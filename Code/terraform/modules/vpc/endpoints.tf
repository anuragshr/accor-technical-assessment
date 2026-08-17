data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecrapi" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "eks" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.eks"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "oidc-eks" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.oidc-eks"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "eks-auth" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.eks-auth"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "elb" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "asg" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.autoscaling"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "route53" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.route53"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.eks_endpoint.id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

}

resource "aws_security_group" "eks_endpoint" {
  name        = "eks-endpoint-sg"
  description = "Security group for EKS VPC endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}