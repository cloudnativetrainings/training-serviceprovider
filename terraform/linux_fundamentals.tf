resource "google_project" "lf_projects" {
  for_each        = { for event in local.lf_yaml : format("lf-%s", event.event_id) => event }
  name            = each.key
  project_id      = each.key
  org_id          = var.main_project_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

resource "google_project_iam_member" "lf_projects_iam_member_sa_owner" {
  depends_on = [google_project.lf_projects]

  for_each   = { for event in local.lf_yaml : format("lf-%s", event.event_id) => event }
  project    = each.key
  role       = "roles/owner"
  member     = format("serviceAccount:%s", var.main_sa_email)
}

resource "google_project_service" "lf_projects_googleapis" {
  depends_on = [google_project_iam_member.lf_projects_iam_member_sa_owner]

  for_each = { for event in local.lf_yaml : format("lf-%s", event.event_id) => event }
  project  = each.key
  service  = "compute.googleapis.com"
}

module "linux_fundamentals" {
  depends_on = [google_project_service.lf_projects_googleapis]

  for_each     = { for trainee in local.flattened_lf : format("lf-%s-%s", trainee.event_id, trainee.trainee_name) => trainee }
  source       = "./modules/linux_fundamentals"
  project_id   = format("lf-%s", each.value.event_id)
  trainee_name = each.value.trainee_name
  event_id     = each.value.event_id
  vm_name      = format("linux-fundamentals-%s", each.value.trainee_name)
}
