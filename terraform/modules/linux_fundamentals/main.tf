resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    # TODO path should be relative to the module
    content  = file("modules/linux_fundamentals/cloud_init.yaml")
    filename = "cloud_init.yaml"
  }
}

resource "google_compute_instance" "vm" {
  depends_on   = [tls_private_key.ssh_key, data.cloudinit_config.cloud_init]
  project      = var.project_id
  name         = var.vm_name
  machine_type = "n2-standard-4"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    user-data = "${data.cloudinit_config.cloud_init.rendered}"
    ssh-keys  = "root:${tls_private_key.ssh_key.public_key_openssh}"
  }
}

resource "local_file" "private_key_file" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = format("out/linux-fundamentals/%s/%s/ssh-private-key", var.event_id, var.trainee_name)
  file_permission = "0400"
}

resource "local_file" "ssh_config_file" {
  depends_on = [google_compute_instance.vm]

  content         = <<EOF
Host ${var.vm_name}
  HostName ${google_compute_instance.vm.network_interface.0.access_config.0.nat_ip}
  User root
  IdentityFile ./ssh-private-key
EOF
  filename        = format("out/linux-fundamentals/%s/%s/ssh-config", var.event_id, var.trainee_name)
  file_permission = "0400"
}

resource "local_file" "readme_file" {
  depends_on = [google_compute_instance.vm]

  content         = <<EOF
# Linux Fundamentals Training

## Connect to the VM

```bash
ssh -F ./ssh-config ${var.vm_name}
```
EOF
  filename        = format("out/linux-fundamentals/%s/%s/README.md", var.event_id, var.trainee_name)
  file_permission = "0400"
}
