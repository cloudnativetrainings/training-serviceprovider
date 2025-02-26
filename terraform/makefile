export VAULT_ADDR=https://vault.loodse.com
export GOOGLE_CREDENTIALS=../.vault/gcloud-service-account.json

.PHONY: get-sensitive-data
get-sensitive-data:
	mkdir -p ../.vault
	vault login --method=oidc --path=loodse
	vault kv get -field gcloud-service-account.json \
		sig-cs-infra/training/gcloud-terraform > ../.vault/gcloud-service-account.json
	vault kv get -field terraform.tfvars \
		sig-cs-infra/training/gcloud-terraform > ../.vault/terraform.tfvars

.PHONY: init
init:
	terraform init

.PHONY: plan
plan: init
	terraform plan -var-file="../.vault/terraform.tfvars"

.PHONY: create
create: plan
	mkdir -p ./out
	terraform apply -var-file="../.vault/terraform.tfvars" -auto-approve
	terraform output -json > ./out/tf.json
