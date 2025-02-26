resource "google_project" "ks_projects" {
  for_each        = { for event in local.ks_yaml : format("ks-%s", event.event_id) => event }
  name            = each.key
  project_id      = each.key
  org_id          = var.main_project_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

resource "google_project_iam_member" "ks_projects_iam_member_sa_owner" {
  depends_on = [google_project.ks_projects]

  for_each = { for event in local.ks_yaml : format("ks-%s", event.event_id) => event }
  project  = each.key
  role     = "roles/owner"
  member   = format("serviceAccount:%s", var.main_sa_email)
}

resource "google_project_service" "ks_projects_googleapis" {
  depends_on = [google_project_iam_member.ks_projects_iam_member_sa_owner]

  for_each = { for event in local.ks_yaml : format("ks-%s", event.event_id) => event }
  project  = each.key
  service  = "compute.googleapis.com"
}

resource "google_compute_firewall" "ks_allow_ingress" {
  depends_on = [google_project_iam_member.ks_projects_iam_member_sa_owner,
  google_project_service.ks_projects_googleapis]

  for_each = { for event in local.ks_yaml : format("ks-%s", event.event_id) => event }
  name     = "allow-ingress"
  network  = "default"
  project  = each.key
  allow {
    protocol = "tcp"
    ports    = ["10250", "6443", "30000-32767"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = 1000
}

module "kubernetes_security" {
  depends_on = [google_project_service.ks_projects_googleapis]

  for_each     = { for trainee in local.flattened_ks : format("ks-%s-%s", trainee.event_id, trainee.trainee_name) => trainee }
  source       = "./modules/kubernetes_security"
  project_id   = format("ks-%s", each.value.event_id)
  trainee_name = each.value.trainee_name
  event_id     = each.value.event_id
  vm_name      = format("ks-%s", each.value.trainee_name)
}
