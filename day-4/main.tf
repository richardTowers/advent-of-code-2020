locals {
  input = trimspace(file("input.txt"))
  passports = [for passport in split("\n\n", local.input):
    replace(passport, "\n", " ")
  ]
  passports_with_all_fields = [for passport in local.passports:
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
  parsed_passports = [for passport in local.passports_with_all_fields:
    {
      byr: regex("byr:([[:digit:]]{4})", passport)[0],
      iyr: regex("iyr:([[:digit:]]{4})", passport)[0],
      eyr: regex("eyr:([[:digit:]]{4})", passport)[0],
      hgt_cm: regex("hgt:(?:([[:digit:]]+)cm)?", passport)[0],
      hgt_in: regex("hgt:(?:([[:digit:]]+)in)?", passport)[0],
      hcl: regex("hcl:(#[0-9a-f]{6})?", passport)[0],
      ecl: regex("ecl:(amb|blu|brn|gry|grn|hzl|oth)?", passport)[0],
      pid: regex("pid:([[:digit:]]{9}(?: |$))?", passport)[0],
    }
  ]
  valid_passports = [for passport in local.parsed_passports:
    passport
    if passport["byr"] != null && parseint(passport["byr"], 10) >= 1920 && parseint(passport["byr"], 10) <= 2002
    && passport["iyr"] != null && parseint(passport["iyr"], 10) >= 2010 && parseint(passport["iyr"], 10) <= 2020
    && passport["eyr"] != null && parseint(passport["eyr"], 10) >= 2020 && parseint(passport["eyr"], 10) <= 2030
    && (
      (passport["hgt_cm"] != null ? (parseint(passport["hgt_cm"], 10) >= 150 && parseint(passport["hgt_cm"], 10) <= 193) : false)
      ||
      (passport["hgt_in"] != null ? (parseint(passport["hgt_in"], 10) >= 59 && parseint(passport["hgt_in"], 10) <= 76) : false)
    )
    && passport["hcl"] != null
    && passport["ecl"] != null
    && passport["pid"] != null
  ]
}

output "part_1_answer" {
  value = length(local.passports_with_all_fields)
}

output "part_2_answer" {
  value = length(local.valid_passports)
}
