# ci.iac

Terraform that provisions the AWS side of the [ci.api](https://github.com/lucamandelli/ci.api) CI/CD pipeline. It's applied by its own GitHub Actions workflow, so the infrastructure follows the same flow as application code: commit, push, pipeline.

## What it provisions

| Resource                         | Purpose                                                                  |
| -------------------------------- | ------------------------------------------------------------------------ |
| GitHub OIDC provider             | Lets GitHub Actions authenticate to AWS with short-lived credentials     |
| `tf-role`                        | Assumed by this repo's pipeline to run Terraform                         |
| `ecr-role`                       | Assumed by the ci.api pipeline to push images and deploy to App Runner   |
| `app-runner-role`                | Lets App Runner pull images from ECR                                     |
| ECR repository `luca-ci`         | Stores the ci.api Docker images, with vulnerability scan on push         |
| S3 bucket `luca-iac`             | Terraform remote state, versioned and protected with `prevent_destroy`   |

## How it fits together

```
 ci.iac push to main ─▶ GitHub Actions ─(OIDC, tf-role)─▶ terraform apply ─▶ IAM, ECR, S3

 ci.api push to main ─▶ GitHub Actions ─(OIDC, ecr-role)─▶ ECR ─▶ App Runner
```

Each role only trusts the `main` branch of its own repository, and no AWS access keys are stored in GitHub.

## Pipeline

On every push to `main` ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)):

1. Assume `tf-role` through OIDC
2. `terraform init`
3. `terraform fmt -check`
4. `terraform plan`
5. `terraform apply`

## Files

```
main.tf    provider, S3 backend and the state bucket
iam.tf     OIDC provider, roles and policies
ecr.tf     ECR repository
```

## Next steps

- Scope `tf-role` permissions down to the specific resources it manages
- Run `plan` on pull requests and keep `apply` for merges into `main`
