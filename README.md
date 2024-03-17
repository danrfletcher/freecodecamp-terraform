## 🛠️ Project Resources
- [GPT-4 Thread](https://chat.openai.com/c/ae91f41e-b17a-4906-b486-728ed69d8779)
- [GPT-3.5 Thread](https://chat.openai.com/c/487d9083-d9cd-4bec-a5f5-61fefe117647)
- [Video Course](https://www.youtube.com/watch?v=SLB_c_ayRMo)
- [Bash Logs](./Bash) (.gitignored)

## Terraform Commands
- terraform init
- terraform plan
- terraform apply
    - -auto-approve flag (eliminates need to manually confirm with user input)
    - -target {resource name} (targets an individual resource to create)
    - -var "{variable name}={value}" (specifies a variable to be passed into on resource creation)
    - -var-file {name of variable file}.tfvars (specifies variable file, not terraform.tfvars)
- terraform destroy
    - -target {resource name} (targets an individual resource to destroy)
- terraform state show {name}
- terraform state list
- terraform refresh (get outputs from main.tf without deploying)

## Setup
1. Create secrets.tfvars file
2. Create access & secret key from AWS (click name in top right > security credentials > create access key)
2. Add the following:

```
aws_access_key = "copy from AWS console"
aws_secret_key = "copy from AWS console"
```

3. Run `terraform init`