# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export BASH_SILENCE_DEPRECATION_WARNING=1

### GOLANG ###############################################
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH=$PATH:$GOBIN

### CIRCLE CI #############################################
export CIRCLE_TOKEN=

### DATADOG ###############################################
export DATADOG_API_KEY=
export DATADOG_APPLICATION_KEY=

### VAULT #################################################
export VAULT_ADDR=

### ACYL ##################################################
export ACYL_HOOK=
export ACYL_TOKEN=

### GITHUB ################################################
export GITHUB_TOKEN=
export HOMEBREW_GITHUB_API_TOKEN=

### SLACK #################################################
export SLACK_API_TOKEN=

### DOCKER ################################################
export DOCKER_USERNAME=
export DOCKER_EMAIL=
export DOCKER_PASSWORD=
export DOCKER_REGISTRY_SERVER=

### JENKINS ###############################################
export JENKINS_TOKEN=
export JENKINS_USER=

### AWS ###################################################
export AWS_DEFAULT_REGION=
export AWS_PROFILE=
export AWS_ACCESS_ID=
export AWS_ACCESS_KEY=

### TERRAFORM ENTERPRISE ##################################
export ATLAS_TOKEN=

### FASTLY ################################################
export FASTLY_API_TOKEN="PERSONAL TOKEN"
# FASTLY GATEKEEPER #
export FASTLY_TOKEN="GET FROM VAULT"

### SPOT ##################################################
export SPOTINST_TOKEN=
export SPOTINST_ACCOUNT_DEV=
export SPOTINST_ACCOUNT=

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
