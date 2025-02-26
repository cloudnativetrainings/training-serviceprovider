resource "google_project" "k1_projects" {
  for_each        = { for event in local.k1_yaml : format("k1-%s", event.event_id) => event }
  name            = each.key
  project_id      = each.key
  org_id          = var.main_project_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

resource "google_project_iam_member" "k1_projects_iam_member_sa_owner" {
  depends_on = [google_project.k1_projects]

  for_each = { for event in local.k1_yaml : format("k1-%s", event.event_id) => event }
  project  = each.key
  role     = "roles/owner"
  member   = format("serviceAccount:%s", var.main_sa_email)
}

resource "google_project_service" "k1_projects_googleapi_compute" {
  depends_on = [google_project_iam_member.k1_projects_iam_member_sa_owner]

  for_each = { for event in local.k1_yaml : format("k1-%s", event.event_id) => event }
  project  = each.key
  service  = "compute.googleapis.com"
}

module "advanced_operations_of_kubernetes_with_kubeone" {
  depends_on = [google_project_service.k1_projects_googleapi_compute]

  for_each     = { for trainee in local.flattened_k1 : format("k1-%s-%s", trainee.event_id, trainee.trainee_name) => trainee }
  source       = "./modules/advanced_operations_of_kubernetes_with_kubeone"
  project_id   = format("k1-%s", each.value.event_id)
  trainee_name = each.value.trainee_name
  event_id     = each.value.event_id
}
