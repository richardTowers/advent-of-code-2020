locals {
  input = trimspace(file("input.txt"))
  numbers = [for string in split("\n", local.input): parseint(string, 10)]

  adapters = concat(
    [0], # The charging outlet
    local.numbers, # Our adapters
    [max(local.numbers...) + 3], # The device
  )

  # Terraform has no numeric sort, so we have to pad the numbers with zeros and sort them alphabetically
  sorted_adapters = [for string in sort(formatlist("%09d", local.adapters)): parseint(string, 10)]
  differences = [for index, adapter in slice(local.sorted_adapters, 0, length(local.sorted_adapters) - 1):
    local.sorted_adapters[index + 1] - adapter
  ]
  difference_groups = {for diff in local.differences:
    diff => "#"...
  }
  difference_counts = {for key, group in local.difference_groups:
    key => length(group)
  }
}

output "part_1_answer" {
  value = local.difference_counts["1"] * local.difference_counts["3"]
}

