output "control-plane-node_ip" {
  value = hcloud_server.control-plane-node.ipv4_address
}

output "worker-nodes_ip" {
  value = formatlist(
    "%s: %s",
    hcloud_server.worker-nodes[*].name,
    hcloud_server.worker-nodes[*].ipv4_address
  )
}
