output "instance_ips" {
  value = aws_instance.swisscom02-vm.public_ip
}