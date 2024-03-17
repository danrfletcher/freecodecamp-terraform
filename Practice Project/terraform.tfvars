#Define variables here - can be gitignored
subnet_prefix = ["10.0.200.0/24", "10.0.2.0/24"] #this variable is a list, but it can also be any other supported data type, even an object

object_variable_example = [{cidr_block = "10.0.1.0/24", name = "prod_subnet"}, {cidr_block = "10.0.50.0/24", name = "dev_subnet"}]