output "advanced-operations-of-kubernetes-with-kubeone-events" {
  value = [
    for event in coalesce(try(local.k1_yaml, []), []) : {
      event_id = event.event_id
      trainees = [
        for trainee in coalesce(try(event.trainees, []), []) : {
          name = trainee.name
        }
      ]
    }
  ]
}

output "kubermatic-kubernetes-platform-administration-training-events" {
  value = [
    for event in coalesce(try(local.kkp_yaml, []), []) : {
      event_id = event.event_id
      trainees = [
        for trainee in coalesce(try(event.trainees, []), []) : {
          name = trainee.name
        }
      ]
    }
  ]
}

output "kubernetes-security-training-events" {
  value = [
    for event in coalesce(try(local.ks_yaml, []), []) : {
      event_id = event.event_id
      trainees = [
        for trainee in coalesce(try(event.trainees, []), []) : {
          name = trainee.name
        }
      ]
    }
  ]
}

output "kubernetes-fundamentals-for-operators-training-events" {
  value = [
    for event in coalesce(try(local.kfo_yaml, []), []) : {
      event_id = event.event_id
      trainees = [
        for trainee in coalesce(try(event.trainees, []), []) : {
          name = trainee.name
        }
      ]
    }
  ]
}


output "linux-fundamentals-training-events" {
  value = [
    for event in coalesce(try(local.lf_yaml, []), []) : {
      event_id = event.event_id
      trainees = [
        for trainee in coalesce(try(event.trainees, []), []) : {
          name = trainee.name
        }
      ]
    }
  ]
}
