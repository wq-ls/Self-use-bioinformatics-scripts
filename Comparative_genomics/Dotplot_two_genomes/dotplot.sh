minimap2 -t 40 -x asm5 hcs_chr-genome.fa fcs_chr-genome.fa > hcs_fcs.paf

### pafCoordsDotPlotly.R need Rpackage optparse  ggplot2   plotly

pafCoordsDotPlotly.R -i hcs_fcs.paf -o hcs_fcs.paf -m 1000 -q 1000 -s -t -l -p 16
