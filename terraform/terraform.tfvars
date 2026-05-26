region            = "eu-central-1"
project           = "case-study"
workload_vpc_cidr = "10.20.0.0/16"
data_vpc_cidr     = "10.30.0.0/16"
k8s_vpc_cidr      = "10.40.0.0/16"

alert_email = "rosi.yovcheva.05@gmail.com"
db_password = "RosiCS2_DB!"

client_vpn_server_certificate_arn            = "arn:aws:acm:eu-central-1:985738120856:certificate/e5bd2859-85e6-4551-b927-bb914577d1ed"
client_vpn_client_root_certificate_chain_arn = "arn:aws:acm:eu-central-1:985738120856:certificate/3d823797-1d80-4362-8ce9-8a6b6a8503cb"
client_vpn_cidr                              = "172.16.0.0/22"

identity_store_id = ""
sso_instance_arn  = ""