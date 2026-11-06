variable "service_account_key_file" {
  description = "Path to Yandex Cloud service account authorized key JSON (preferred after 2026-06-01 OAuth change)"
  type        = string
  default     = ""
}

variable "yc_token" {
  description = "Optional legacy Yandex Cloud OAuth/IAM token (empty if using service_account_key_file)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "future20-platform"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vm_name" {
  description = "Compute instance name"
  type        = string
  default     = "future20-app"
}

variable "vm_platform_id" {
  description = "YC platform id"
  type        = string
  default     = "standard-v3"
}

variable "vm_cores" {
  description = "vCPU count"
  type        = number
  default     = 2
}

variable "vm_memory_gb" {
  description = "RAM GB"
  type        = number
  default     = 4
}

variable "boot_disk_size_gb" {
  description = "Boot disk size"
  type        = number
  default     = 15
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "network-hdd"
}

variable "data_disk_size_gb" {
  description = "Secondary data disk size"
  type        = number
  default     = 10
}

variable "data_disk_type" {
  description = "Data disk type"
  type        = string
  default     = "network-hdd"
}

variable "vm_user" {
  description = "OS user for SSH"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}
