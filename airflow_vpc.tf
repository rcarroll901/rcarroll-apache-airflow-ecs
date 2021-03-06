
resource "aws_vpc" "airflow" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = {
        Name = "airflow_vpc"
    }
}

# GATEWAYS
resource "aws_internet_gateway" "airflow" {
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow_ig"
    }
}

resource "aws_eip" "nat" {
    vpc = true
}

resource "aws_nat_gateway" "airflow" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public.id
    depends_on = [aws_internet_gateway.airflow]
    tags = {
        Name = "airflow_nat"
    }
}

# SUBNETS
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.airflow.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.region}a"
    tags = {
        Name = "airflow_public_sn"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.airflow.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.region}b"
    tags = {
        Name = "airflow_private_sn"
    }
}

# ROUTING TABLES
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.airflow.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.airflow.id
    }
    tags = {
        Name = "airflow_public_route_table"
    }
}

resource "aws_route_table_association" "public-rta" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# add route to NAT for private subnet (to main rt)
resource "aws_route" "nat" {
  route_table_id            = aws_vpc.airflow.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.airflow.id
}


# BASTION SETUP
resource "aws_instance" "bastion" {
    ami = "ami-078d79190068a1b35"
    associate_public_ip_address = true
    instance_type = "t2.nano"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.bastion.id]
    key_name = aws_key_pair.just_city.key_name

    tags = {
        Name = "airflow_bastion_instance"
    }
}

resource "aws_key_pair" "just_city" {
    key_name = "to-bastion-jc-pipeline"
    public_key = var.access_ssh_public_key
    tags = {
        Name = "just_city_key_pair"
    }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
}
