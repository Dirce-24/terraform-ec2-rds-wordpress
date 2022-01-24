resource "aws_instance" "site_server" {
  ami                    = "ami-08e4e35cccc6189f4"
  instance_type          = "t2.micro"
  key_name               = "php"
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "site_server"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./ec2_key/php.pem")
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
          "sudo yum install httpd php php-mysql -y",
          "cd /var/www/html",
          "sudo wget https://wordpress.org/wordpress-5.1.1.tar.gz",
          "sudo tar -xzf wordpress-5.1.1.tar.gz",
          "sudo cp -r wordpress/* /var/www/html/",
          "rm -rf wordpress",
          "rm -rf wordpress-5.1.1.tar.gz",
          "sudo chmod -R 755 wp-content",
          "sudo chown -R apache:apache wp-content",
          "sudo service httpd start",
          "sudo chkconfig httpd on"
    ]
  }
  
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    }
  ]
}
