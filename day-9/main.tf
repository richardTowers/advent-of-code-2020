locals {
  input = trimspace(file("input.txt"))
  numbers = [for string in split("\n", local.input): parseint(string, 10)]
  preamble_length = 25
  max_range_length = 20

  invalid_numbers = [for index, number in slice(local.numbers, local.preamble_length, length(local.numbers)):
    number if !contains(flatten([for i, inum in slice(local.numbers, index, index + local.preamble_length):
      [for j, jnum in slice(local.numbers, index, index + local.preamble_length):
        inum + jnum if i != j
      ]
    ]), number)
  ]
  part_1_answer = local.invalid_numbers[0]
  ranges = flatten([for end_index, _ in local.numbers:
    [for range_length in range(0, end_index > local.max_range_length ? local.max_range_length : end_index):
      {
        end_index: end_index,
        range_length: range_length,
        min: min(slice(local.numbers, end_index - range_length, end_index)...),
        max: max(slice(local.numbers, end_index - range_length, end_index)...),
      } if range_length > 1 && sum(concat(slice(local.numbers, end_index - range_length, end_index), [0])) == local.part_1_answer
    ]
  ])
  part_2_answer = local.ranges[0]["min"] + local.ranges[0]["max"]
}

output "part_1_answer" {
  value = local.part_1_answer
}

output "part_2_answer" {
  value = local.part_2_answer
}

