resource "aws_instance" "swisscom02-vm" {
  ami = "ami-0fbd1ecdaa0af2276"
  instance_type = "t4g.medium"
  vpc_security_group_ids = [ aws_security_group.swisscom02-sg.id ]
  key_name = "swisscom02"
  user_data = <<EOF
#!/bin/bash -xe
exec >/var/log/user-data.log 2>&1
yum update -y 
amazon-linux-extras enable ansible2
yum install -y ansible
while true; do 
  [ -f /tmp/docker-playbook.yml ] && echo "docker-playbook found" && ansible-playbook /tmp/docker-playbook.yml && exit
  echo "docker-playbook NOT found, re-iterating"
done
EOF
  tags = {
      Name = "swisscom02"
  }
  provisioner "file" {
    source      = "../ansible/docker-playbook.yml"
    destination = "/tmp/docker-playbook.yml"
  
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("swisscom02.openssh.privatekey")
      host     = "${aws_instance.swisscom02-vm.public_ip}"
    }

  }
}

resource "aws_security_group" "swisscom02-sg" {
  name = "web-sg01"
  ingress {
    protocol = "tcp"
    from_port = 53
    to_port = 53
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    protocol = "udp"
    from_port = 53
    to_port = 53
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}