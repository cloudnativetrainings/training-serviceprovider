# Training Infra

## Run localy

```bash
cd terraform
make get-sensitive-data
make create
# trainee files are in the directory "out/"
```

## Run on github

1. commit your changes in the file `in/trainings.yaml`
2. github actions will take over and create the infra
3. trainee files are in the directory `out/` of the created artifact by the github action run of the job called `run-terraform-apply`

## VM management

> ATTENTION: All VMs in all projects are taken into concern here

### Show all created VMs in all projects

```bash
for project in $(gcloud projects list --format="value(project_id)"); \
  do gcloud compute instances list --project $project; \
done
```

### Stop all created VMs in all projects

```bash
for project in $(gcloud projects list --format="value(project_id)"); \
  do for vm in $(gcloud compute instances list --project $project --format="value(name)"); \
    do gcloud compute instances stop $vm --project $project; \
  done
done
```

### Start all created VMs in all projects

```bash
for project in $(gcloud projects list --format="value(project_id)"); \
  do for vm in $(gcloud compute instances list --project $project --format="value(name)"); \
    do gcloud compute instances start $vm --project $project; \
  done
done
```
