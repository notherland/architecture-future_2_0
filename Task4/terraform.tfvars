
service_account_key_file = "sa-key.json"

yc_cloud_id  = "b1gpib5mbriggurg98l0"
yc_folder_id = "b1gseepad94krr7cf3e2"
yc_zone      = "ru-central1-a"

network_name = "future20-platform"
subnet_cidr  = "10.10.0.0/24"
ssh_cidr     = "0.0.0.0/0"

vm_name        = "future20-app"
vm_platform_id = "standard-v3"
vm_cores       = 2
vm_memory_gb   = 4
boot_disk_size_gb  = 15
boot_disk_type     = "network-hdd"
data_disk_size_gb  = 1
data_disk_type     = "network-hdd"

vm_user        = "ubuntu"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuture20PlaceholderKey future20@local"
