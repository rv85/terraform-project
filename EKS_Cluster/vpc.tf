resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = merge(var.common_tags, {
        "Name"="${var.project_name}-vpc",
        "kubernetes.io/cluster/${var.project_name}-cluster}"="shared"
    })
  
}
resource "aws_subnet" "public" {
    count=length(var.public_subnet_cidrs)
    vpc_id=aws_vpc.main.vpc_id
    cidr_block = element(var.public_subnet_cidrs,count.index)
    availability_zone = data.aws_availability_zone.available.names[count.index]
    map_public_ip_on_launch = true
    tags=merge(var.common_tags,{
        "Name"="${var.project_name}-public-subnet",
        "kubernetes.io/role/elb"="1"
    })
  
}
resource "aws_subnet" "private" {
    count=length(var.public_subnet_cidrs)
    vpc_id=aws_vpc.main.vpc_id
    cidr_block = element(var.private_subnet_cidrs,count.index)
    availability_zone = data.aws_availability_zone.available.names[count.index]
    map_public_ip_on_launch = true
    tags=merge(var.common_tags,{
        "Name"="${var.project_name}-private-subnet",
        "kubernetes.io/role/elb"="1"
    })
  
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.main_vpc
    tags = merge(var.common_tags,{
        "Name"="${var.project_name}-igw"
    })
  
}
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
    tags = merge(var.common_tags,{
        "Name"="${var.project_name}-public-rt"
    })
  
}
resource "aws_route_table_association" "public_rt_association" {
    count=length(var.public_subnet_cidrs)
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public[count.index].id

  
}
resource "aws_eip" "nateip" {
    tags = merge(var.common_tags,{
        "Name"="${var.project_name}-nateip"
    })
  
}
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nateip.id
    subnet_id = aws_subnet.public[0].id
    depends_on = [ 
        aws_internet_gateway.IGW
     ]
     tags = merge(var.common_tags,{
        "Name"="${var.project_name}-nat"
     })
  
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main_vpc
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
    tags = merge(var.common_tags,{
        "Name"="${var.project_name}-private-rt"
    })
    
  
}
resource "aws_route_table_association" "private_rt_association" {
    count= length(var.private_subnet_cidrs)
    route_table_id = aws_route_table.private_rt.id
    subnet_id = aws_subnet.private[count.index].id
  
}
