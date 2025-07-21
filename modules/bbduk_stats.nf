process bbduk_stats {
    input:
        path(refstats_files)
        path(r_script_bbduk)
    
    output:
        path("read_cleaning_results.txt")
    
    script:
        """
        # Process #Reads lines
        grep "#Reads" ${refstats_files.join(' ')} | sed -r 's/:#Reads\\t/\\tInputReads\\t/' | sed 's/.refstats//' > bbduk_stats.txt
        # Process #Mapped lines
        grep "#Mapped" ${refstats_files.join(' ')} | sed -r 's/:#Mapped\\t/\\tMapped\\t/' | sed 's/.refstats//' >> bbduk_stats.txt
        # Process other lines (excluding headers and adapters)
        grep -v "#" ${refstats_files.join(' ')} | grep -v 'adapters      ' | cut -f 1,6 | sed 's/.refstats:/\\t/' >> bbduk_stats.txt
        Rscript ${r_script_bbduk}
        """
}
