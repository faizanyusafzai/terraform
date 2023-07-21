provider "aws" {
  version = "~> 3.0"  
  region  = "us-east-1"
}

module "mine-it" {
  source = "../../terraform/module" 

  region                    = "us-east-1"  #
  vpc_cidr_block            = "10.0.0.0/16"
  availability_zones        = ["us-east-1a", "us-east-1b"]  
  public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24"]
  instance_type             = "t2.micro"
  volume_size_gb            = 10
  s3_bucket_name            = "my-s3-bucket-name"
  ami_id                    = "ami-0c55b159cbfafe1f0"  
}
