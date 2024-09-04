## https://github.com/Gardner-BinfLab/Razor
#micromamba activate py36

source activate /home_micromamba/envs/py36

input_pep=ABCD.pep
output_txt=Razor
cpu=10
max_scan_length=80

[ -d libs ] || ln -s /01_soft/Razor/libs/

python /01_soft/Razor/razor.py --fastafile ${input_pep} --output ${output_txt} --maxscan ${max_scan_length} --ncores ${cpu}

rm libs
