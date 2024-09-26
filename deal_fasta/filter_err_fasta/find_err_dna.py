
import sys
from Bio import SeqIO

def check_dna_sequences(fasta_file):
    # Define legal DNA/RNA character sets
    valid_chars = set("ATCGatcg")

    with open(fasta_file, "r") as file:
        for record in SeqIO.parse(file, "fasta"):
            sequence = str(record.seq)
            invalid_chars = [char for char in sequence if char not in valid_chars]
            if invalid_chars:
                print(f">{record.id}")
                print(f"{sequence}")
#                print(f"Illegal_character: {set(invalid_chars)}")
#                print("-" * 40)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_fasta_file>")
        sys.exit(1)

    fasta_file_path = sys.argv[1]
    check_dna_sequences(fasta_file_path)
