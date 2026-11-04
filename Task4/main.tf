terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.120"
    }
  }
}

provider "yandex" {
  token                    = var.yc_token != "" ? var.yc_token : null
  service_account_key_file = var.service_account_key_file != "" ? var.service_account_key_file : null
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.yc_zone
}

resource "yandex_vpc_network" "future20" {
  name        = var.network_name
  description = "Future 2.0 platform network"
}

resource "yandex_vpc_gateway" "nat" {
  name = "${var.network_name}-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat" {
  name       = "${var.network_name}-rt-nat"
  network_id = yandex_vpc_network.future20.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "platform" {
  name           = "${var.network_name}-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.future20.id
  v4_cidr_blocks = [var.subnet_cidr]
  route_table_id = yandex_vpc_route_table.nat.id
}

resource "yandex_vpc_security_group" "platform" {
  name       = "${var.network_name}-sg"
  network_id = yandex_vpc_network.future20.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = [var.ssh_cidr]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "app_data" {
  name     = "${var.vm_name}-data"
  type     = var.data_disk_type
  zone     = var.yc_zone
  size     = var.data_disk_size_gb
}

resource "yandex_compute_instance" "platform" {
  name        = var.vm_name
  platform_id = var.vm_platform_id
  zone        = var.yc_zone

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory_gb
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.boot_disk_size_gb
      type     = var.boot_disk_type
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.app_data.id
    auto_delete = false
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.platform.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.platform.id]
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }
}
