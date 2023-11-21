terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.token_iam
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

# create 3 gfs2-vm
resource "yandex_compute_instance" "gfs2-vm" {

  # count = 3
  for_each = toset(["vm1", "vm2", "vm3"])
  name = each.key

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.username}:${file(var.ssh-pub-key)}"
  }

}

# create 1 iscsi-vm
resource "yandex_compute_instance" "iscsi-vm" {

  name = "${var.instance_name}-iscsi"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.username}:${file(var.ssh-pub-key)}"
  }

}

# create network
resource "yandex_vpc_network" "network-1" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "tf-testsubnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# run ansible deploy for gfs2-vm
resource "null_resource" "gfs2-ansible_provision" {
  # count = length(yandex_compute_instance.gfs2-vm)
  for_each = yandex_compute_instance.gfs2-vm
  # depends_on = [
  #   yandex_compute_instance.gfs2-vm[count.index],
  # ]
    depends_on = [
    each.value,
  ]

  connection {
    type  = "ssh"
    user  = var.username
    private_key = file(var.ssh-priv-key)
    host  = yandex_compute_instance.gfs2-vm[each.key].network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = ["echo 'ready to apt installing'"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.username} -i '${yandex_compute_instance.gfs2-vm[each.key].network_interface.0.nat_ip_address},' --private-key='${var.ssh-priv-key}' gfs2_playbook.yml"
  }

}

# run ansible deploy for iscsi-vm
resource "null_resource" "iscsi-ansible_provision" {
  depends_on = [yandex_compute_instance.iscsi-vm]
  

  connection {
    type  = "ssh"
    user  = var.username
    private_key = file(var.ssh-priv-key)
    host  = yandex_compute_instance.iscsi-vm.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = ["echo 'ready to apt installing'"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.username} -i '${yandex_compute_instance.iscsi-vm.network_interface.0.nat_ip_address},' --private-key='${var.ssh-priv-key}' iscsi_playbook.yml"
  }
}