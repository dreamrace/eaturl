# Shortener

This is a urlshortener written in golang, deployable in AWS via Terraform

## How to build

We utilize packer as image packaging tool here, internally we use shell script, golang utils to build the software and manage dependencies.

```sh
packer validate packer.json
packer build packer.json
```

## How to deploy

Supply to required to variables specified in variables.tf, then

```sh
terraform plan
terraform apply
```

## Answers for other questions

Please refer to Answers.md
