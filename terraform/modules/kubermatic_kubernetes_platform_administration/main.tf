resource "google_service_account" "google_service_account" {
  account_id   = format("%s-%s", var.event_id, var.trainee_name)
  display_name = format("%s-%s", var.event_id, var.trainee_name)
  project      = var.project_id
}

resource "google_service_account_key" "google_service_account_key" {
  depends_on = [google_service_account.google_service_account]

  service_account_id = google_service_account.google_service_account.name
}

resource "local_file" "service_account_file" {
  depends_on = [google_service_account_key.google_service_account_key]

  content         = base64decode(google_service_account_key.google_service_account_key.private_key)
  filename        = format("out/kubermatic-kubernetes-platform-administration/%s/%s/gcloud-service-account.json", var.event_id, var.trainee_name)
  file_permission = "0400"
}

resource "google_project_iam_member" "roles" {
  depends_on = [local_file.service_account_file]

  for_each = toset([
    "roles/compute.admin",
    "roles/iam.serviceAccountUser",
    "roles/viewer",
    "roles/dns.admin",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.google_service_account.email}"
  project = var.project_id
}

resource "google_dns_managed_zone" "dns_zone" {
  name          = format("%s-%s", var.event_id, var.trainee_name)
  project       = var.project_id
  dns_name      = format("%s.%s.%s.", var.trainee_name, var.event_id, var.dns_name)
  force_destroy = true
}

resource "google_dns_record_set" "nameserver_dns_record" {
  depends_on   = [google_dns_managed_zone.dns_zone]
  project      = "loodse-training-infrastructure"
  name         = format("%s.%s.%s.", var.trainee_name, var.event_id, var.dns_name)
  managed_zone = var.dns_zone_name
  type         = "NS"
  ttl          = 60
  rrdatas      = google_dns_managed_zone.dns_zone.name_servers
}

# resource "google_compute_address" "kkp_ip" {
#   depends_on = [google_dns_record_set.nameserver_dns_record]

#   name    = "kkp-ip"
#   project = var.project_id
# }

# resource "google_compute_address" "kkp_seed_ip" {
#   depends_on = [google_dns_record_set.nameserver_dns_record]

#   name    = "kkp-seed-ip"
#   project = var.project_id
# }

# resource "google_dns_record_set" "kkp_dns" {
#   depends_on = [google_compute_address.kkp_ip]

#   project      = var.project_id
#   name         = format("%s.%s.%s.", var.trainee_name, var.event_id, var.dns_name)
#   managed_zone = google_dns_managed_zone.dns_zone.name
#   type         = "A"
#   ttl          = 60
#   rrdatas      = [google_compute_address.kkp_ip.address]
# }

# resource "google_dns_record_set" "kkp_wildcard_dns" {
#   depends_on = [google_compute_address.kkp_ip]

#   project      = var.project_id
#   name         = format("*.%s.%s.%s.", var.trainee_name, var.event_id, var.dns_name)
#   managed_zone = google_dns_managed_zone.dns_zone.name
#   type         = "A"
#   ttl          = 60
#   rrdatas      = [google_compute_address.kkp_ip.address]
# }

# resource "google_dns_record_set" "kkp_seed_wildcard_dns" {
#   depends_on = [google_compute_address.kkp_seed_ip]

#   project      = var.project_id
#   name         = format("*.kubermatic.%s.%s.%s.", var.trainee_name, var.event_id, var.dns_name)
#   managed_zone = google_dns_managed_zone.dns_zone.name
#   type         = "A"
#   ttl          = 60
#   rrdatas      = [google_compute_address.kkp_seed_ip.address]
# }


resource "local_file" "readme_file" {
  # depends_on      = [google_dns_record_set.kkp_ip, google_dns_record_set.kkp_wildcard_dns, google_dns_record_set.kkp_seed_wildcard_dns]
  content = <<EOF
# Kubermatic Kubernetes Platform Administration Training

## Environment

```
Google Project id: ${var.project_id}
Domain: ${format("%s.%s.%s", var.trainee_name, var.event_id, var.dns_name)}
 
```
EOF

  # DNS:
  #   ${google_dns_record_set.kkp_dns.name} ${google_compute_address.kkp_ip.address}
  #   ${google_dns_record_set.kkp_wildcard_dns.name} ${google_compute_address.kkp_ip.address}
  #   ${google_dns_record_set.kkp_seed_wildcard_dns.name} ${google_compute_address.kkp_seed_ip.address}


  filename        = format("out/kubermatic-kubernetes-platform-administration/%s/%s/README.md", var.event_id, var.trainee_name)
  file_permission = "0400"
}

