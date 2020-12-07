locals {
  input = trimspace(file("input.txt"))
  rows = split("\n", local.input)
  rules = {for row in local.rows:
    regex("([a-z]+ [a-z]+) bags contain", row)[0] =>
      regexall("(?P<count>[0-9]+) (?P<bag>[a-z]+ [a-z]+) bags?[,.]", row)
  }
  containers = fileexists("containers.txt") ? split("\n", trimspace(file("containers.txt"))) : ["shiny gold"]
  next_containers = toset(concat(local.containers, [for bag, contents in local.rules:
    bag if length(setintersection(contents[*].bag, local.containers)) > 0
  ]))
}

resource "local_file" "containers" {
  content  = join("\n", local.next_containers)
  file_permission = "0666"
  filename = "containers.txt"
}

output "answer" {
  value = length(local.next_containers) - 1 # subtract 1 for "shiny gold", which shouldn't count.
}
