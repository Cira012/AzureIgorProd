location            = "westeurope"
resource_group_name = "rg-prod"
dns_zone_name       = "terraform-igor-demo-test.com"
dns_record_name     = "@"
email               = "ops@mycompany.com"
ssh_key_bits        = 4096
# Write SSH keys straight to C:\
ssh_key_path        = "C:/Users/flitd/.ssh/terraform_key.pem"
ssh_public_key_path = "C:/Users/flitd/.ssh/terraform_key.pub"
