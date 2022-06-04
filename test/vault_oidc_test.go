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

	// Test the token access
	secret, err := vaultClient.Logical().Read("secret/data/main/secret")
	if err != nil {
		log.Fatalf("::error file=test/vault_oidc_test.go,line=79::Unable to read secret: %v", err)
	}
	rawData, ok := secret.Data["data"].(map[string]interface{})
	if !ok {
		log.Fatalf("::error file=test/vault_oidc_test.go,line=84::Data type assertion failed: %T %#v", secret.Data["data"], secret.Data["data"])
	}
	dataString, err := json.Marshal(rawData)
	if err != nil {
		log.Fatalf("::error file=test/vault_oidc_test.go,line=89::Failed to marshal data: %v", err)
	}
	assert.JSONEq(suite.T(), data, string(dataString))
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
		log.Fatalf("::error file=test/vault_oidc_test.go,line=98::unable to initialize Vault client: %v", err)
	}
	client.SetToken("dovaultrootpass")

	return client
}
