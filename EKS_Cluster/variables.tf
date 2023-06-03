variable "aws_region" {
    type= string
    default = "eu-west-2"
    description = "The aws region in which terraform will manage the infrastructure"
      
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "VPC CIDR"
  
}
variable "public_subnet_cidrs" {
    type = list(string)
    default = [ "10.0.0.0/19","10.0.32.0/19","10.0.64.0/19" ]
  
}
variable "private_subnet_cidrs" {
    type = list(string)
    default=["10.0.96.0/19","10.0.128.0/19","10.0.160.0/19"]
}
  

variable "project_name" {
    type = string
    description = "Demo-EKS"
}
variable "common_tags" {
    type = map(string)
    default ={
        "Environment"="Dev"
        "owner"="Ravi"
    }
  
}