module "example" {
  source = "../.."

  namespace      = "ns"
  environment    = "env"
  stage          = "st"
  name           = "nm"
  aws_account_id = "123456789101"
  cluster_name   = "clusterName"
  service_name   = "serviceName"
}
