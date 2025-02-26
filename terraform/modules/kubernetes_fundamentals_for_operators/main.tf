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
  filename        = format("out/kubernetes-fundamentals-for-operators/%s/%s/gcloud-service-account.json", var.event_id, var.trainee_name)
  file_permission = "0400"
}

resource "google_project_iam_member" "roles" {
  depends_on = [local_file.service_account_file]

  for_each = toset([
    "roles/compute.admin",
    "roles/iam.serviceAccountUser"
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.google_service_account.email}"
  project = var.project_id
}

# resource "google_compute_address" "static_ip" {
#   name    = format("%s-%s", var.event_id, var.trainee_name)
#   project = var.project_id
# }

resource "local_file" "readme_file" {
  content         = <<EOF
# Kubernetes Fundamentals for Operators

## Environment

```
Google Project id: ${var.project_id}
Trainee Name: ${var.trainee_name}
```
EOF
  filename        = format("out/kubernetes-fundamentals-for-operators/%s/%s/README.md", var.event_id, var.trainee_name)
  file_permission = "0400"
}
