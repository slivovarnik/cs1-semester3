region            = "eu-central-1"
project           = "case-study"
workload_vpc_cidr = "10.20.0.0/16"
data_vpc_cidr     = "10.30.0.0/16"

alert_email = "rosi.yovcheva.05@gmail.com"
db_password = "RosiCS2_DB!"

client_vpn_server_certificate_arn            = "arn:aws:acm:eu-central-1:536300832697:certificate/3676dce4-19e1-47c0-b140-c5a84b0bc79c"
client_vpn_client_root_certificate_chain_arn = "arn:aws:acm:eu-central-1:536300832697:certificate/0ee52711-3353-400c-8e3a-a2e7c1f7d5e7"
client_vpn_cidr                              = "172.16.0.0/22"

identity_store_id = ""
sso_instance_arn  = ""