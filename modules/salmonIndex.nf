process salmonIndex {
    input:
        path(reference_genome)

    output:
        path("salmon_index"), emit: index_dir

    script:
        """
        salmon index -t $reference_genome -p ${NSLOTS} -i salmon_index
        """
}
