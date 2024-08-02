provider "aws" {
  region = "ap-northeast-2"
}

data "aws_elasticache_subnet_group" "example" {
  name = "name of the subnet group  "
}
data "aws_security_group" "selected" {
  name = "name of the security group"
}

resource "aws_iam_role" "elasticache_iam_auth_app" {
  name               = "elasticache-iam-auth-app"
  assume_role_policy = file("trust-policy.json")
}

resource "aws_iam_policy" "elasticache_allow_all" {
  name        = "elasticache-allow-all"
  description = "Policy to allow ElastiCache access"
  policy      = file("policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.elasticache_iam_auth_app.name
  policy_arn = aws_iam_policy.elasticache_allow_all.arn
}

resource "aws_elasticache_user" "iam_user" {
  user_id       = "redis-iam-user"
  user_name     = "redis-iam-user"
  engine        = "REDIS"
  access_string = "on ~* +@all"
  authentication_mode {
    type = "iam"
  }
}

resource "aws_elasticache_user_group" "iam_user_group" {
  user_group_id = "redis-iam-user-group-01"
  engine        = "REDIS"
  user_ids      = ["default", aws_elasticache_user.iam_user.user_id]
}

resource "aws_elasticache_replication_group" "example" {
  automatic_failover_enabled  = false
  preferred_cache_cluster_azs = ["ap-northeast-2a"]
  replication_group_id        = "redis-iam-test"
  description                 = "redis cluster for iam testing"
  node_type                   = "cache.t2.micro"
  num_cache_clusters          = 1
  parameter_group_name        = "default.redis7"
  subnet_group_name    = data.aws_elasticache_subnet_group.example.id
  security_group_ids   = [data.aws_security_group.selected.id]
  user_group_ids  = [aws_elasticache_user_group.iam_user_group.user_group_id]
  transit_encryption_enabled = true
}