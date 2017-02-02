#!/bin/bash

# This script removes all ASCII punkctuation from $1 and writes the result to $2
_input_file="${1:-/dev/null}"
_output_file="${2:-/dev/null}"
cat "$_input_file" | tr -d '[:punct:]' > "$_output_file"