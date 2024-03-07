provider "google" {
  #credentials =  file("gcp-credentials.json")
  project     = "zinc-strategy-393412"
  region      = "us-central1"
}

terraform {
  backend "gcs" {    
    bucket  = "mon_bucket_for_terraform"
    prefix  = "MonBackend"
  }
}


variable "db_password" {
  description = "Mot de passe pour la base de données MySQL"
  type        = string
}

resource "google_sql_database_instance" "mansours" {
  name             = "mansours"
  database_version = "MYSQL_5_7"
  region           = "us-central1"
  deletion_protection = "false"
  settings {
    tier = "db-f1-micro"   

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }


  }
  
}

resource "google_sql_database" "test" {
  name     = "test"
  instance = google_sql_database_instance.mansours.name
}

resource "google_sql_user" "mansour" {
  name     = "mansour"
  instance = google_sql_database_instance.mansours.name
  password = var.db_password
}

resource "google_container_cluster" "mon_cluster" {
  name     = "mon-cluster"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  lifecycle {
    ignore_changes = [node_config]  # Ignorer les modifications dans le bloc node_config
  }

  node_config {
    machine_type = "e2-micro"  # Type de machine le moins cher
    disk_size_gb = 10   

    metadata = {
      disable-node-deletion = "true"
    }
  } 

}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  cluster    = google_container_cluster.mon_cluster.id
  node_count = 1

  node_locations = ["us-central1-a"]  # Spécifiez la ou les zones que vous souhaitez utiliser

  #lifecycle {
  #  ignore_changes = [node_config]  # Ignorer les modifications dans le bloc node_config
  #}

  node_config {
    preemptible  = true
    machine_type = "e2-micro"

#metadata = {
#      disable-node-deletion = "true"
#    }

  }
}


################ DashBoard Part ###################

resource "google_monitoring_dashboard" "dashboard_soutenance" {
  dashboard_json = <<EOF
{
  "displayName": "Soutenance",
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Widget 1",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"kubernetes.io/container/cpu/usage_rate\"",
                "aggregation": {
                  "perSeriesAligner": "ALIGN_RATE"
                }
              },
              "unitOverride": "1"
            },
            "plotType": "LINE"
          }],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "text": {
          "content": "Widget 2",
          "format": "MARKDOWN"
        }
      },
      {
        "title": "Widget 3",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"kubernetes.io/container/memory/usage\"",
                "aggregation": {
                  "perSeriesAligner": "ALIGN_RATE"
                }
              },
              "unitOverride": "1"
            },
            "plotType": "STACKED_BAR"
          }],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      }
    ]
  }
}
EOF
}





















output "database_ip" {
  value = google_sql_database_instance.mansours.ip_address[0].ip_address
}
