locals {
  groups = [for group in split("\n\n", trimspace(file("input.txt"))):
    [for person in split("\n", group): split("", person)]
  ]
  anyone_yes_counts   = [for g in local.groups: length(setunion(g...)) ]
  everyone_yes_counts = [for g in local.groups: length(setintersection(g...)) ]
}

output "part_1_answer" {
  value = sum(local.anyone_yes_counts)
}

output "part_2_answer" {
  value = sum(local.everyone_yes_counts)
}
