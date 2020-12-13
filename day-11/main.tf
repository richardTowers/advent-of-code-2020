locals {
  input = trimspace(fileexists("output.txt") ? file("output.txt") : file("input.txt"))
  cells = [for row in split("\n", local.input): [for col in split("", row): col]]

  surrounding_coords = [
    [-1,-1],
    [-1, 0],
    [-1, 1],
    [ 0,-1],
    [ 0, 1],
    [ 1,-1],
    [ 1, 0],
    [ 1, 1],
  ]

  neighbour_counts = [for i, row in local.cells:
    [for j, cell in row:
      length([for coord in [for coord in local.surrounding_coords: coord
        if i + coord[0] >= 0
        && j + coord[1] >= 0
        && i + coord[0] < length(local.cells)
        && j + coord[1] < length(row)
      ]: 1 if local.cells[i + coord[0]][j + coord[1]] == "#"])
    ]
  ]

  next_cells = [for i, row in local.cells:
    [for j, cell in row:
      (cell == "L"
        ? (local.neighbour_counts[i][j] == 0 ? "#" : cell)
        : (cell == "#"
          ? (local.neighbour_counts[i][j] >= 4 ? "L" : cell)
          : (".") # Floor cells never change
        )
      )
    ]
  ]
}

resource "local_file" "output" {
  content  = join("\n", [for row in local.next_cells: join("", row)])
  file_permission = "0666"
  filename = "output.txt"
}

output "neighbour_counts" {
  value = join("\n", [for row in local.neighbour_counts: join("", row)])
}

output "part_1_answer" {
  value = length(flatten([for row in local.next_cells: [for cell in row: cell if cell == "#" ]]))
}

