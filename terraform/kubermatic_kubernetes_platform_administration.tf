resource "google_project" "kkp_projects" {
  for_each        = { for event in local.kkp_yaml : format("kkp-%s", event.event_id) => event }
  name            = each.key
  project_id      = each.key
  org_id          = var.main_project_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

resource "google_project_iam_member" "kkp_projects_iam_member_sa_owner" {
  depends_on = [google_project.kkp_projects]

  for_each = { for event in local.kkp_yaml : format("kkp-%s", event.event_id) => event }
  project  = each.key
  role     = "roles/owner"
  member   = format("serviceAccount:%s", var.main_sa_email)
}

resource "google_project_service" "kkp_projects_googleapi_compute" {
  depends_on = [google_project_iam_member.kkp_projects_iam_member_sa_owner]

  for_each = { for event in local.kkp_yaml : format("kkp-%s", event.event_id) => event }
  project  = each.key
  service  = "compute.googleapis.com"
}

resource "google_project_service" "kkp_projects_googleapi_dns" {
  depends_on = [google_project_iam_member.kkp_projects_iam_member_sa_owner]

  for_each = { for event in local.kkp_yaml : format("kkp-%s", event.event_id) => event }
  project  = each.key
  service  = "dns.googleapis.com"
}

module "kubermatic_kubernetes_platform_administration" {
  depends_on = [google_project_service.kkp_projects_googleapi_compute, 
                google_project_service.kkp_projects_googleapi_dns]

  for_each      = { for trainee in local.flattened_kkp : format("kkp-%s-%s", trainee.event_id, trainee.trainee_name) => trainee }
  source        = "./modules/kubermatic_kubernetes_platform_administration"
  project_id    = format("kkp-%s", each.value.event_id)
  trainee_name  = each.value.trainee_name
  event_id      = each.value.event_id
  dns_zone_name = var.dns_zone_name
  dns_name      = var.dns_name
}
