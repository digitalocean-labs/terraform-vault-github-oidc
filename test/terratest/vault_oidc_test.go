package test

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"testing"

	httphelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	vault "github.com/hashicorp/vault/api"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
)

type TestSuite struct {
	suite.Suite
	PrepareServerOptions *terraform.Options
}

const (
	CD_SECRET_PATH        = "secret/data/main/secret"
	CI_OIDC_SUBJECT       = "repo:digitalocean/terraform-vault-github-oidc:environment:E2E"
	CI_SECRET_PATH        = "secret/data/foo/bar"
	CI_TOKEN_POLICY       = "oidc-example"
	OIDC_AUDIENCE         = "https://github.com/digitalocean"
	OIDC_BACKEND_CONFIG   = "auth/github-actions/config"
	OIDC_CI_ROLE_PATH     = "auth/github-actions/role/oidc-ci-test"
	OIDC_GITHUB_TOKEN_URL = "https://token.actions.githubusercontent.com"
	TOKEN_TTL             = "300"
)

func (suite *TestSuite) SetupSuite() {
	prepareOptions := terraform.WithDefaultRetryableErrors(suite.T(), &terraform.Options{
		TerraformDir: "./prepare-server",
	})
	terraform.InitAndApply(suite.T(), prepareOptions)
	suite.PrepareServerOptions = prepareOptions
}

func (suite *TestSuite) TearDownSuite() {
	terraform.Destroy(suite.T(), suite.PrepareServerOptions)
}

func (suite *TestSuite) TestServerConfiguration() {
	output := terraform.Output(suite.T(), suite.PrepareServerOptions, "vault_ip")
	vaultIp := net.ParseIP(output)
	assert.NotNil(suite.T(), vaultIp)

	vaultAddress := fmt.Sprintf("https://%s:8200/ui/", vaultIp.String())
	tlsConfig := &tls.Config{InsecureSkipVerify: true}
	statusCode, _ := httphelper.HttpGet(suite.T(), vaultAddress, tlsConfig)
	assert.Equal(suite.T(), statusCode, 200)
}

func (suite *TestSuite) TestSeedVaultConfiguration() {
	seedVaultOptions := terraform.WithDefaultRetryableErrors(suite.T(), &terraform.Options{
		TerraformDir: "./configure-vault",
	})
	defer terraform.Destroy(suite.T(), seedVaultOptions)
	terraform.InitAndApply(suite.T(), seedVaultOptions)

	output := terraform.OutputJson(suite.T(), seedVaultOptions, "ci_secret")
	data := `{"fi": "fofum"}`

	assert.JSONEq(suite.T(), output, data)
}

// All the OIDC tests are listed out in this function to avoid constantly
// building and destroying the Terraform suite.
func (suite *TestSuite) TestOIDCVaultConfiguration() {
	seedVaultOptions := terraform.WithDefaultRetryableErrors(suite.T(), &terraform.Options{
		TerraformDir: "./configure-vault",
	})
	defer terraform.Destroy(suite.T(), seedVaultOptions)
	terraform.InitAndApply(suite.T(), seedVaultOptions)

	oidcVaultOptions := terraform.WithDefaultRetryableErrors(suite.T(), &terraform.Options{
		TerraformDir: "./configure-oidc",
	})
	defer terraform.Destroy(suite.T(), oidcVaultOptions)
	terraform.InitAndApply(suite.T(), oidcVaultOptions)

	output := terraform.OutputJson(suite.T(), seedVaultOptions, "cd_secret")
	data := `{"cdsecret": "only accessible from the main branch"}`
	assert.JSONEq(suite.T(), output, data)
	ipOutput := terraform.Output(suite.T(), suite.PrepareServerOptions, "vault_ip")
	vaultClient := configureVaultClient(ipOutput)

	// Test what we just validated to ensure we configured the
	// client library correctly
	secret, err := vaultClient.Logical().Read(CD_SECRET_PATH)
	if err != nil {
		log.Fatalf("Unable to read secret: %v", err)
	}
	rawData, ok := secret.Data["data"].(map[string]interface{})
	if !ok {
		log.Fatalf("Data type assertion failed: %T %#v", secret.Data["data"], secret.Data["data"])
	}
	dataString, err := json.Marshal(rawData)
	if err != nil {
		log.Fatalf("Failed to marshal data: %v", err)
	}
	assert.JSONEq(suite.T(), data, string(dataString))

	// Test the configuration of the OIDC auth backend
	authBackend, err := vaultClient.Logical().Read(OIDC_BACKEND_CONFIG)
	if err != nil {
		log.Fatalf("Unable to read auth backend data: %v", err)
	}
	boundIssuer := fmt.Sprint(authBackend.Data["bound_issuer"])
	assert.Equal(suite.T(), OIDC_GITHUB_TOKEN_URL, boundIssuer)
	oidcDiscoveryUrl := fmt.Sprint(authBackend.Data["oidc_discovery_url"])
	assert.Equal(suite.T(), OIDC_GITHUB_TOKEN_URL, oidcDiscoveryUrl)

	oidcRoleConfig, err := vaultClient.Logical().Read(OIDC_CI_ROLE_PATH)
	if err != nil {
		log.Fatalf("Unable to read OIDC role config: %v", err)
	}

	userClaim := oidcRoleConfig.Data["user_claim"]
	assert.Equal(suite.T(), "job_workflow_ref", userClaim)
	tokenTtl := oidcRoleConfig.Data["token_ttl"]
	assert.Equal(suite.T(), json.Number(TOKEN_TTL), tokenTtl)

	boundAudienceList, ok := oidcRoleConfig.Data["bound_audiences"].([]interface{})
	if !ok {
		log.Fatalf("Failed to cast bound_audiences: %T %#v", oidcRoleConfig.Data["bound_audiences"], oidcRoleConfig.Data["bound_audiences"])
	}
	assert.Equal(suite.T(), OIDC_AUDIENCE, boundAudienceList[0])

	tokenPolicyList, ok := oidcRoleConfig.Data["token_policies"].([]interface{})
	if !ok {
		log.Fatalf("Failed to cast token_policies: %T %#v", oidcRoleConfig.Data["token_policies"], oidcRoleConfig.Data["token_policies"])
	}
	assert.Equal(suite.T(), CI_TOKEN_POLICY, tokenPolicyList[0])

	rawBoundClaims, ok := oidcRoleConfig.Data["bound_claims"].(map[string]interface{})
	if !ok {
		log.Fatalf("Failed to cast bound_claims to interface map: %T %#v", oidcRoleConfig.Data["bound_claims"], oidcRoleConfig.Data["bound_claims"])
	}
	boundSubList, ok := rawBoundClaims["sub"].([]interface{})
	if !ok {
		log.Fatalf("Failed to cast bound_claims.sub to interface slice: %T %#v", rawBoundClaims["sub"], rawBoundClaims["sub"])
	}
	assert.Equal(suite.T(), CI_OIDC_SUBJECT, boundSubList[0])
}

func TestOIDCSuite(t *testing.T) {
	suite.Run(t, new(TestSuite))
}

func configureVaultClient(vaultAddr string) *vault.Client {
	config := vault.DefaultConfig()
	config.Address = fmt.Sprintf("https://%s:8200", vaultAddr)
	config.ConfigureTLS(&vault.TLSConfig{
		Insecure: true,
	})

	client, err := vault.NewClient(config)
	if err != nil {
		log.Fatalf("Unable to initialize Vault client: %v", err)
	}
	client.SetToken("dovaultrootpass")

	return client
}
