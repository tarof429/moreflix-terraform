# Moreflix Terraform

## Introduction

This project is used to create an EC2 instance.

## Usage

```sh
terraform plan -var "docker_user=<docker username>" -var "docker_pass=<docker password>" -var "my_ip=$(curl ifconfig.me)/32 -var "keypair_name="moreflix-keypair"
```