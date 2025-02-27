resource "google_project" "ks_projects" {
  name            = var.project_id
  project_id      = var.project_id
  org_id          = var.main_project_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

resource "google_project_iam_member" "ks_projects_iam_member_sa_owner" {
  depends_on = [google_project.ks_projects]

  project = var.project_id
  role    = "roles/owner"
  member  = format("serviceAccount:%s", var.main_sa_email)
}

resource "google_project_service" "ks_projects_googleapis" {
  depends_on = [google_project_iam_member.ks_projects_iam_member_sa_owner]

  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_compute_firewall" "ks_allow_ingress" {
  depends_on = [google_project_iam_member.ks_projects_iam_member_sa_owner,
  google_project_service.ks_projects_googleapis]

  name    = "allow-ingress"
  network = "default"
  project = var.project_id
  allow {
    protocol = "tcp"
    ports    = ["10250", "6443", "30000-32767"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = 1000
}

variable "main_sa_email" {
  type = string
}

variable "main_project_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "billing_account" {
  type = string
}



