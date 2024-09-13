#!/bin/bash

input=$1
input_without_extension="${input%.*}"
extension=".${input##*.}"
output="${input_without_extension}-compressed${extension}"
# Size savings max out around 6 (5 iterations), but the color changes slightly.
# The color change is subjectively nice.
# Simply rotating 360 degrees keeps the color close enough.
num_iterations=2
angle=0
# output_file="${input_without_extension}_sizes.txt"

bytes_to_megabytes() {
    local bytes=$1
    echo "$(bc -l <<< "scale=2; $bytes/1048576")"
}

input_size=$(stat -f%z "$input")
input_size_mb=$(bytes_to_megabytes "$input_size")
# echo "$input_size" >> "$output_file"

sips -r 90 "$input" --out "$output" &> /dev/null
angle=$((angle+90))

for ((i=1; i<=num_iterations; i++))
do
  sips -r 90 "$output" --out "$output" &> /dev/null
  angle=$((angle+90))

  if [[ $angle -eq 360 ]]; then
    angle=0
  fi
done

sips -r $((360 - angle)) "$output" --out "$output" &> /dev/null

output_size=$(stat -f%z "$output")
output_size_mb=$(bytes_to_megabytes "$output_size")
# echo "$output_size" >> "$output_file"

size_saved=$((input_size - output_size))
size_saved_mb=$(bytes_to_megabytes "$size_saved")

echo "Input size: $input_size_mb MB"
echo "Output size: $output_size_mb MB"
echo "Diff: $size_saved_mb MB"
