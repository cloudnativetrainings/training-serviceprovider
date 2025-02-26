terraform {
  backend "gcs" {
    bucket      = "tf-state-cloud-native-training"
    credentials = "../.vault/gcloud-service-account.json"
  }
}
