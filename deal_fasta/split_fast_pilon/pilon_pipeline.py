#!/usr/bin/env python3
import os
import subprocess
import argparse
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed

def get_chromosome_lengths(fasta):
    lengths = {}
    # Use samtools to index the fasta file
    subprocess.run(['samtools', 'faidx', fasta], check=True)
    # Read the .fai file to get chromosome names and lengths
    with open(fasta + '.fai', 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            chrom = parts[0]
            length = int(parts[1])
            lengths[chrom] = length
    return lengths

def partition_chromosomes(lengths, n_parts):
    total_length = sum(lengths.values())
    target_length = total_length / n_parts

    partitions = defaultdict(list)
    current_lengths = [0] * n_parts

    # Sort chromosomes by length in descending order
    sorted_chroms = sorted(lengths.items(), key=lambda x: x[1], reverse=True)

    for chrom, length in sorted_chroms:
        # Assign chromosome to the partition with the smallest total length
        idx = current_lengths.index(min(current_lengths))
        partitions[idx].append(chrom)
        current_lengths[idx] += length

    return partitions

def run_commands(cmd_list):
    for cmd in cmd_list:
        print('Running command:', ' '.join(cmd))
        subprocess.run(cmd, check=True)

def process_partition(args):
    idx, chroms, genome, reads1, reads2, fix_option, output_dir = args
    part_name = f'part_{idx+1}'
    part_dir = os.path.join(output_dir, part_name)
    os.makedirs(part_dir, exist_ok=True)

    # Create sub-genome fasta file
    part_fasta = os.path.join(part_dir, f'{part_name}.fasta')
    with open(part_fasta, 'w') as out_fasta:
        for chrom in chroms:
            cmd = ['samtools', 'faidx', genome, chrom]
            seq = subprocess.check_output(cmd).decode()
            out_fasta.write(seq)

    # Build bwa index for sub-genome
    run_commands([
        ['bwa', 'index', part_fasta]
    ])

    # Align reads with bwa mem
    sam_file = os.path.join(part_dir, f'{part_name}.sam')
    run_commands([
        ['bwa', 'mem', '-t', '5', part_fasta, reads1, reads2, '-o', sam_file]
    ])

    # Process alignment results with samtools
    bam_file = os.path.join(part_dir, f'{part_name}_sorted.bam')
    unsorted_bam = bam_file.replace('_sorted.bam', '.bam')
    run_commands([
        ['samtools', 'view', '-bS', '-q 10', '-F 12', '-@ 5', sam_file, '-o', unsorted_bam],
        ['samtools', 'sort', '-o', bam_file, unsorted_bam],
        ['samtools', 'index', bam_file]
    ])

    # Run Pilon
    pilon_output_prefix = os.path.join(part_dir, f'{part_name}_pilon')
    pilon_output_fasta = pilon_output_prefix + '.fasta'
    run_commands([
        ['pilon',
         '--genome', part_fasta,
         '--frags', bam_file,
         '--output', pilon_output_prefix,
         '--vcf',
         '--fix', fix_option,
         '--changes']
    ])

    return pilon_output_fasta

def main():
    parser = argparse.ArgumentParser(description='Split genome and process with bwa and pilon')
    parser.add_argument('--genome', required=True, help='Input genome fasta file')
    parser.add_argument('--reads1', required=True, help='Forward reads file')
    parser.add_argument('--reads2', required=True, help='Reverse reads file')
    parser.add_argument('--parts', type=int, default=2, help='Number of parts to split the genome into')
    parser.add_argument('--fix', default='all', help='Fix option for pilon (default: all)')
    parser.add_argument('--output', default='output', help='Output directory')
    args = parser.parse_args()

    genome = args.genome
    reads1 = args.reads1
    reads2 = args.reads2
    n_parts = args.parts
    fix_option = args.fix
    output_dir = args.output

    os.makedirs(output_dir, exist_ok=True)

    # Step 1: Get chromosome lengths
    lengths = get_chromosome_lengths(genome)

    # Step 2: Partition chromosomes
    partitions = partition_chromosomes(lengths, n_parts)

    pilon_outputs = []

    # Run processing in parallel
    with ThreadPoolExecutor(max_workers=n_parts) as executor:
        futures = []
        for idx, chroms in partitions.items():
            args_tuple = (idx, chroms, genome, reads1, reads2, fix_option, output_dir)
            futures.append(executor.submit(process_partition, args_tuple))

        for future in as_completed(futures):
            try:
                pilon_output_fasta = future.result()
                pilon_outputs.append(pilon_output_fasta)
            except Exception as e:
                print(f'Error processing partition: {e}')

    # Merge pilon output fasta files
    merged_genome = os.path.join(output_dir, 'merged_genome.fasta')
    with open(merged_genome, 'w') as outfile:
        for fasta in pilon_outputs:
            with open(fasta, 'r') as infile:
                outfile.write(infile.read())

    print('Processing complete! Merged genome file:', merged_genome)

if __name__ == '__main__':
    main()
