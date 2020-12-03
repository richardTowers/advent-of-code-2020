locals {
  input = trimspace(file("input.txt"))
  grid = [for row in split("\n", local.input): split("", row)]
  width = length(local.grid[0])
  height = length(local.grid)

  vectors = [
    {
      down: 1
      right: 1
    },
    {
      down: 1
      right: 3
    },
    {
      down: 1
      right: 5
    },
    {
      down: 1
      right: 7
    },
    {
      down: 2
      right: 1
    }
  ]

  indices_to_check_by_vector = [for vector in local.vectors:
    [for index, row in local.grid:
      [index * vector["down"], (index * vector["right"]) % local.width] if index * vector["down"] <= local.height
    ]
  ]
  trees_by_vector = [for indices_to_check in local.indices_to_check_by_vector:
    [for index in indices_to_check:
      "#" if local.grid[index[0]][index[1]] == "#"
    ]
  ]
}

output "part_1_answer" {
  value = length(local.trees_by_vector[1])
}

output "part_2_answer" {
  value = "${
    length(local.trees_by_vector[0]) *
    length(local.trees_by_vector[1]) *
    length(local.trees_by_vector[2]) *
    length(local.trees_by_vector[3]) *
    length(local.trees_by_vector[4])
  }"
}
