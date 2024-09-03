### https://github.com/zengxiaofei/HapHiC

micromamba activate haphic

export PATH="/01_soft/HapHiC/:$PATH"
export PATH="/01_soft/HapHiC/utils/:$PATH"

agp=chr.fa.agp
matrix=contact_matrix.pkl
cpu=30
bin_size=1000		## bin size for generating contact matrix, default: 500 (kbp)
cmap=viridis		## define the colormap for the heatmap, default: white,red. It can be any built-in sequential colormap from Matplotlib (refer to:
			## https://matplotlib.org/stable/users/explain/colors/colormaps.html). You can create a custom colormap by listing colors separated by commas
normalization=KR	## method for matrix normalization, default: KR {KR,log10,none}
ncols=5			## number of scaffolds per row in `separate_plots.pdf`, default: 5
origin=top_left		## set the origin of each heatmap, default: bottom_left {bottom_left,top_left,bottom_right,top_right}
border_style=outline	## border style for scaffolds, default: grid {grid,outline}
figure_width=15		## figure width, default: 15 (cm)
figure_height=12	## figure height, default: 12 (cm)
# specified_scaffolds=
# min_len=
# vmax_coef=
# manual_vmax=
# separate_plots	## generate `separate_plots.pdf`, depicting the heatmap for each scaffold individually, default: False

haphic plot ${agp} ${matrix} --bin_size ${bin_size} --cmap ${cmap} --normalization ${normalization} --ncols ${ncols} --origin ${origin} --border_style ${border_style} --figure_width ${figure_width} --figure_height ${figure_height} --threads ${cpu}
