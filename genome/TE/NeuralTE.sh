#!/bin/bash
source activate /micromamba/envs/NeuralTE

input=TIR.fa
outdir=$PWD/out_NeuralTE
threads_num=10

python /01_soft/NeuralTE-master/src/Classifier.py \
 --data ${input} \
 --model_path /01_soft/NeuralTE-master/models/NeuralTE_model.h5 \
 --outdir ${outdir} \
 --use_gpu_num 0 \
 --is_plant 0 \
 --thread ${threads_num}
