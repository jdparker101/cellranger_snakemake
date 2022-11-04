import os
from touch import touch

configfile: "config.yaml"

SampleList=[]
samplefile=open(config["rawdatadir"]+"/SampleSheet.csv")
for line in samplefile:
    if "BN" in line:
        SampleList.append(line.split(",")[1])

rule all:
    input:
        expand("count_stamps/{sample}.count", sample=SampleList)

rule mkannotations:
    input:
        config["rawdatadir"]+"/SampleSheet.csv"
    output:
        "annotations.csv"
    shell:
        """python mkannotations.py
        """


rule cellranger_mkfastq:
    input:
        "annotations.csv"
    output:
        expand("mkfastq_stamps/{sample}.mkfastq", sample=SampleList)
    shell:
        """~/bin/cellranger-arc-2.0.1/cellranger-arc mkfastq --id={config[fastqdir]} \
                                                             --run=raw_data_download_GEX/ \
                                                             --csv=annotations.csv \
                                                             --localcores=8 \
                                                             --localmem=64 2> fastq.log
           for samp in $(tail -n{config[samplenum]} annotations.csv | awk -F',' '{{print $2 }}'); do    touch mkfastq_stamps/$samp.mkfastq;  done
        """

rule cellranger_count:
    input:
        "mkfastq_stamps/{sample_id}.mkfastq"
    output:
        "count_stamps/{sample_id}.count"
    shell:
        """cellranger count  --id={wildcards.sample_id} \
                  --transcriptome=/data/neurogen/referenceGenome/Homo_sapiens/cellranger_references/hg38/transcriptome/refdata-gex-GRCh38-2020-A_Ensembl98_DL-2-25-2021/ \
                  --fastqs={config[fastqdir]}/outs/fastq_path/ \
                  --sample={wildcards.sample_id} \
                  --include-introns \
                  --chemistry=ARC-v1
                  --localcores=8 \
                  --localmem=64 2> {wildcards.sample_id}.count.log
        touch {output}
        """

        
