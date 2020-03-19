locals {
  az_count = "${length(data.aws_availability_zones.all.names)}"
}

data "aws_availability_zones" "all" {}

# Network VPC, gateway, and routes

resource "aws_vpc" "network" {
  cidr_block                       = "${var.host_cidr}"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = "${map("Name", "${var.cluster_name}")}"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.network.id}"

  tags = "${map("Name", "${var.cluster_name}")}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.network.id}"

  tags = "${map("Name", "${var.cluster_name}-public")}"
}

resource "aws_route" "internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
}

resource "aws_route" "ipv6_internet_gateway" {
  route_table_id              = "${aws_route_table.public.id}"
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = "${aws_internet_gateway.gateway.id}"
}

# Subnets (one per availability zone)

resource "aws_subnet" "public" {
  count = "${local.az_count}"

  vpc_id            = "${aws_vpc.network.id}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"

  cidr_block                      = "${cidrsubnet(var.host_cidr, 4, count.index)}"
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index)}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = "${merge(
    var.subnet_tags_public,
    map("Name", "${var.cluster_name}-public-${count.index}")
  )}"
}

resource "aws_route_table_association" "public" {
  count = "${local.az_count}"

  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_subnet" "private" {
  count = "${local.az_count}"

  vpc_id            = "${aws_vpc.network.id}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"

  cidr_block                      = "${cidrsubnet(var.host_cidr, 4, count.index + 8)}"
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index + 8)}"
  assign_ipv6_address_on_creation = true

  tags = "${merge(
    var.subnet_tags_private,
    map("Name", "${var.cluster_name}-private-${count.index}")
  )}"
}

resource "aws_route_table" "private" {
  count = "${local.az_count}"

  vpc_id = "${aws_vpc.network.id}"
  tags = "${map("Name", "${var.cluster_name}-private")}"
}

resource "aws_route" "nat_gateway" {
  count = "${local.az_count}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  destination_cidr_block     = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

resource "aws_route" "egress_only_gateway" {
  count = "${local.az_count}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  destination_ipv6_cidr_block        =   "::/0"
  egress_only_gateway_id = "${aws_egress_only_internet_gateway.egress_igw.id}"
}

resource "aws_route_table_association" "private" {
  count = "${local.az_count}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}


resource "aws_eip" "nat" {
  count = "${local.az_count}"

  vpc = true
}

resource "aws_nat_gateway" "nat" {
  depends_on = [
    "aws_internet_gateway.gateway",
  ]

  count = "${local.az_count}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_egress_only_internet_gateway" "egress_igw" {
  vpc_id = "${aws_vpc.network.id}"
}
