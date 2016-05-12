.DEFAULT_GOAL := help
.PHONY: help plan apply deps

TF_SOURCE := sandbox
BUILD_DIR := .build
BUILD_TARGET := sandbox.tf
CREDENTIALS_FILE := credentials.tfvars

help:
	@echo "Builds Runnable AWS infrastructures with Terraform"
	@echo ""
	@echo "Environment Variables:"
	@echo "  TERRAFORM_ENVIRONMENT - Name of the environment for which to apply changes"
	@echo ""
	@echo "Targets:"
	@echo "  apply    Commits the plan and builds the infrastructure"
	@echo "  deps     Ensures system requirements are met to run Terraform"
	@echo "  env      Display the working environment (TERRAFORM_ENVIRONMENT)"
	@echo "  help     Displays this message"
	@echo "  plan     Builds a new Terraform plan"
	@echo ""
	@echo "For an indepth guide see: https://github.com/codenow/devops-scripts README"

env:
	@echo "Working environment: ${TERRAFORM_ENVIRONMENT}"

deps:
	@hash terraform > /dev/null 2>&1 || \
		(echo "Terraform not installed (try: brew install terraform)"; exit 1)
	@test -n "$(TERRAFORM_ENVIRONMENT)" || \
		(echo "Variable TERRAFORM_ENVIRONMENT is missing"; exit 1)
	@test -e "${CREDENTIALS_FILE}" || \
		(echo "Cannot find credentials variables, ask someone for '${CREDENTIALS_FILE}'")

compile:
	@echo "Compiling .tf files from sandbox/"
	@mkdir -p .build
	@find ${TF_SOURCE} \
		| grep -E '${TF_SOURCE}/.*[.]tf' \
		| xargs cat > ${BUILD_DIR}/${BUILD_TARGET}

apply: compile deps
	terraform apply \
		-var-file="${CREDENTIALS_FILE}" \
		-var-file="environment/${TERRAFORM_ENVIRONMENT}.tfvars" \
		${BUILD_DIR}/

destroy:
	terraform destroy \
		-var-file="${CREDENTIALS_FILE}" \
		-var-file="environment/${TERRAFORM_ENVIRONMENT}.tfvars" \
		${BUILD_DIR}/

plan: compile deps
	terraform plan \
		-var-file="${CREDENTIALS_FILE}" \
		-var-file="environment/${TERRAFORM_ENVIRONMENT}.tfvars" \
		${BUILD_DIR}/
