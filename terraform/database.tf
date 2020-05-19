resource "random_password" "postgresql" {
  length  = 12
  special = false
}

data "aws_availability_zones" "postgresql_az" {

}

resource "aws_rds_cluster_instance" "postgresql" {
  count                   = 2
  identifier              = "persistent-1-${count.index}"
  cluster_identifier      = aws_rds_cluster.postgresql.id
  instance_class          = "db.t3.medium"
  engine                  = "aurora-postgresql"
  engine_version          = "11.6"
  db_parameter_group_name = "default.aurora-postgresql11"
  publicly_accessible     = true
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier = "persistent-1"
  engine             = "aurora-postgresql"
  # availability_zones              = local.selected_availability_zones
  database_name                   = "postgres"
  master_username                 = "postgres"
  master_password                 = random_password.postgresql.result
  skip_final_snapshot             = true
  engine_version                  = "11.6"
  db_cluster_parameter_group_name = "default.aurora-postgresql11"
  vpc_security_group_ids          = [aws_security_group.allow_localaccess.id, aws_default_security_group.default.id]
}

resource "aws_ssm_parameter" "postgresql_pass" {
  name  = "${var.prefix}.postgresql.pass"
  type  = "String"
  value = random_password.postgresql.result
}

resource "aws_ssm_parameter" "postgresql" {
  name  = "${var.prefix}.postgresql.endpoint"
  type  = "String"
  value = "${aws_rds_cluster.postgresql.endpoint}:5432"
}
