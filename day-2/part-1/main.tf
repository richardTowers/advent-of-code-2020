locals {
  input = trimspace(file("input.txt"))
  strings = split("\n", local.input)
  parts = [ for str in local.strings :
    regex("(?P<min>[[:digit:]]+)-(?P<max>[[:digit:]]+) (?P<char>[[:alpha:]]): (?P<password>[[:alpha:]]+)", str)
  ]
  valid_passwords = [ for part in local.parts :
    part
    if length(regexall(part["char"], part["password"])) >= parseint(part["min"], 10)
    && length(regexall(part["char"], part["password"])) <= parseint(part["max"], 10)
  ]
}

output "answer" {
  value = length(local.valid_passwords)
}
