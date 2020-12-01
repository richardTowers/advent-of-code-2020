locals {
  input = trimspace(file("input.txt"))
  strings = split("\n", local.input)
  numbers = toset([for str in local.strings : parseint(str, 10)])
  answer = [for num in local.numbers : num if contains(local.numbers, 2020 - num)]
}

output "answer" {
  value = "${local.answer[0] * local.answer[1]}"
}
