resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-${var.env}"
  subnet_ids = var.subnets

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sng" })
}


resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "redis"
    from_port        = var.port_no
    to_port          = var.port_no
    protocol         = "tcp"
    cidr_blocks      = var.allow_db_cidr
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sg" })
  }

resource "aws_docdb_cluster_parameter_group" "main" {
  family      = "redis6.x"
  name        = "${var.name}-${var.env}-pg"
  description = "${var.name}-${var.env}-pg"

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-pg" })

}

resource "aws_elasticache_replication_group" "example" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["us-west-2a", "us-west-2b"]
  replication_group_id        = "${var.name}-${var.env}-elasticache"
  description                 = "${var.name}-${var.env}-elasticache"
  node_type                   = "var.node_type"
  num_node_groups             = "var.num_node_groups"
  parameter_group_name        = "aws_elasticache_parameter_group.main.name"
  replicas_per_node_group = var.replicas_per_node_group
  vpc_security_group_ids          = [aws_security_group.main.id]
  port                        = 6379
  subnet_group_name            = aws_elasticache_subnet_group.main.name
}