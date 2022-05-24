package test

import (
	"crypto/tls"
	"fmt"
	httphelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"net"
	"testing"
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

	output := terraform.OutputJson(suite.T(), seedVaultOptions, "seed_secret")
	data := `{"fi": "fofum"}`

	assert.JSONEq(suite.T(), output, data)
}

func TestOIDCSuite(t *testing.T) {
	suite.Run(t, new(TestSuite))
}
