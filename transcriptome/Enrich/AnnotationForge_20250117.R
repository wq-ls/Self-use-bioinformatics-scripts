#!/01_software/miniconda3/envs/R-4.0/bin/Rscript

### https://www.jianshu.com/p/45f1e8c9b79c

### help doc
library(optparse)
option_list <- list(
    make_option(c("-v", "--info"), type = "character", default=F, metavar="info",
                help="Building non-model object Orgdb packages.\n\t\t!!! Example: ./AnnotationForge.R -i eggNog.anno.txt -a LS -m shiyeyishang@outlook.com -g Cynoglossus -s se -d 244447 !!!"),
    make_option(c("-i", "--input"), type = "character", default=NULL,
                help="annotation from eggNOG"),
    make_option(c("-a", "--author"), type="character", default=NULL,
                help="author"),
    make_option(c("-m", "--mail"), type="character", default=NULL,
                help="e-mail"),
    make_option(c("-g", "--genus"), type="character", default=NULL,
                help="genus"),
    make_option(c("-s", "--species"), type="character", default=NULL,
                help="species"),
    make_option(c("-d", "--taxid"), type="character", default=NULL,
                help="Taxonomy ID from NCBI")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input)){
  print_help(opt_parser)}

infile = opt$input
author_name = opt$author
e_mail = opt$mail
Genus = opt$genus
Species = opt$species
Taxid = opt$taxid

library(tidyverse)
library(AnnotationForge)
emapper <- read.delim(infile) %>%
#  mutate(Description = if_else(Description != "-", Description, PFAMs)) %%
  dplyr::select(GID = query, Gene_Symbol = Preferred_name,
                GO = GOs, KO = KEGG_ko, Pathway = KEGG_Pathway,
                OG = eggNOG_OGs, Gene_Name = Description, pfam = PFAMs)

gene_info <- dplyr::select(emapper,GID,Gene_Name) %>%
  dplyr::filter(!is.na(Gene_Name))

gene2go <- dplyr::select(emapper,GID,GO) %>%
  separate_rows(GO, sep = ",", convert = F) %>%
  filter(GO!="NA",!is.na(GO)) %>%
  mutate(EVIDENCE = 'A')

gene2ko<- dplyr::select(emapper,GID,KO) %>%
  separate_rows(KO, sep = ",", convert = F) %>%
  dplyr::filter(KO!="NA",!is.na(KO))

gene2pathway<- dplyr::select(emapper,GID,Pathway) %>%
separate_rows(Pathway, sep = ",", convert = F) %>%
  dplyr::filter(!is.na(Pathway))

gene2symbol<- dplyr::select(emapper,GID,Gene_Symbol) %>%
  dplyr::filter(!is.na(Gene_Symbol))

AnnotationForge::makeOrgPackage(gene_info=gene_info,
                                go=gene2go,
                                ko=gene2ko,
                                pathway=gene2pathway,
                                symbol=gene2symbol,
                                maintainer=e_mail,
                                author=author_name,
                                version="0.1",
                                outputDir=".",
                                tax_id=Taxid,
                                genus=Genus,
                                species=Species,
                                goTable = "go")
