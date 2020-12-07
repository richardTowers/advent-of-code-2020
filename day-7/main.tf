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

  contained = fileexists("contained.txt") ? split("\n", trimspace(file("contained.txt"))) : [
    jsonencode({
      bag: "shiny gold",
      multiple: 1,
      partial: true
    })
  ]
  parsed_contained = [for item in local.contained: jsondecode(item)]
  non_partial = [for item in local.parsed_contained: jsonencode({
    bag: item["bag"],
    multiple: item["multiple"],
    partial: false,
  })]
  partials = flatten([for item in local.parsed_contained:
    [for inside in local.rules[item["bag"]]:
      jsonencode({
        bag: inside["bag"],
        multiple: parseint(inside["count"], 10) * item["multiple"]
        partial: true
      })
    ] if item["partial"]
  ])
  next_contained = concat(local.non_partial, local.partials)
}

resource "local_file" "containers" {
  content  = join("\n", local.next_containers)
  file_permission = "0666"
  filename = "containers.txt"
}

resource "local_file" "contained" {
  content  = join("\n", local.next_contained)
  file_permission = "0666"
  filename = "contained.txt"
}

output "part_1_answer" {
  value = length(local.next_containers) - 1 # subtract 1 for "shiny gold", which shouldn't count.
}

output "part_2_answer" {
  value = sum(local.parsed_contained[*].multiple) - 1 # subtract 1 for "shiny gold", which shouldn't count.
}
