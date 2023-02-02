# Terraform Module: Hashicorp Vault GitHub OIDC <!-- omit in toc -->

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/digitalocean/terraform-vault-github-oidc)
[![OIDC Tests](https://github.com/digitalocean/terraform-vault-github-oidc/actions/workflows/oidc_test.yaml/badge.svg)](https://github.com/digitalocean/terraform-vault-github-oidc/actions/workflows/oidc_test.yaml)
![GitHub](https://img.shields.io/github/license/digitalocean/terraform-vault-github-oidc)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6305/badge)](https://bestpractices.coreinfrastructure.org/projects/6305)
![GitHub contributors](https://img.shields.io/github/contributors/digitalocean/terraform-vault-github-oidc)
![GitHub last commit](https://img.shields.io/github/last-commit/digitalocean/terraform-vault-github-oidc)

Terraform module to configure Vault for GitHub OIDC authentication from Action runners on GitHub.com or self-hosted GitHub Enterprise Server.

OIDC authentication allows us to bind GitHub repositories (and subcomponents of a repository, such as a branch, ref, or environment)
to a Vault role without needing to manage actual credentials that require a lifecycle system, integration into repo-level
GitHub Secrets, or other organizational glue.

Explore GitHub OIDC and HashiCorp Vault use cases with this hands-on workshop: <https://github.com/artis3n/course-vault-github-oidc>.

Reference documents that help with understanding the process:
- <https://docs.github.com/en/enterprise-cloud@latest/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault>

Once OIDC authentication is configured on a Vault server via this module, a GitHub repository can leverage
[hashicorp/vault-action](https://github.com/hashicorp/vault-action) to retrieve secrets from Vault with GitHub OIDC authentication.
No secrets or credential management needed!

e.g.

```yml
- name: Import Secrets
  uses: hashicorp/vault-action@v2
  id: secrets
  with:
    exportEnv: false
    url: https://<your-vault-URL>
    path: github-actions
    method: jwt
    role: <vault_role_name>
    secrets: |
      secret/data/foo/bar fi | MY_SECRET

- name: Access secret
  run: echo '${{steps.secrets.outputs.MY_SECRET }}' | my_command
```

- [Usage](#usage)
  - [Examples](#examples)
  - [Considerations for Enterprise Cloud organizations](#considerations-for-enterprise-cloud-organizations)
  - [Variables](#variables)
    - [oidc\_bindings](#oidc_bindings)
      - [oidc\_bindings.audience](#oidc_bindingsaudience)
      - [oidc\_bindings.vault\_role\_name](#oidc_bindingsvault_role_name)
      - [oidc\_bindings.bound\_subject](#oidc_bindingsbound_subject)
      - [oidc\_bindings.vault\_policies](#oidc_bindingsvault_policies)
      - [oidc\_bindings.user\_claim](#oidc_bindingsuser_claim)
      - [oidc\_bindings.additional\_claims](#oidc_bindingsadditional_claims)
      - [oidc\_bindings.ttl](#oidc_bindingsttl)
    - [default\_ttl](#default_ttl)
    - [default\_user\_claim](#default_user_claim)
    - [oidc\_auth\_backend\_path](#oidc_auth_backend_path)
    - [github\_identity\_provider](#github_identity_provider)
    - [token\_type](#token_type)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [Authors](#authors)
- [License](#license)

# Usage

This module simplifies the creation of the JWT auth backend on Vault for this GitHub Action OIDC use case.
The module requires you to configure what repositories to bind to Vault roles and policies, and under what
conditions the respective repository should be granted access.
This is encapsulated by the `oidc_bindings` variable.

> **Note**
>
> v2 of this module adopts Terraform 1.3's standardized support of [optional object type attributes](https://www.terraform.io/language/expressions/type-constraints#optional-object-type-attributes).
> Therefore, Terraform 1.3+ is required to use v2.0.0 or higher.
>
> Users with Terraform 1.2 or earlier can use v1.1.0 of this module with the [`module_variable_optional_attrs`](https://www.terraform.io/language/v1.2.x/expressions/type-constraints#experimental-optional-object-type-attributes) experimental Terraform feature enabled.

## Examples

Tutorial/example repo: <https://github.com/artis3n/github-oidc-vault-example>.

You can find several examples leveraging this module under `examples/`:
- [Basic usage](/examples/simple-repo)
- [Leveraging JSON files for distributed organization of repo bindings](/examples/json-files)
- [Adding custom additional claims per OIDC binding](/examples/additional-claims)
- [Leveraging this module on-prem with GitHub Enterprise Server](/examples/github-enterprise)

Basic example - one repo, separating secrets access by nonprod and prod pipelines.

```terraform
module "github-vault-oidc" {
  source = "digitalocean/github-oidc/vault"
  version = "~> 2.1.0"

  oidc_bindings = [
    {
      audience : "https://github.com/artis3n",
      vault_role_name : "oidc-dev-role",
      bound_subject : "repo:artis3n/github-oidc-vault-example:pull_request",
      vault_policies : [
        vault_policy.dev.name,
      ],
    },
    {
      audience : "https://github.com/artis3n",
      vault_role_name : "oidc-deploy-role",
      bound_subject : "repo:artis3n/github-oidc-vault-example:ref:refs/heads/main",
      vault_policies : [
        vault_policy.deployment.name,
      ],
    },
  ]
}

resource "vault_policy" "dev" {
  name   = "oidc-dev"
  policy = data.vault_policy_document.dev.hcl
}

data "vault_policy_document" "dev" {
  rule {
    path         = "secret/data/dev/foo"
    capabilities = ["read"]
  }
}

resource "vault_policy" "deployment" {
  name = "oidc-deploy"
  policy = data.vault_policy_document.deployment.hcl
}

data "vault_policy_document" "deployment" {
  rule {
    path         = "secret/data/prod/bar"
    capabilities = ["read"]
  }
}
```

## Considerations for Enterprise Cloud organizations

Enterprise Cloud organizations should strongly consider enabling the [Unique Token URL](https://docs.github.com/en/enterprise-cloud@latest/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#switching-to-a-unique-token-url) feature for their organization.

If they do so, they should set the `github_identity_provider` variable of this module to their enterprise's unique token URL.

## Variables

### oidc_bindings

This input variable must be a list of objects containing the following structure:

```terraform
oidc_bindings = [
  {
    audience: '',
    vault_role_name: '',
    bound_subject: '',
    vault_policies: [''],
  }
]
```

There are additional, optional values you can include as well:

```terraform
oidc_bindings = [
  {
    audience: '',
    vault_role_name: '',
    bound_subject: '',
    vault_policies: [''],
    # Optional below
    user_claim: '',
    additional_claims: [
      {
        x: '',
      }
    ],
    ttl: 0,
  }
]
```

Descriptions for each parameter are below:

#### oidc_bindings.audience

By default, the `audience` must be the URL of the repository owner (e.g. `https://github.com/digitalocean`).

The `audience` can be customized by configuring [whatever you'd like](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#requesting-the-access-token) and using the `jwtGithubAudience` parameter in
[hashicorp/vault-action](https://github.com/hashicorp/vault-action).
For example, from an organizational or audit perspective, you may desire to establish a naming scheme such as `audience: "<company>:<org-unit>:<team-name>"`, e.g. `digitalocean:security:product-security`.

#### oidc_bindings.vault_role_name

The `vault_role_name` must be the name of the Vault role you wish to create on the JWT auth backend.
Each Vault role should be configured for one repo subject - using the same Vault role with different configurations in the rest of
the parameters will cause this module to fail.
This is because you would otherwise silently overwrite the role configuration.

You may want to create multiple Vault roles for a single GitHub repository, e.g. a nonprod CI workflow that needs access
to CI secrets, and a deployment workflow that publishes a release that needs production secrets.

#### oidc_bindings.bound_subject

The `bound_subject` must be the `sub` field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).
The bound subject can be constructed from various filters, such as a branch, tag, or specific [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).
See [GitHub's documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) for examples.

#### oidc_bindings.vault_policies

`vault_policies` must be a list of Vault policy strings to grant to the `vault_role_name` Vault role being configured.
These can also come from [`vault_policy` resources](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#name).

#### oidc_bindings.user_claim

**Optional**

The `user_claim` is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client.
This will be used as the name for the Identity entity alias created due to a successful login.
This means it will determine the `auth.display_name` value in Vault audit logs.

This must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).
Defaults to the value of the [`default_user_claim`](#default_user_claim) variable if not provided.

We strongly recommend you keep a consistent format for `auth.display_name` for monitoring of Vault's audit log.
Instead of changing the `user_claim` for a specific role, consider modifying the [`default_user_claim`](#default_user_claim) variable to apply a format change to all roles managed through this module.

#### oidc_bindings.additional_claims

**Optional**

`additional_claims` must be a list of any additional claims you would like to enforce in the Vault role binding.
Each `key` must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).

For example, to leverage [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows)
with OIDC, you may wish to set your `bound_subject` to `repo:ORG_NAME/*` and add an additional claim of `job_workflow_ref:ORG_NAME/REPO_NAME` pointing to the reusable workflow.

e.g.

```terraform
oidc_bindings = [
  {
    audience: '...',
    vault_role_name: '...',
    bound_subject: "repo:digitalocean/*",
    vault_policies: ['...'],
    user_claim: '...',
    additional_claims: [
      {
        job_workflow_ref: 'digitalocean/oidc-example/.github/workflows/deployment.yml@v1',
      }
    ],
  },
]
```

#### oidc_bindings.ttl

You can also specify a custom `ttl` per role binding if you wish to customize beyond the [`default_ttl`](#default_ttl) variable.
This must be a number of seconds.

### default_ttl

**Optional**

The default incremental time-to-live for generated tokens, in seconds.
Since most uses of [`hashicorp/vault-action`](https://github.com/hashicorp/vault-action) authenticate & retrieve secrets
in one step during a CI pipeline, the default for this variable is set to **5 minutes**.

If you wish to customize the TTL for all roles, modify this variable.
You can also specify individual TTL requirements on individual roles that may have edge case needs for a different TTL.
See [`oidc_bindings.ttl`](#oidc_bindings.ttl).

### default_user_claim

**Optional**

This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client.
This will be used as the name for the Identity entity alias created from a successful login.
This means it will determine the `auth.display_name` value in Vault audit logs.

This must be a field prevent in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).

This is set to `job_workflow_ref` by default.

### oidc_auth_backend_path

**Optional**

By default, this role will generate a JWT auth backend on Vault at the path `/github-actions`.
If you wish to customize the path created by this module, modify this variable.
Do **not** include a leading `/` in the variable value (e.g. use `github-actions` not `/github-actions`).

At this time, this module expects to create and manage the JWT backend leveraged for GitHub OIDC auth.
You cannot pass in a Terraform reference to an existing backend.

### github_identity_provider

**Optional**

By default, this role will communicate with github.com for an OIDC JWT (`https://token.actions.githubusercontent.com`).

If you are an Enterprise Cloud customer, you should configure a [unique token URL](https://docs.github.com/en/enterprise-cloud@latest/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#switching-to-a-unique-token-url) and set this variable to your unique token URL.

`https://token.actions.githubusercontent.com/<enterpriseSlug>`

If you run GitHub Enterprise Server, you will need to configure your instance of GitHub as the identity provider and should modify this variable.
This requires GitHub Enterprise Server version 3.5 or higher.

The format is: `https://HOSTNAME/_services/token`.

See <https://docs.github.com/en/enterprise-server@latest/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#adding-the-identity-provider-to-hashicorp-vault>.

### token_type

**Optional**

The type of Vault token that should be generated.
<https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_type>

Because of the short TTLs and frequent use intended for authentication via this module, this module generates a [batch token](https://developer.hashicorp.com/vault/tutorials/tokens/batch-tokens) by default.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_jwt_auth_backend.github_oidc](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend) | resource |
| [vault_jwt_auth_backend_role.github_oidc_role](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/jwt_auth_backend_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oidc_bindings"></a> [oidc\_bindings](#input\_oidc\_bindings) | A list of OIDC JWT bindings between GitHub repos and Vault roles. For each entry, you must include:<br><br>  `audience`: By default, this must be the URL of the repository owner (e.g. `https://github.com/digitalocean`). This can be customized with the `jwtGithubAudience` parameter in [hashicorp/vault-action](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#requesting-the-access-token) . This is the bound audience (`aud`) field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) .<br><br>  `vault_role_name`: The name of the Vault role to generate under the OIDC auth backend.<br><br>  `bound_subject`: This is what is set in the `sub` field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . The bound subject can be constructed from various filters, such as a branch, tag, or specific [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) . See [GitHub's documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) for examples.<br><br>  `vault_policies`: A list of Vault policies you wish to grant to the generated token.<br><br>  `user_claim`: **Optional**. This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Defaults to the `default_user_claim` variable if not provided. Consider the impact on [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows#how-the-token-works-with-reusable-workflows) if you are thinking of changing this value from the default.<br><br>  `additional_claims`: **Optional**. Any additional `bound_claims` to configure for this role. Claim keys must match a value in [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Do not use this field for the `sub` claim. Use the `bound_subject` parameter instead.<br><br>  `ttl`: **Optional**. The default incremental time-to-live for the generated token, in seconds. Defaults to the `default_ttl` value but can be individually specified per binding with this value. | <pre>list(object({<br>    audience          = string,<br>    vault_role_name   = string,<br>    bound_subject     = string,<br>    vault_policies    = set(string),<br>    user_claim        = optional(string),<br>    additional_claims = optional(map(string)),<br>    ttl               = optional(number),<br>  }))</pre> | n/a | yes |
| <a name="input_default_ttl"></a> [default\_ttl](#input\_default\_ttl) | The default incremental time-to-live for generated tokens, in seconds. | `number` | `300` | no |
| <a name="input_default_user_claim"></a> [default\_user\_claim](#input\_default\_user\_claim) | This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Consider the impact on [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows#how-the-token-works-with-reusable-workflows) if you are thinking of changing this value from the default. | `string` | `"job_workflow_ref"` | no |
| <a name="input_github_identity_provider"></a> [github\_identity\_provider](#input\_github\_identity\_provider) | The JWT authentication URL used for the GitHub OIDC trust configuration. If you are an Enteprise Cloud account, you should configure a [unique token URL](https://docs.github.com/en/enterprise-cloud@latest/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#switching-to-a-unique-token-url) and set the result on this variable. If you are an Enterprise Server organization, you should provide a URL in the format: `https://HOSTNAME/_services/token`. This requires GitHub Enterprise Server version 3.5 or higher. See <https://docs.github.com/en/enterprise-server@latest/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#adding-the-identity-provider-to-hashicorp-vault>. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_oidc_auth_backend_path"></a> [oidc\_auth\_backend\_path](#input\_oidc\_auth\_backend\_path) | The path to mount the OIDC auth backend. | `string` | `"github-actions"` | no |
| <a name="input_token_type"></a> [token\_type](#input\_token\_type) | The type of token to generate. This can be either `batch` or `service`. See <https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_type> for more information. | `string` | `"batch"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_backend_path"></a> [auth\_backend\_path](#output\_auth\_backend\_path) | The path of the generated auth method. Use with a `vault_auth_backend` data source to retrieve any needed attributes from this resource. |
| <a name="output_oidc_bindings_names"></a> [oidc\_bindings\_names](#output\_oidc\_bindings\_names) | The Vault role names generated for each OIDC binding provided. This is a reflection of the `vault_role_name` value of each item in `oidc-bindings`. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Authors

This module is maintained by [Ari Kalfus](https://github.com/artis3n) with help from [these excellent contributors](https://github.com/digitalocean/terraform-vault-github-oidc/graphs/contributors).

# License

Licensed under Apache 2.0. See [LICENSE](LICENSE) for full details.
