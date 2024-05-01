terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.46.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

locals {
  cloud_init_control = templatefile(
    "${path.module}/cloud-init.yaml", {
      own_public    = file(var.ssh_public_key),
      worker_public = tls_private_key.worker.public_key_openssh,
    }
  )
  cloud_init_worker = templatefile(
    "${path.module}/cloud-init-worker.yaml", {
      own_public     = file(var.ssh_public_key),
      worker_private = tls_private_key.worker.private_key_openssh
    }
  )
}

resource "tls_private_key" "worker" {
  algorithm = "ED25519"
}

resource "hcloud_network" "private_network" {
  name     = "kubernetes-cluster"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private_network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.private_network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_server" "control-plane-node" {
  name        = "control-plane-node"
  image       = "ubuntu-22.04"
  server_type = "cax11"
  location    = "fsn1"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
    ip         = "10.0.1.1"
  }
  user_data = local.cloud_init_control

  depends_on = [hcloud_network_subnet.private_network_subnet]
}

resource "hcloud_server" "worker-nodes" {
  count       = 3
  name        = format("worker-node-%02d", count.index + 1)
  image       = "ubuntu-22.04"
  server_type = "cax11"
  location    = "fsn1"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
  }
  user_data = local.cloud_init_worker

  depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_server.control-plane-node]
}
