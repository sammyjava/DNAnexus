#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

mark-section "running gzip"

#
# Stream input with "dx cat", decompress with gzip, stream output with "dx upload"
#
dx cat "$file" | gunzip | dx upload -o "$file_prefix" --brief - >.file.id
dx-jobutil-add-output file $(<.file.id)

mark-success
