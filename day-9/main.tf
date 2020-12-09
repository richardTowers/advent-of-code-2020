locals {
  input = trimspace(file("input.txt"))
  numbers = [for string in split("\n", local.input): parseint(string, 10)]
  preamble_length = 25
  invalid_numbers = [for index, number in slice(local.numbers, local.preamble_length, length(local.numbers)):
    number if !contains(flatten([for i, inum in slice(local.numbers, index, index + local.preamble_length):
      [for j, jnum in slice(local.numbers, index, index + local.preamble_length):
        inum + jnum if i != j
      ]
    ]), number)
  ]
}

output "answer" {
  value = local.invalid_numbers[0]
}
