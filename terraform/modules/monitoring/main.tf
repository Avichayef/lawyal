# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/lawyal-project-eks-cluster/logs"
  retention_in_days = 30
}

# Enable EKS Control Plane Logging
# Note: This should be part of the EKS cluster resource configuration instead
# Moving this configuration to the EKS module

# CloudWatch Dashboard for EKS monitoring
resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  dashboard_name = "EKS-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", "lawyal-project-eks-cluster"],
            [".", "cluster_node_count", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EKS Node Count"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "pod_cpu_utilization", "ClusterName", "lawyal-project-eks-cluster"],
            [".", "pod_memory_utilization", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Pod Resource Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", "lawyal-project-eks-cluster"],
            [".", "node_memory_utilization", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Node Resource Utilization"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "eks-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EKS node CPU utilization"
  alarm_actions      = []  # Add SNS topic ARN here if you want notifications

  dimensions = {
    ClusterName = "lawyal-project-eks-cluster"
  }
}

resource "aws_cloudwatch_metric_alarm" "pod_memory_high" {
  alarm_name          = "eks-pod-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_memory_utilization"
  namespace           = "ContainerInsights"
  period             = "300"
  statistic          = "Average"
  threshold          = "85"
  alarm_description  = "This metric monitors pod memory utilization"
  alarm_actions      = []

  dimensions = {
    ClusterName = "lawyal-project-eks-cluster"
  }
}

# Keep the data sources and resources
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Create Kubernetes namespace for CloudWatch agent
resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }
}

# Deploy CloudWatch agent as DaemonSet (fixed resource name)
resource "kubernetes_daemonset" "cloudwatch_agent" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        name = "cloudwatch-agent"
      }
    }

    template {
      metadata {
        labels = {
          name = "cloudwatch-agent"
        }
      }

      spec {
        service_account_name = "cloudwatch-agent"
        
        container {
          name  = "cloudwatch-agent"
          image = "amazon/cloudwatch-agent:latest"

          env {
            name = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name  = "K8S_NAMESPACE"
            value = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
          }

          volume_mount {
            name       = "cwagentconfig"
            mount_path = "/etc/cwagentconfig"
          }

          volume_mount {
            name       = "rootfs"
            mount_path = "/rootfs"
            read_only  = true
          }

          volume_mount {
            name       = "dockersock"
            mount_path = "/var/run/docker.sock"
            read_only  = true
          }

          volume_mount {
            name       = "varlibdocker"
            mount_path = "/var/lib/docker"
            read_only  = true
          }

          volume_mount {
            name       = "sys"
            mount_path = "/sys"
            read_only  = true
          }

          volume_mount {
            name       = "devdisk"
            mount_path = "/dev/disk"
            read_only  = true
          }
        }

        volume {
          name = "cwagentconfig"
          config_map {
            name = "cwagentconfig"
          }
        }

        volume {
          name = "rootfs"
          host_path {
            path = "/"
          }
        }

        volume {
          name = "dockersock"
          host_path {
            path = "/var/run/docker.sock"
          }
        }

        volume {
          name = "varlibdocker"
          host_path {
            path = "/var/lib/docker"
          }
        }

        volume {
          name = "sys"
          host_path {
            path = "/sys"
          }
        }

        volume {
          name = "devdisk"
          host_path {
            path = "/dev/disk/"
          }
        }
      }
    }
  }
}

# Create ConfigMap for CloudWatch agent configuration
resource "kubernetes_config_map" "cwagentconfig" {
  metadata {
    name      = "cwagentconfig"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  data = {
    "cwagentconfig.json" = jsonencode({
      logs = {
        metrics_collected = {
          kubernetes = {
            cluster_name                = "lawyal-project-eks-cluster"
            metrics_collection_interval = 60
          }
        }
        force_flush_interval = 5
      }
    })
  }
}

# Create service account for CloudWatch agent
resource "kubernetes_service_account" "cloudwatch_agent" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.cloudwatch_agent_role_arn
    }
  }
}
