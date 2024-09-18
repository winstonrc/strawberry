#!/bin/bash

debug=false
input=""
num_iterations=2
angle=0

show_help() {
    echo "Usage: ./strawberry.sh [options] <input_file>"
    echo "Options:"
    echo "  -d, --debug    Enable debug mode"
    echo "  -h, --help     Display this help message"
}

usage() {
    echo "Usage: $0 [options] <input_file>"
    echo "Options:"
    echo "  -d, --debug    Enable debug mode"
    exit 1
}

# Check if any arguments are passed
if [ $# -eq 0 ]; then
    echo "No arguments provided."
    show_help
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--debug)
            debug=true
            shift
            ;;
        -h|--help)
        usage
        exit 0
        ;;
    -*)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    *)
        if [ -z "$input" ]; then
            input="$1"
        else
            echo "Error: Too many arguments." >&2
            usage
            exit 1
        fi
        shift
        ;;
    esac
done

if [ -z "$input" ]; then
    echo "Error: A picture input file must be provided." >&2
    usage
fi

input_without_extension="${input%.*}"
extension=".${input##*.}"
output="${input_without_extension}-compressed${extension}"

bytes_to_megabytes() {
    local bytes=$1
    echo "$(bc -l <<< "scale=2; $bytes/1048576")"
}

input_size=$(stat -f%z "$input")
input_size_mb=$(bytes_to_megabytes "$input_size")

if [ "$debug" = true ]; then
    output_file="${input_without_extension}_sizes.txt"
    echo "$input_size" > "$output_file"
fi

sips -r 90 "$input" --out "$output" &> /dev/null
angle=$((angle+90))

for ((i=1; i<=num_iterations; i++))
do
    sips -r 90 "$output" --out "$output" &> /dev/null
    angle=$((angle+90))
    if [[ $angle -eq 360 ]]; then
        angle=0
    fi
    # Write size to file
    if [ "$debug" = true ]; then
        current_size=$(stat -f%z "$output")
        echo "$current_size" >> "$output_file"
    fi
done

sips -r $((360 - angle)) "$output" --out "$output" &> /dev/null

output_size=$(stat -f%z "$output")
output_size_mb=$(bytes_to_megabytes "$output_size")

if [ "$debug" = true ]; then
    echo "$output_size" >> "$output_file"
fi

size_saved=$((input_size - output_size))
size_saved_mb=$(bytes_to_megabytes "$size_saved")

# Overwrite original input once the output has completed
mv $output $input

echo "Input size: $input_size_mb MB"
echo "Output size: $output_size_mb MB"
echo "Diff: $size_saved_mb MB"
