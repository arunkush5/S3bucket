provider "aws" {
	region	=  "ap-south-1"
	profile =  "TfUser"
}

resource "aws_instance" "tfos" {
  ami               = "ami-0447a12f28fddb066"
  availability_zone = "ap-south-1a"
  instance_type     = "t2.micro"
  key_pair	    = "nike-key"
  security_groups   = "sg_task01"
  
    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Windows10/Downloads/AWS/CloudTerra/Task01/nike-key.pem")
    host     = aws_instance.tfos.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "TfOS"
  }
}

resource "aws_ebs_volume" "external_vol" {
  	availability_zone = "ap-south-1a"
  	size              = 1

  	tags = {
    		Name = "ext_vol"
  	}
}


resource "aws_volume_attachment" "vol_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.exterenal_vol.id}"
  instance_id = "${aws_instance.tfos.id}"
  force_detach= true

# Tells Terraform to attach this volume after the
  # volume has been created.
  depends_on = [aws_ebs_volume.external_vol]
}


output "myos_ip" {
  value = aws_instance.tfos.public_ip
}

resource "null_resource" "nullremote1"  {

depends_on = [
    aws_volume_attachment.vol_att,
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Windows10/Downloads/AWS/CloudTerra/Task01/nike-key.pem")
    host     = aws_instance.tfos.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/d3adl0ck3y3/Terraform.git /var/www/html/"
    ]
  }
}
