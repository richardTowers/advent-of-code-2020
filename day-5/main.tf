locals {
  input = trimspace(file("input.txt"))
  boarding_passes = [for pass in split("\n", local.input):
    {
      row: substr(pass, 0, 7),
      column: substr(pass, 7, 3)
    }
  ]
  binary_passes = [for pass in local.boarding_passes:
    {
      row: replace(replace(pass["row"], "B", "1"), "F", "0"),
      column: replace(replace(pass["column"], "R", "1"), "L", "0"),
    }
  ]
  numeric_passes = [for pass in local.binary_passes:
    {
      row: parseint(pass["row"], 2),
      column: parseint(pass["column"], 2),
    }
  ]
  ids = [for pass in local.numeric_passes:
    pass["row"] * 8 + pass["column"]
  ]
  max_id = max(local.ids...)
  missing_ids = [for id in range(min(local.ids...), local.max_id):
    id if !contains(local.ids, id)
  ]
}

output "part_1_answer" {
  value = local.max_id
}

output "part_2_answer" {
  value = local.missing_ids[0]
}
