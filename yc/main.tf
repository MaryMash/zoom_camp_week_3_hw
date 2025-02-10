terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_storage_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name

  lifecycle_rule {
    id      = "cleanupoldlogs"
    enabled = true
    expiration {
      days = 1
    }
  }
}

resource "yandex_vpc_network" "cluster-net" { name = "cluster-net" }

resource "yandex_vpc_subnet" "cluster-subnet-a" {
  name           = "cluster-subnet-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.cluster-net.id
  v4_cidr_blocks = ["172.16.1.0/24"]
}

resource "yandex_mdb_clickhouse_cluster" "mych" {
  name               = "zoomcapm-2025-ch"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.cluster-net.id

  clickhouse {
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = 16
    }
  }

  host {
    type      = "CLICKHOUSE"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.cluster-subnet-a.id
    assign_public_ip = true
  }

  database {
    name = "taxi-data"
  }

  user {
    name     = "admin"
    password = var.clickhouse_password
    permission {
      database_name = "taxi-data"
    }
  }
}

