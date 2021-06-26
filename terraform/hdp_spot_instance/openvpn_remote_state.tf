// usage ${data.terraform_remote_state.openvpn_remote_state.outputs.openvpn_elastic_ip}
data "terraform_remote_state" "openvpn_remote_state" {
  backend = "s3"
  config = {
    bucket  = "terraform-hadoop-openvpn"
    key     = "sandbox-openvpn/terraform.tfstate"
    region  = "us-east-1"
  }
}
