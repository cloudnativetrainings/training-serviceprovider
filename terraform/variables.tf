variable "main_sa_email" {
  type = string
}

variable "main_project_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "dns_zone_name" {
  type = string
}
variable "dns_name" {
  type = string
}

variable "trainings_file" {
  default = "in/trainings.yaml"
  type    = string
}

locals {

  trainings_yaml = yamldecode(file(var.trainings_file))

  k1_yaml = coalesce(try(local.trainings_yaml.advanced_operations_of_kubernetes_with_kubeone, []), [])
  flattened_k1 = flatten([
    for event in local.k1_yaml : [
      for trainee in coalesce(try(event.trainees, []), []) : {
        event_id     = event.event_id
        trainee_name = trainee.name
      }
    ]
  ])

  kkp_yaml = coalesce(try(local.trainings_yaml.kubermatic_kubernetes_platform_administration, []), [])
  flattened_kkp = flatten([
    for event in local.kkp_yaml : [
      for trainee in coalesce(try(event.trainees, []), []) : {
        event_id     = event.event_id
        trainee_name = trainee.name
      }
    ]
  ])

  kfo_yaml = coalesce(try(local.trainings_yaml.kubernetes_fundamentals_for_operators, []), [])
  flattened_kfo = flatten([
    for event in local.kfo_yaml : [
      for trainee in coalesce(try(event.trainees, []), []) : {
        event_id     = event.event_id
        trainee_name = trainee.name
      }
    ]
  ])


  ks_yaml = coalesce(try(local.trainings_yaml.kubernetes_security, []), [])
  flattened_ks = flatten([
    for event in local.ks_yaml : [
      for trainee in coalesce(try(event.trainees, []), []) : {
        event_id     = event.event_id
        trainee_name = trainee.name
      }
    ]
  ])

  lf_yaml = coalesce(try(local.trainings_yaml.linux_fundamentals, []), [])
  flattened_lf = flatten([
    for event in local.lf_yaml : [
      for trainee in coalesce(try(event.trainees, []), []) : {
        event_id     = event.event_id
        trainee_name = trainee.name
      }
    ]
  ])

}
