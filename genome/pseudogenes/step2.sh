## https://github.com/kelkar/Discover_pseudogenes

protein=use.pep
cds=use.cds
genome=genome.mask.for_anno.fa.cut/ABCD
output_prefix=pse_ABCD
Percent=60

[ -d TMP ] || mkdir TMP

### step1
exonerate --percent ${Percent} --model protein2genome --showquerygff yes --showtargetgff yes -q ${protein} -t ${genome} --ryo "RYO\t%qi\t%ti\t%ql\t%tl\t%qal\t%qab\t%qae\t%tal\t%tab\t%tae\t%et\t%ei\t%es\t%em\t%pi\t%ps\t%g\nTransitionStart\n%V{%Pqs\t%Pts\t%Pqb\t%Pqe\t%Ptb\t%Pte\t%Pn\t%Pl\n}TransitionEnd\nTargetSeq\n%qs\nAligned Sequences\n>Q\n%qas\n>T\n%tas\nCoding Sequences\n>Q\n%qcs\n>T\n%tcs\n" > TMP/${output_prefix}.exonerate.txt

### step2
grep -P "Query:|Target:|(Query range:)|(Target range:)|(^[A-Z]\tTAA\t)|(\sframeshift\s)|(^[A-Z]\tTAG\t)|(^[A-Z]\tTGA\t)|(^\*)"  TMP/${output_prefix}.exonerate.txt > TMP/${output_prefix}.exonerate.erros.txt

### step3
perl /exonerate-2.2.0-x86_64/bin/Exonerate_to_evm_gff3.pl TMP/${output_prefix}.exonerate.txt > TMP/${output_prefix}.exonerate.gff

### step4
perl /exonerate-2.2.0-x86_64/bin/tabulate_stops_frameshifts.pl ${cds} TMP/${output_prefix}.exonerate.gff TMP/${output_prefix}.exonerate.erros.txt > TMP/${output_prefix}.pseudogenes.txt
