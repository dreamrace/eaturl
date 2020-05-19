resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "ephemeral-1"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_default_security_group.default.id]
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-sn-group"
  subnet_ids = data.aws_subnet_ids.target.ids
}

resource "aws_ssm_parameter" "redis" {
  name  = "${var.prefix}.redis"
  type  = "String"
  value = "${aws_elasticache_cluster.redis.cache_nodes.0.address}:6379"
}
