locals {
  input = trimspace(file("input.txt"))
  raw_instructions = [for row in split("\n", local.input): split(" ", row)]
  instructions = [for raw in local.raw_instructions:
    {
      type: raw[0],
      value: raw[1],
    }
  ]
  execution_log = fileexists("execution_log.json") ? jsondecode(file("execution_log.json")) : [0]
  last_address = local.execution_log[length(local.execution_log) -1]
  last_instruction = local.instructions[local.last_address]
  next_address = (
    local.last_instruction["type"] == "jmp"
      ? local.last_address + local.last_instruction["value"]
      : local.last_address + 1
  )
  next_execution_log = (
    contains(local.execution_log, local.next_address)
      ? local.execution_log
      : concat(local.execution_log, [local.next_address])
  )
  accumulators = [for address in local.execution_log:
    parseint(local.instructions[address]["value"], 10) if local.instructions[address]["type"] == "acc"
  ]
}

resource "local_file" "execution_log" {
  content  = jsonencode(local.next_execution_log)
  file_permission = "0666"
  filename = "execution_log.json"
}

output "part_1_answer" {
  value = sum(local.accumulators)
}

