variable "cidr_range" {
    description = "the cidr range of the instance"
    type = string
  
}
variable "sub_range" {
    description = "the cidr range ot the subnet"
    type = string
}
variable "route_table_range" {
    description = "the cidr range ot the route table"
    type = string
  
}
variable "login_key" {
    description = "public key of the instance"
    type = string
}
variable "ami_id" {
    description = "ubuntu ami id" 
    type = string 
}
variable "instance_type" {
    description = "instane type" 
    type = string 
  
}