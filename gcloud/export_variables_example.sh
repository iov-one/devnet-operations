# this needs to be customized according to your setup
export TF_VAR_gcloud_project=yourcompany-devnet
export GCLOUD_PLATFORM=devnet
export GOOGLE_CLOUD_KEYFILE_JSON="your_desired_path/terraform-service-account.json"
export TF_VAR_billing_account=your-billing-account
export TF_STATE="your_desired_path/terraform.tfstate"
export TF_PLAN="your_desired_path/plan-1.0.plan"
export EMAILS="account1@example.com;account2@example.com;account3@example.com"
export ADMIN_EMAILS="account1@example.com;account2@example.com" # this is a subset of EMAILS for admin access