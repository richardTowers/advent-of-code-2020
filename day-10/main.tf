locals {
  input = trimspace(file("input.txt"))
  numbers = [for string in split("\n", local.input): parseint(string, 10)]

  device = max(local.numbers...) + 3
  adapters = concat(
    [0], # The charging outlet
    local.numbers, # Our adapters
    [local.device]
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

  # Part 2
  options = {for adapter in local.sorted_adapters:
    adapter => [for a in local.sorted_adapters: tostring(a) if a > adapter && a <= adapter + 3]
  }

  evaluated_options = (fileexists("evaluated_options.json")
    ? jsondecode(file("evaluated_options.json"))
    : { "${local.device}": 1 }
  )

  next_evaluated_options = merge(local.evaluated_options, {for adapter, options in local.options:
    adapter => try(sum([for key, value in local.evaluated_options: value if contains(options, key)]), null) if
    length(setintersection(options, keys(local.evaluated_options))) > 0
  })
}

resource "local_file" "evaluated_options" {
  content  = jsonencode(local.next_evaluated_options)
  file_permission = "0666"
  filename = "evaluated_options.json"
}

output "part_1_answer" {
  value = local.difference_counts["1"] * local.difference_counts["3"]
}

output "part_2_answer" {
  value = try(local.evaluated_options["0"], "...")
}

