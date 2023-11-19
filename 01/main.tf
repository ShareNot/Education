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

resource "yandex_compute_instance" "test-vm" {
  name = var.instance_name

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

resource "yandex_vpc_network" "network-1" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "tf-testsubnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "null_resource" "ansible_provision" {
  depends_on = [yandex_compute_instance.test-vm]

  connection {
    type  = "ssh"
    user  = var.username
    private_key = file(var.ssh-priv-key)
    host  = yandex_compute_instance.test-vm.network_interface.0.nat_ip_address
  }

provisioner "remote-exec" {
    inline = ["echo 'ready to apt installing'"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.username} -i '${yandex_compute_instance.test-vm.network_interface.0.nat_ip_address},' --private-key='${var.ssh-priv-key}' ansible_playbook.yml"
  }

}

