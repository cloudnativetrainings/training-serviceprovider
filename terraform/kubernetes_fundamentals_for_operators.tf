resource "google_project" "kfo_projects" {
  for_each        = { for event in local.kfo_yaml : format("kfo-%s", event.event_id) => event }
  name            = each.key
  project_id      = each.key
  org_id          = var.main_project_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

resource "google_project_iam_member" "kfo_projects_iam_member_sa_owner" {
  depends_on = [google_project.kfo_projects]

  for_each = { for event in local.kfo_yaml : format("kfo-%s", event.event_id) => event }
  project  = each.key
  role     = "roles/owner"
  member   = format("serviceAccount:%s", var.main_sa_email)
}

resource "google_project_service" "kfo_projects_googleapi_compute" {
  depends_on = [google_project_iam_member.kfo_projects_iam_member_sa_owner]

  for_each = { for event in local.kfo_yaml : format("kfo-%s", event.event_id) => event }
  project  = each.key
  service  = "compute.googleapis.com"
}

resource "google_project_service" "kfo_projects_googleapi_cloudresourcemanager" {
  depends_on = [google_project_iam_member.kfo_projects_iam_member_sa_owner]

  for_each = { for event in local.kfo_yaml : format("kfo-%s", event.event_id) => event }
  project  = each.key
  service  = "cloudresourcemanager.googleapis.com"
}

module "kubernetes_fundamentals_for_operators" {
  depends_on = [google_project_service.kfo_projects_googleapi_compute]

  for_each     = { for trainee in local.flattened_kfo : format("kfo-%s-%s", trainee.event_id, trainee.trainee_name) => trainee }
  source       = "./modules/kubernetes_fundamentals_for_operators"
  project_id   = format("kfo-%s", each.value.event_id)
  trainee_name = each.value.trainee_name
  event_id     = each.value.event_id
}
