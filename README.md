# terraform-demo-project

## Please comment the s3 backend configuration in main.tf if not required and then go for further steps

## To Initialise the Directory, please run `terraform init`

## There are workspaces available for specific region and environment
### To list the workspaces, please run `terraform workspace list`
### Select any available workspace for target environment and region, if target entity is not available, then please make it with `terraform workspace new ENVIRONMENT_REGION`. In the value at the last of the creation command, ENVIRONMENT stands for environment name and REGION stands for AWS Region name, both are separated by "_"

## To Plan the Changes, please run `terraform plan`

## To Execute the Changes, please run `terraform apply` and give 'yes' to the confirmation