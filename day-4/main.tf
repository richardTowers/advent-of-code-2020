locals {
  input = trimspace(file("input.txt"))
  passports = [for passport in split("\n\n", local.input):
    replace(passport, "\n", " ")
  ]
  valid_passports = [for passport in local.passports:
    passport
    if length(regexall("byr:", passport)) > 0
    && length(regexall("iyr:", passport)) > 0
    && length(regexall("eyr:", passport)) > 0
    && length(regexall("hgt:", passport)) > 0
    && length(regexall("hcl:", passport)) > 0 # ❤ hcl
    && length(regexall("ecl:", passport)) > 0
    && length(regexall("pid:", passport)) > 0
    # && length(regexall("cid:", passport)) > 0 # This one's optional
  ]
}

output "answer" {
  value = length(local.valid_passports)
}
