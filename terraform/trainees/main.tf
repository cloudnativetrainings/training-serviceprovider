resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file("cloud_init.yaml")
    filename     = "cloud_init.yaml"
  }
}

resource "google_compute_instance" "vm" {
  depends_on   = [tls_private_key.ssh_key, data.cloudinit_config.cloud_init]
  project      = var.project_id
  name         = var.vm_name
  machine_type = "n2-standard-4"

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
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
  depends_on = [tls_private_key.ssh_key]

  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = format("out/kubernetes_security/%s/%s/ssh-private-key", var.event_id, var.trainee_name)
  file_permission = "0400"
}

resource "local_file" "ssh_config_file" {
  depends_on = [google_compute_instance.vm]

  content         = <<EOF
Host kubernetes-security-vm
  HostName ${google_compute_instance.vm.network_interface.0.access_config.0.nat_ip}
  User root
  IdentityFile ./ssh-private-key
EOF
  filename        = format("out/kubernetes_security/%s/%s/ssh-config", var.event_id, var.trainee_name)
  file_permission = "0400"
}

variable "project_id" {
  type = string
}

variable "trainee_name" {
  type = string
}

variable "event_id" {
  type = string
}

variable "vm_name" {
  type = string
}
