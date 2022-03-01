# xe_code_challenge

The provisioning of AWSRedrive.core and SQS/SNS pair is using Terraform and Ansible.\
It is split between tf_files (terraform files, implied by the name), and ansible_files.\
An S3 bucket is used for state locking (backend-state sub-directory).\
The main variable is env, which can be either dev, staging, or prod, and the created infra is named accordingly.  

To set-up the application, execute the following commands:

```Shell
cd tf_files
ssh-keygen -f xe-code-challenge-key-pair
terraform init
terraform plan -out=dev_plan -var 'env=dev'
terraform apply dev_plan
cd ../ansible_files/
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/servers app.yaml
```

What the above commands achieve:
1. Create ssh-key pair to access the instance via SSH.
2. Provision the AWS infra and template ansible inventory.
   - Create a VPC and inside configure a public subnet.
   - Create a gateway via which traffic from the public subnet is routed, to reach the internet.
   - Allow ssh access from our public IP and disable outgoing access.
   - Provision the instance, SNS endpoint, and SQS. 
3. Provision application config.
   - Update the OS packages.
   - Install and configure AWSRedrive.core application. 


The terraform dir structure is as such:

```Shell
├── backend-state
│   ├── outputs.tf
│   ├── provider.tf
│   └── state.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── iam_role.tf
├── templates
│   └── inventory.tmpl
├── variables.tf
└──  vpc.tf
```

The ansible dir structure is as such:

```Shell
├── app.yaml
├── inventories
│   └── servers
└── roles
    ├── install_awsredrive
    │   ├── tasks
    │   │   └── main.yaml
    │   └── templates
    │       ├── config.json.j2
    │       └── systemd.j2
    └── update_instance
        └── tasks
            └── main.yaml
```