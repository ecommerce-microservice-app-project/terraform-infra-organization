# Resource Group Module

This module creates a Resource Group in Azure.

## Usage

```hcl
module "resource_group" {
  source = "./modules/resource-group"

  name     = "my-resource-group"
  location = "East US 2"
  tags = {
    Environment = "dev"
  }
}
```

## Variables

| Name     | Description          | Type        | Required | Default |
|----------|----------------------|-------------|----------|---------|
| name     | Resource group name  | string      | Yes      | -       |
| location | Azure region         | string      | Yes      | -       |
| tags     | Tags to apply        | map(string) | No       | {}      |

## Outputs

| Name     | Description                |
|----------|----------------------------|
| name     | Resource group name        |
| location | Resource group location    |
| id       | Resource group ID          |
