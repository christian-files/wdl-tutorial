version 1.0

## This workflow is designed for demonstration purpose only!

############
# Workflow #
############

workflow BWA {
    input {
        String sample_name
        File r1fastq
        File r2fastq
        File ref_fasta
        File ref_fasta_amb
        File ref_fasta_sa
        File ref_fasta_bwt
        File ref_fasta_ann
        File ref_fasta_pac
    }

    call align {
        input:
            sample_name = sample_name,
            r1fastq = r1fastq,
            r2fastq = r2fastq,
            ref_fasta = ref_fasta,
            ref_fasta_amb = ref_fasta_amb,
            ref_fasta_sa = ref_fasta_sa,
            ref_fasta_bwt = ref_fasta_bwt,
            ref_fasta_ann = ref_fasta_ann,
            ref_fasta_pac = ref_fasta_pac
        }
    
    call sort {
        input:
            sample_name = sample_name,
            infile = align.out
    }
}

#########
# Tasks # 
#########

task align {
    input {
        String sample_name
        File r1fastq
        File r2fastq
        File ref_fasta
        File ref_fasta_amb
        File ref_fasta_sa
        File ref_fasta_bwt
        File ref_fasta_ann
        File ref_fasta_pac
        Int threads
    }

    command {
        bwa mem -M -t ${threads} ${ref_fasta} ${r1fastq} ${r2fastq} > ${sample_name}.sam
    }

    runtime {
        cpu: threads
        memory: "16GB"
    }

    output {
        File out = "${sample_name}.sam"
    }
}


task sort{
    input {
        String sample_name
        File infile
    }

    command <<<
        java -jar picard.jar \
            sort \
            I=${infile} \
            O=${sample_name}.sorted.bam \
            SORT_ORDER=coordinate \
            CREATE_INDEX=true
    >>>

    output {
        File outbam = "${sample_name}.sorted.bam"
        File outbamidx = "${sample_name}.sorted.bai"
    }
}