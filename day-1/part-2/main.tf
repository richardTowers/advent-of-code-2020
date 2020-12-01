locals {
  input = trimspace(file("input.txt"))
  strings = split("\n", local.input)
  numbers = toset([for str in local.strings : parseint(str, 10)])
  combos = [for combo in setproduct(local.numbers, local.numbers) : combo if combo[0] != combo[1]]
  answer = distinct(flatten([for combo in local.combos : combo if contains(local.numbers, 2020 - combo[0] - combo[1])]))
}

output "answer" {
  value = "${local.answer[0] * local.answer[1] * local.answer[2]}"
}
