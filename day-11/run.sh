#!/usr/bin/env bash

set -eu

steps=0
output_file=$(mktemp -t aoc-terraform-output)
while ! grep -F 'Apply complete! Resources: 0 added, 0 changed, 0 destroyed.' "$output_file"
do
  time terraform apply -auto-approve | tee "$output_file"
  steps=$((steps + 1))
  echo "(Step $steps)"
done

echo "Completed in $steps steps"

