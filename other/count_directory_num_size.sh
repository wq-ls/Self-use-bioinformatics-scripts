#!/bin/bash

# Define the output file
output_file="count_size_dir.txt"

# Define the maximum depth (modifiable variable)
max_depth=6

# Clear or create the output file
> "$output_file"

echo "Counting files and their sizes in KB (including hidden files and links, ensuring recursive accumulation beyond max depth) up to depth $max_depth..."

# Function to recursively count files and aggregate counts and sizes up to the parent
function count_files_and_sizes {
  local dir="$1"
  local current_depth="$2"

  # Initialize counters for this directory
  local file_count=0
  local total_size=0

  # Count files and their sizes directly in this directory
  local direct_file_count=$(find "$dir" -maxdepth 1 \( -type f -o -type l \) | wc -l)
  local direct_size=$(find "$dir" -maxdepth 1 \( -type f -o -type l \) -exec du -b {} + | awk '{sum += $1} END {print sum}')
  direct_size=${direct_size:-0}

  # Add direct counts and sizes to the totals
  file_count=$((file_count + direct_file_count))
  total_size=$((total_size + direct_size))

  # If current depth is less than or equal to max depth, process subdirectories
  if [ "$current_depth" -lt "$max_depth" ]; then
    for subdir in "$dir"/* "$dir"/.*; do
      if [ -d "$subdir" ] && [ "$subdir" != "$dir/." ] && [ "$subdir" != "$dir/.." ] && [ ! -L "$subdir" ]; then
        # Recursively get file counts and sizes from subdirectories
        local sub_count_and_size=$(count_files_and_sizes "$subdir" $((current_depth + 1)))
        local sub_count=$(echo "$sub_count_and_size" | awk '{print $1}')
        local sub_size=$(echo "$sub_count_and_size" | awk '{print $2}')
        file_count=$((file_count + sub_count))
        total_size=$((total_size + sub_size))
      fi
    done
  elif [ "$current_depth" -eq "$max_depth" ]; then
    # If at max depth, include all files recursively from this point
    local deeper_count=$(find "$dir" -type f -o -type l | wc -l)
    local deeper_size=$(find "$dir" -type f -o -type l -exec du -b {} + | awk '{sum += $1} END {print sum}')
    deeper_size=${deeper_size:-0}
    file_count=$((file_count + deeper_count))
    total_size=$((total_size + deeper_size))
  fi

  # Convert size to KB
  local total_size_mb=$(echo "scale=2; $total_size / 1024" | bc)

  # Output this directory
  local abs_path=$(realpath "$dir")
  echo -e "$file_count\t$total_size_mb\t$abs_path" >> "$output_file"

  # Return the file count and total size for this directory
  echo "$file_count $total_size"
}

# Start counting from the current directory with an initial depth of 1
count_files_and_sizes "." 1

echo "Counting completed. Results are saved in $output_file."
