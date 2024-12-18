#!/bin/bash
source activate /01_soft/mamba/envs/TEsorter

input=confident_TE.cons_valid.fa
cpu=5

TEsorter ${input} -p ${cpu} -rule 70-50-50
mkdir TEsorter_out
mv ${input}.rexdb* TEsorter_out
