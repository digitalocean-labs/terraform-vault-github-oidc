# Terraform Module: Hashicorp Vault GitHub OIDC <!-- omit in toc -->

Terraform module to configure Vault for GitHub OIDC authentication from Action runners.

OIDC authentication allows us to bind GitHub repositories (and subcomponents of a repository, such as a branch, ref, or environment)
to a Vault role without needing to manage actual credentials that require a lifecycle system, integration into repo-level
GitHub Secrets, or other organizational glue.

Reference documents that help with understanding the process:
- <https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault>
- <https://medium.com/hashicorp-engineering/push-button-security-for-your-github-actions-d4fffde1df20>

Once OIDC authentication is configured on your Vault server via this module, a GitHub repository can leverage
[hashicorp/vault-action](https://github.com/hashicorp/vault-action) to retrieve secrets from Vault with GitHub OIDC authentication.
No credential management needed!

```yml
- name: Import Secrets
  uses: hashicorp/vault-action@v2.4.0
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

Tutorial/example repo: <https://github.com/artis3n/github-oidc-vault-example>.

- [Usage](#usage)
  - [Examples](#examples)
  - [Variables](#variables)
    - [oidc_bindings](#oidc_bindings)
      - [oidc_bindings.audience](#oidc_bindingsaudience)
      - [oidc_bindings.vault_role_name](#oidc_bindingsvault_role_name)
      - [oidc_bindings.bound_subject](#oidc_bindingsbound_subject)
      - [oidc_bindings.vault_policies](#oidc_bindingsvault_policies)
      - [oidc_bindings.user_claim](#oidc_bindingsuser_claim)
      - [oidc_bindings.additional_claims](#oidc_bindingsadditional_claims)
      - [oidc_bindings.ttl](#oidc_bindingsttl)
    - [default_ttl](#default_ttl)
    - [oidc_auth_backend_path](#oidc_auth_backend_path)
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

| :exclamation: Note: This module uses the experimental Terraform feature [`module_variable_optional_attrs`](https://www.terraform.io/language/expressions/type-constraints#experimental-optional-object-type-attributes). |
|---|

You will need to opt-in to this experiment in your `terraform` block:

```tf
terraform {
  experiments = [module_variable_optional_attrs]
}
```

## Examples

You can find several examples leveraging this module under `examples/`:
- [Basic usage](/examples/simple-repo)
- [Leveraging JSON files for distributed organization of repo bindings](/examples/json-files)
- [Adding custom additional claims per OIDC binding](/examples/additional-claims)

Basic example - one repo, separating secrets access by nonprod and prod pipelines:

```tf
module "github-vault-oidc" {
  source = "digitalocean/github-oidc/vault"
  version = "~> 1.0.0"

  oidc_bindings = [
    {
      audience : "https://github.com/artis3n",
      vault_role_name : "oidc-test",
      bound_subject : "repo:artis3n/github-oidc-vault-example:environment:nonprod",
      vault_policies : [
        "oidc-policy"
      ],
    },
    {
      audience : "https://github.com/artis3n",
      vault_role_name : "oidc-prod-test",
      bound_subject : "repo:artis3n/github-oidc-vault-example:ref:refs/heads/main",
      vault_policies : [
        "oidc-policy"
      ],
    },
  ]
}
```

Note: see the full [Basic usage](/examples/simple-repo) example to see how to leverage `vault_policy` resources for the `oidc_bindings.vault_policies` array.

## Variables

### oidc_bindings

This input variable must be a list of objects containing the following structure:

```tf
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

```tf
oidc_bindings = [
  {
    audience: '',
    vault_role_name: '',
    bound_subject: '',
    vault_policies: [''],
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
hashicorp/vault-action.

#### oidc_bindings.vault_role_name

The `vault_role_name` must be the name of the Vault role you wish to create on the JWT auth backend.
Each Vault role should be configured for one repo subject - using the same Vault role with different configurations in the rest of
the parameters will cause this module to fail.
This is because you would silently overwrite the role configuration.

You may want to create multiple Vault roles for a single GitHub repository, e.g. a nonprod CI workflow that needs access
to CI secrets, and a deployment workflow that publishes a release that needs production secrets.

#### oidc_bindings.bound_subject

The `bound_subject` must be the `sub` field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).
The bound subject can be constructed from various filters, such as a branch, tag, or specific [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).
See [GitHub's documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) for examples.

#### oidc_bindings.vault_policies

`vault_policies` must be a list of Vault policy strings to grant to the `vault_role_name` Vault role being configured.
This can also come from a [`vault_policy` resource](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy#name).

#### oidc_bindings.user_claim

**Optional**

The `user_claim` is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client.
This will be used as the name for the Identity entity alias created due to a successful login.
This must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).
Defaults to the `default_user_claim` variable if not provided.

#### oidc_bindings.additional_claims

**Optional**

`additional_claims` must be a list of any additional claims you would like to enforce in the Vault role binding.
Each `key` must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token).

For example, to leverage [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows)
with OIDC, you may set your `bound_subject` to `repo:ORG_NAME/*` and add an additional claim of `job_workflow_ref:ORG_NAME/REPO_NAME`.

e.g.

```tf
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

You can also specify a custom `ttl` per role binding if you wish to customize beyond the `default_ttl`.
This must be a number of seconds.

### default_ttl

**Optional**

The default incremental time-to-live for generated tokens, in seconds.
Since most uses of [`hashicorp/vault-action`](https://github.com/hashicorp/vault-action) authenticate + retrieve secrets
in one step during a CI pipeline, the default for this variable is set to 60 seconds.
If you wish to customize the TTL for all roles, modify this variable.
You can also specify individual TTL requirements on individual role bindings.
See [`oidc_bindings.ttl`](#ttl).

### oidc_auth_backend_path

**Optional**

By default, this role will generate a JWT auth backend on Vault at the path `/github-actions`.
If you wish to customize the path created by this module, modify this variable.
Do **not** include a leading `/` in the variable content.

At this time, this module expects to create and manage the JWT backend leveraged for GitHub OIDC auth.
You cannot pass in a Terraform reference to an existing backend.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 3.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.3.1 |

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
| <a name="input_default_ttl"></a> [default\_ttl](#input\_default\_ttl) | The default incremental time-to-live for generated tokens, in seconds. | `number` | `60` | no |
| <a name="input_default_user_claim"></a> [default\_user\_claim](#input\_default\_user\_claim) | This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Consider the impact on [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows#how-the-token-works-with-reusable-workflows) if you are thinking of changing this value from the default. | `string` | `"job_workflow_ref"` | no |
| <a name="input_oidc_auth_backend_path"></a> [oidc\_auth\_backend\_path](#input\_oidc\_auth\_backend\_path) | The path to mount the OIDC auth backend. | `string` | `"github-actions"` | no |

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
