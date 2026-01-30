variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "labs-dvn-mini-curso-devops-e-aws"
  }
}

variable "assume_role" {
  type = object({
    region   = string
    role_arn = string
  })
  default = {
    region   = "us-east-1"
    role_arn = "arn:aws:iam::273444517440:role/labs-dvn-mini-curso-devops-e-aws-role"
  }
}

variable "queues" {
  type = list(object({
    name                      = string
    delay_seconds             = number
    max_message_size          = number
    message_retention_seconds = number
    receive_wait_time_seconds = number
  }))
  default = [{
    name                      = "labs-dvn-queue-1"
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    },
    {
      name                      = "labs-dvn-queue-2"
      delay_seconds             = 0
      max_message_size          = 1024
      message_retention_seconds = 345600
      receive_wait_time_seconds = 0
  }]
}

variable "vpc" {
  type = object({
    name                     = string
    cidr_block               = string
    internet_gateway_name    = string
    public_route_table_name  = string
    private_route_table_name = string
    nat_gateway_name         = string
    public_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))
    private_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))
  })
  default = {
    name                     = "labs-dvn-mini-curso-devops-e-aws-vpc"
    cidr_block               = "10.0.0.0/24"
    internet_gateway_name    = "labs-dvn-mini-curso-devops-e-aws-igw"
    nat_gateway_name         = "labs-dvn-mini-curso-devops-e-aws-nat-ngw"
    public_route_table_name  = "labs-dvn-mini-curso-devops-e-aws-public-rt"
    private_route_table_name = "labs-dvn-mini-curso-devops-e-aws-private-rt"
    public_subnets = [{
      name                    = "public-subnet-1"
      cidr_block              = "10.0.0.0/26"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
      },
      {
        name                    = "public-subnet-2"
        cidr_block              = "10.0.0.64/26"
        availability_zone       = "us-east-1b"
        map_public_ip_on_launch = true
    }]
    private_subnets = [{
      name                    = "private-subnet-1"
      cidr_block              = "10.0.0.128/26"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = false
      },
      {
        name                    = "private-subnet-2"
        cidr_block              = "10.0.0.192/26"
        availability_zone       = "us-east-1b"
        map_public_ip_on_launch = false
    }]
  }
}

variable "eks_cluster" {
  type = object({
    name                              = string
    version                           = string
    enabled_cluster_log_types         = list(string)
    access_config_authentication_mode = string
    iam_role_name                     = string
  })
  default = {
    name    = "labs-dvn-mini-curso-devops-e-aws-eks-cluster"
    version = "1.31"
    enabled_cluster_log_types = [
      "api",
      "audit",
      "authenticator",
      "controllerManager",
      "scheduler"
    ]
    access_config_authentication_mode = "API_AND_CONFIG_MAP"
    iam_role_name                     = "labs-dvn-mini-curso-devops-e-aws-eks-cluster-role"
  }
}


variable "eks_node_group" {
  type = object({
    name           = string
    version        = string
    capacity_type  = string
    instance_types = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    iam_role_name = string
  })
  default = {
    name           = "labs-dvn-mini-curso-devops-e-aws-eks-node-group"
    version        = "1.31"
    capacity_type  = "ON_DEMAND"
    instance_types = ["t3.medium"]
    scaling_config = {
      desired_size = 2
      max_size     = 2
      min_size     = 2
    }
    iam_role_name = "labs-dvn-mini-curso-devops-e-aws-eks-node-group-role"
  }
}

variable "ecr_repository" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
  }))
  default = [
    {
      name                 = "labs-dvn-repo/dev/frontend"
      image_tag_mutability = "MUTABLE"
    },
    {
      name                 = "labs-dvn-repo/dev/backend"
      image_tag_mutability = "MUTABLE"
    }
  ]
}
