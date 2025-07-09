# RDS CPU 모니터링
module "rds_cpu_monitoring" {
  source              = "./modules/monitoring"
  alarm_name          = "${var.service_name}-RDS-CPU-High"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  sns_topic_name      = "${var.service_name}-rds-alerts"
  email_addresses     = local.alert_emails
  action_description  = "쿼리 튜닝 및 불필요한 프로세스 확인, 인스턴스 타입 업그레이드 검토, 애플리케이션 부하 분산 검토"
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }
  tags = {
    Name        = "${var.service_name}-RDS-Monitoring"
    Environment = var.environment
  }
}

# RDS 커넥션 수 모니터링
module "rds_connection_monitoring" {
  source              = "./modules/monitoring"
  alarm_name          = "${var.service_name}-RDS-Connection-High"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  sns_topic_name      = "${var.service_name}-rds-alerts"
  email_addresses     = local.alert_emails
  action_description  = "커넥션 풀링 확인, 커넥션 제한 조정"
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }
  tags = {
    Name        = "${var.service_name}-RDS-Monitoring"
    Environment = var.environment
  }
}

# RDS 스토리지 모니터링
module "rds_storage_monitoring" {
  source              = "./modules/monitoring"
  alarm_name          = "${var.service_name}-RDS-FreeStorage-Low"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  threshold           = 10737418240 # 10GB in bytes
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  sns_topic_name      = "${var.service_name}-rds-alerts"
  email_addresses     = local.alert_emails
  action_description  = "디스크 자동 확장 확인, 불필요한 데이터 제거"
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }
  tags = {
    Name        = "${var.service_name}-RDS-Monitoring"
    Environment = var.environment
  }
}

# RDS 읽기 지연 모니터링
module "rds_read_latency_monitoring" {
  source              = "./modules/monitoring"
  alarm_name          = "${var.service_name}-RDS-ReadLatency-High"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  sns_topic_name      = "${var.service_name}-rds-alerts"
  email_addresses     = local.alert_emails
  action_description  = "쿼리 인덱스 확인, 읽기 레플리카 고려"
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }
  tags = {
    Name        = "${var.service_name}-RDS-Monitoring"
    Environment = var.environment
  }
}

# RDS 쓰기 지연 모니터링
module "rds_write_latency_monitoring" {
  source              = "./modules/monitoring"
  alarm_name          = "${var.service_name}-RDS-WriteLatency-High"
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  sns_topic_name      = "${var.service_name}-rds-alerts"
  email_addresses     = local.alert_emails
  action_description  = "스토리지 성능 확인, 쓰기 병목 분석"
  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_id
  }
  tags = {
    Name        = "${var.service_name}-RDS-Monitoring"
    Environment = var.environment
  }
}
