variable "public_subnet_1_cidr" {
  default = 10.0.1.0/24
}

variable "public_subnet_2_cidr" {
  default = 10.0.2.0/24
}

variable "env" {
    default = dev
  
}

variable "key_name" {
  default = mumbai-key
}

 variable "image_id" {
    default = ami-0e38835daf6b8a2b9
 }

 variable "instance_type" {
    default = t3.micro
   
}