locals {
  input = trimspace(file("input.txt"))
  raw_instructions = [for row in split("\n", local.input): split(" ", row)]
  instructions = [for raw in local.raw_instructions:
    {
      type: raw[0],
      value: raw[1],
    }
  ]
  state = (fileexists("state.json")
    ? jsondecode(file("state.json"))
    : {
        mode: "default", # "speculative" or "reset"
        execution_log:[0],
        speculative_execution_log: [],
        non_teminating_addresses: []
      })

  mode = local.state["mode"]
  execution_log = local.state["execution_log"]
  speculative_execution_log = local.state["speculative_execution_log"]
  non_teminating_addresses = local.state["non_teminating_addresses"]

  total_execution_log = concat(local.execution_log, local.speculative_execution_log)

  last_address = (local.mode == "speculative"
    ? local.speculative_execution_log[length(local.speculative_execution_log) - 1]
    : local.execution_log[length(local.execution_log) - 1])

  last_instruction = (local.last_address < length(local.instructions)
    ? local.instructions[local.last_address]
    : local.instructions[length(local.instructions) - 1])

  flip_instruction = local.mode == "default" && contains(["jmp", "nop"], local.last_instruction["type"])

  next_address = (local.flip_instruction
    ? (local.last_instruction["type"] == "nop"
      ? local.last_address + local.last_instruction["value"]
      : local.last_address + 1)
    : (local.last_instruction["type"] == "jmp"
      ? local.last_address + local.last_instruction["value"]
      : local.last_address + 1)
  )

  done = local.next_address > length(local.instructions)

  loop_detected = contains(local.total_execution_log, local.next_address) || (local.mode == "speculative" && contains(local.non_teminating_addresses, local.next_address))

  next_mode = ({
    default: (local.flip_instruction ? "speculative" : "default"),
    speculative: (local.loop_detected ? "reset" : "speculative"),
    reset: "default"
  }[local.mode])

  next_state = {
    mode: local.next_mode,
    execution_log: contains(["speculative", "reset"], local.next_mode) ? local.execution_log : concat(local.execution_log, [local.next_address]),
    speculative_execution_log: local.next_mode == "speculative" ? concat(local.speculative_execution_log, [local.next_address]) : [],
    non_teminating_addresses: toset(concat(local.non_teminating_addresses, local.next_mode == "reset" ? local.speculative_execution_log : []))
  }

  executed_addresses = [for address in local.total_execution_log: address if address < length(local.instructions)]
  accumulators = [for address in local.executed_addresses:
    parseint(local.instructions[address]["value"], 10) if local.instructions[address]["type"] == "acc"
  ]
}

resource "local_file" "state" {
  content  = (local.done
    ? file("state.json") # If we're done, make sure this is a no-op
    : jsonencode(local.next_state)
  )
  file_permission = "0666"
  filename = "state.json"
}

output "part_2_answer" {
  value = length(local.accumulators) > 0 ? sum(local.accumulators) : 0
}

