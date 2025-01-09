# provider.tf
terraform {
  required_version = ">= 0.13"
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine",
      version = ">= 1.20.0"
    }
  }
}
provider "flexibleengine" {
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  }
module "vpc_subnet_uat" {
  source="./VPC_SUBNET"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  vpc_name= "UAT-TEST-FR"
  subnet_name= "UAT-eu-west-0-mgmt"

}
module "vpc_subnet_dev" {
  source="./VPC_SUBNET"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  vpc_name= "DEV-TEST-FR"
  subnet_name= "DEV-eu-west-0-mgmt"

}
module "elb_listener_ELB-Sitea-uat" {
  source="./ELB_LISTSENER"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  ELB_name= "ELB-Sitea-uat"
  Listener_name= ["Sitea-uat-443","Sitea-uat-9443"]
  vpc_id    = module.vpc_subnet_uat.vpc_id
  subnet_id=module.vpc_subnet_uat.subnet_id_openstack
  listener_protocol_v3=["HTTPS","HTTPS"]
  listener_port_v3=[443,9443]
  certificate_name=var.certificate_name
  pool_name=["Sitea-uat","Sitea-uat"]
  pool_protocol_v3=["HTTP","HTTP"]
  name_regex_ecs=["UAT-ecs-api*","UAT-ecs-api*"]
  member_port_v3= [443,9443]
}
module "elb_listener_shared_ELB-Siteb-uat" {
  source="./ELB_LISTSENER_shared"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  ELB_name= "ELB-Siteb-uat"
  Listener_name= ["Siteb-uat-443"]
  vpc_id    = module.vpc_subnet_uat.vpc_id
  subnet_id=module.vpc_subnet_uat.subnet_id_openstack
  certificate_name=var.certificate_name
  whitelist=[""]
  enable_whitelist=[false]
  listener_protocol_v2=["TERMINATED_HTTPS"]
  listener_port_v2=[443]
  pool_protocol_v2=["HTTP"]
  name_regex_ecs=["UAT-CCE-WORKERS*|DEV-CCE-WORKERS*"]
  #num_members=var.num_members
  member_port_v2=[80]
  pool_name=["Siteb-uat"]
}
module "elb_listener_shared_ELB-Sitec-uat" {
  source="./ELB_LISTSENER_shared"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  ELB_name= "ELB-Sitec-uat"
  Listener_name= ["Sitec-uat-2022","Sitec-uat-8080"]
  vpc_id    = module.vpc_subnet_uat.vpc_id
  subnet_id=module.vpc_subnet_uat.subnet_id_openstack
  certificate_name=var.certificate_name
  whitelist=["","10.2.1.0/24"]
  enable_whitelist=[false,true]
  listener_protocol_v2=["TCP","HTTP"]
  listener_port_v2=[2022,8080]
  pool_protocol_v2=["TCP","HTTP"]
  name_regex_ecs=["UAT-ecs-api*","UAT-ecs-api*"]
  #num_members=var.num_members
  member_port_v2=[22,8080]
  pool_name=["Sitec-uat","Sitec-uat"]
}
module "elb_listener_ELB-Sitea-dev" {
  source="./ELB_LISTSENER"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  ELB_name= "ELB-Sitea-dev"
  Listener_name= ["Sitea-dev-443","Sitea-dev-9443"]
  vpc_id    = module.vpc_subnet_dev.vpc_id
  subnet_id=module.vpc_subnet_dev.subnet_id_openstack
  listener_protocol_v3=["HTTPS","HTTPS"]
  listener_port_v3=[443,9443]
  certificate_name=var.certificate_name
  pool_protocol_v3=["HTTP","HTTP"]
  name_regex_ecs=["DEV-ecs-api*","DEV-ecs-api*"]
  member_port_v3= [443,9443]
  pool_name=["Sitea-dev","Sitea-dev"]
}
module "elb_listener_shared_ELB-Siteb-dev" {
  source="./ELB_LISTSENER_shared"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  ELB_name= "ELB-Siteb-dev"
  Listener_name= ["Siteb-dev-443"]
  vpc_id    = module.vpc_subnet_dev.vpc_id
  subnet_id=module.vpc_subnet_dev.subnet_id_openstack
  certificate_name=var.certificate_name
  whitelist=[""]
  enable_whitelist=[false]
  listener_protocol_v2=["TERMINATED_HTTPS"]
  listener_port_v2=[443]
  pool_protocol_v2=["HTTP"]
  name_regex_ecs=["DEV-CCE-WORKERS*"]
  #num_members=var.num_members
  member_port_v2=[80]
  pool_name = ["Siteb-dev"]
}
module "elb_listener_shared_ELB-Sitec-dev" {
  source="./ELB_LISTSENER_shared"
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  ELB_name= "ELB-Sitec-dev"
  Listener_name= ["Sitec-dev-2022","Sitec-dev-8080"]
  vpc_id    = module.vpc_subnet_dev.vpc_id
  subnet_id=module.vpc_subnet_dev.subnet_id_openstack
  certificate_name=var.certificate_name
  whitelist=["","10.3.1.0/24"]
  enable_whitelist=[false,true]
  listener_protocol_v2=["TCP","HTTP"]
  listener_port_v2=[2022,8080]
  pool_protocol_v2=["TCP","HTTP"]
  name_regex_ecs=["DEV-ecs-api*","DEV-ecs-api*"]
  #num_members=var.num_members
  member_port_v2=[22,8080]
  pool_name = ["Sitec-dev","Sitec-dev"]

}