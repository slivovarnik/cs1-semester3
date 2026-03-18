resource "aws_db_subnet_group" "main" {
  name = "${var.project}-db-subnet-group"

  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]

  tags = {
    Name    = "${var.project}-db-subnet-group"
    Project = var.project
  }
}

resource "aws_rds_cluster" "aurora_pg" {
  cluster_identifier = "${var.project}-aurora-pg"
  engine             = "aurora-postgresql"

  database_name   = "appdb"
  master_username = "postgres"
  master_password = "RosiCS1_DB!"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name    = "${var.project}-aurora-pg"
    Project = var.project
    Role    = "cluster"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  identifier           = "${var.project}-aurora-writer"
  cluster_identifier   = aws_rds_cluster.aurora_pg.id
  instance_class       = "db.t4g.medium"
  engine               = aws_rds_cluster.aurora_pg.engine
  engine_version       = aws_rds_cluster.aurora_pg.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name    = "${var.project}-aurora-writer"
    Project = var.project
    Role    = "writer"
  }
}

resource "aws_rds_cluster_instance" "reader" {
  identifier           = "${var.project}-aurora-reader"
  cluster_identifier   = aws_rds_cluster.aurora_pg.id
  instance_class       = "db.t4g.medium"
  engine               = aws_rds_cluster.aurora_pg.engine
  engine_version       = aws_rds_cluster.aurora_pg.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.main.name

  tags = {
    Name    = "${var.project}-aurora-reader"
    Project = var.project
    Role    = "reader"
  }
}