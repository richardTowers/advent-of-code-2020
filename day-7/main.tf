locals {
  input = trimspace(file("input.txt"))
  rows = split("\n", local.input)
  rules = {for row in local.rows:
    regex("([a-z]+ [a-z]+) bags contain", row)[0] =>
      regexall("(?P<count>[0-9]+) (?P<bag>[a-z]+ [a-z]+) bags?[,.]", row)
  }

  bag_containers = fileexists("bag_containers.txt") ? split("\n", trimspace(file("bag_containers.txt"))) : ["shiny gold"]
  next_bag_containers = toset(concat(local.bag_containers, [for bag, contents in local.rules:
    bag if length(setintersection(contents[*].bag, local.bag_containers)) > 0
  ]))

  bag_contents = fileexists("bag_contents.txt") ? split("\n", trimspace(file("bag_contents.txt"))) : [
    jsonencode({
      bag: "shiny gold",
      multiple: 1,
      partial: true
    })
  ]
  parsed_bag_contents = [for item in local.bag_contents: jsondecode(item)]
  partials = flatten([for item in local.parsed_bag_contents:
    [for contents in local.rules[item["bag"]]:
      jsonencode({
        bag: contents["bag"],
        multiple: parseint(contents["count"], 10) * item["multiple"]
        partial: true
      })
    ] if item["partial"]
  ])
  non_partials = [for item in local.parsed_bag_contents: jsonencode(merge(item, {partial: false}))]
  next_bag_contents = concat(local.non_partials, local.partials)
}

resource "local_file" "bag_containers" {
  content  = join("\n", local.next_bag_containers)
  file_permission = "0666"
  filename = "bag_containers.txt"
}

resource "local_file" "bag_contents" {
  content  = join("\n", local.next_bag_contents)
  file_permission = "0666"
  filename = "bag_contents.txt"
}

output "part_1_answer" {
  value = length(local.next_bag_containers) - 1 # subtract 1 for "shiny gold", which shouldn't count.
}

output "part_2_answer" {
  value = sum(local.parsed_bag_contents[*].multiple) - 1 # subtract 1 for "shiny gold", which shouldn't count.
}
