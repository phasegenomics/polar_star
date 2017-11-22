
configfile: "config.json"

RG = "'@RG\\tID:" + config['lib'] + "\\tSM:" + config['name'] + "'"
print("Read Group:", RG)

FASTQ = config["fastq_names"].split(",")
print("Fastqs:", FASTQ)

ALN_CMD = "minimap2/minimap2 " + config['opts'] + " -t " + config['threads'] 

AUX_THREADS = int(config['threads']) - 1

rule all:
     input: expand("{sample}.bam", sample=config['name'])

rule sortBam:
     message: "[INFO] sorting bam."
     input  : "{sample}.bam"
     output : protected("{sample}.sort.bam")
     shell  : """
     	    samtools sort -@ {AUX_THREADS} {input} > {output}      	    
     """
    
rule sam2bam:
     message: "[INFO] converting sam to bam."
     input  :  SAM=expand("{sample}.sam", sample=config['name'])
     output :  temp("{sample}.bam")
     shell  : """
     	    samtools view -bS -@ {AUX_THREADS} {input} > {output}
     """

rule aln:
     message: "[INFO] running alignment."
     input  : FA=config["fasta_name"], MM="minimap2/minimap2"
     output : temp("{sample}.sam")
     shell  : """
          {ALN_CMD} {input.FA} {FASTQ} > {output}
     """

rule samtools:
     message: "[INFO] installing samtools."
     input  : "htslib/libhts.a"
     output : "samtools/samtools"
     shell  : """
               git clone https://github.com/samtools/samtools.git
               cd samtools
               git checkout 6c87075a5d9ded7a65a7c0847e7ceb18e09c0bb0
	       autoheader
	       autoconf -Wno-syntax  
	       ./configure
	       make
       	    """

rule htslib:
     message: "[INFO] installing htslib"
     output:  "htslib/libhts.a"
     shell: """
     	    git clone https://github.com/samtools/htslib.git
      	    cd htslib
            git checkout 49fdfbda20acbd73303df3c7fef84f2d972c5f8d
            make
     """

rule golang :
     message: "[INFO] installing gdrive."
     output : "/home/ec2-user/go/bin/gdrive"
     shell  : """
          go get github.com/prasmussen/gdrive
     """


rule minimap2:
     message: "[INFO] installing minimap2."
     output : "minimap2/minimap2"
     shell  : """
     	    git clone https://github.com/lh3/minimap2.git
     	    cd minimap2 
     	    git checkout 39a96662463c3f0dd8c64c70445fc0261721f010
     	    make
     """