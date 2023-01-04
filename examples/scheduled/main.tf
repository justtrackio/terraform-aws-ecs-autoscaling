module "example" {
  source = "../.."

  namespace      = "ns"
  environment    = "env"
  stage          = "st"
  name           = "nm"
  aws_account_id = "123456789101"
  cluster_name   = "clusterName"
  service_name   = "serviceName"

  schedule = [
    {
      schedule     = "cron(0 0 * * ? *)"
      min_capacity = 2
      max_capacity = 10
    },
    {
      schedule     = "cron(45 10 * * ? *)"
      min_capacity = 3
      max_capacity = 12
    }
  ]
}
