## terraform tests

## uniqueness of trainee ane event

## check name of project length and symbols

```
# │ Error: "linux-fundamentals-event-for-customer-a" name must be 4 to 30 characters with lowercase and uppercase letters, numbers, hyphen, single-quote, double-quote, space, and exclamation point.

# │

# │ with google_project.linux-fundamentals-projects["linux-fundamentals-event-for-customer-a"],

# │ on linux_fundamentals.tf line 3, in resource "google_project" "linux-fundamentals-projects":

# │ 3: name = each.key

```

## where to store tf shared state file

## get sensitive stuff from vault

## makefile and github actions

## make more sense of output

## better solution for for loop in for loop with yaml => coalesce

## out folder del old folders

## add dns entries to kkp after https://github.com/kubermatic/kubermatic/issues/14084

## do ssh via gcloud => maybe there is an issue when the ssh key is on yet existing on the local machine running terraform

## on copying the ssh key to codespaces it has the wrong permissions

```bash
Permissions 0666 for './ssh-private-key' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "./ssh-private-key": bad permissions
root@35.198.114.184: Permission denied (publickey).
@stroebitzer ➜ /workspaces/kubernetes-security (main) $ chmod 0400 ssh-private-key
```

## add bins to kkp codespaces training

```bash
# uuidgen
sudo apt-get install uuid-runtime

# gcloud
https://cloud.google.com/sdk/docs/install#deb

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli

# nslookup
sudo apt install dnsutils

# htpasswd
sudo apt-get install apache2-utils
```

## Kubernetes Security

- get trainingrc files from training repo and do it in the init-repo
- problem: getting the files into cloud init
  - multipart cloud init files did not work
  - cvopying shell scripts via terraform also did not work

# create own space in vault for all the training secrets

# project name

create a new project instead of loodse-training-infrastructure => eg cloud-native.training and store the bucket into it

# yaml structure does not work

```yaml
kubernetes_security:
  - event_id: cicd-02
    # trainees:
    # - name: hubert-01
    # - name: hubert-02
  - event_id: cicd-03
    trainees:
      - name: tobi
      - name: hubert
```

```yaml
kubernetes_security:
  - event_id: cicd-02
    trainees:
    # - name: hubert-01
    # - name: hubert-02
  - event_id: cicd-03
    trainees:
      - name: tobi
      - name: hubert
```

# problem with ssh keys generated not on the same machine => GCP ssh key

```bash
# module.kubernetes_security["ks-cicd-03-tobi"].google_compute_instance.vm: Destruction complete after 1m2s
# module.kubernetes_security["ks-cicd-03-tobi"].tls_private_key.ssh_key: Destroying... [id=a12e951837c09c5ba880423788d19d3802a3ddce]
# module.kubernetes_security["ks-cicd-03-tobi"].tls_private_key.ssh_key: Destruction complete after 0s
# ╷
# │ Error: Provider produced inconsistent final plan
# │
# │ When expanding the plan for
# │ module.kubernetes_security["ks-cicd-03-hubert"].local_file.ssh_config_file
# │ to include new values learned so far during apply, provider
# │ "registry.terraform.io/hashicorp/local" produced an invalid new value for
# │ .content: was cty.StringVal("Host kubernetes-security-vm\n  HostName
# │ 34.159.139.236\n  User root\n  IdentityFile ./ssh-private-key\n"), but now
# │ cty.StringVal("Host kubernetes-security-vm\n  HostName \n  User root\n
# │ IdentityFile ./ssh-private-key\n").
# │
# │ This is a bug in the provider, which should be reported in the provider's
# │ own issue tracker.
# ╵
# make: *** [makefile:23: create] Error 1
# Error: Process completed with exit code 2.
```

# after stop and restart of vm

```bash
cat /var/log/cloud-init-output.log | grep "CloudInit Finished Successfully"
================================================= CloudInit Finished Successfully
test -f /root/.trainingrc
kubectx
kubernetes-admin@kubernetes
kubens
calico-apiserver
calico-system
default
kube-node-lease
kube-public
kube-system
tigera-operator
kubectl krew version
error: unknown command "krew" for "kubectl"
```

# after stoping and restarting the vm the ip of vms change

```
@stroebitzer ➜ /workspaces/kubernetes-security (main) $ ssh -v -F ssh-config kubernetes-security-vm
OpenSSH_8.2p1 Ubuntu-4ubuntu0.11, OpenSSL 1.1.1f  31 Mar 2020
debug1: Reading configuration data ssh-config
debug1: ssh-config line 1: Applying options for kubernetes-security-vm
debug1: Connecting to 34.159.139.236 [34.159.139.236] port 22.
```

# KFO Todos

## can I set this on creating the projects via terraform?

```bash
gcloud auth activate-service-account --key-file=./gcloud-service-account.json
gcloud config set project <PROJECT_ID>
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a
```

## force bash only in codespaces

## more-safe-scripts crash the terminal

```bash
set -euxo pipefail
```
