process bbduk {
    input:
	tuple val(run), path(fastq_read_list), val(ref_files)
    output:
        tuple val(run), path("trimmed_*"), path("${run}.refstats"), path("${run}.stats")
    script:
	ref_args = ref_files.join(",")
        if( fastq_read_list.size() == 2 ) {
            """
            echo "Running BBduk in Paired-End mode"
            bbduk.sh threads=${NSLOTS} in1=${fastq_read_list[0]} in2=${fastq_read_list[1]} \
                     out1=trimmed_${fastq_read_list[0]} out2=trimmed_${fastq_read_list[1]} \
		     refstats=${run}.refstats stats=${run}.stats \
		     ref=${ref_args} \
		     forcetrimleft=11 forcetrimright2=3 minlength=80 qtrim=w trimq=20 tpe=t tbo=t
            """
        }
        else if( fastq_read_list.size() == 1 ) {
            """
            echo "Running BBduk in Single-End mode"
            bbduk.sh threads=${NSLOTS} in=${fastq_read_list[0]} out=trimmed_${fastq_read_list[0]} \
                     ref=adapters,artifacts ktrim=r k=23 mink=11 hdist=1
            """
        }
        else {
            """
            echo "Error: Unexpected number of fastq files"
            """
        }
}

