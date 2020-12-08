#!/usr/bin/env bash

set -eu

output_file=$(mktemp -t aoc-terraform-output)
while ! grep -F 'Apply complete! Resources: 0 added, 0 changed, 0 destroyed.' "$output_file"
do
  terraform apply -auto-approve | tee "$output_file"
done

