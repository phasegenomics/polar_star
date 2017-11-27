
configfile: "config.json"

RG = "'@RG\\tID:" + config['lib'] + "\\tSM:" + config['name'] + "'"
print("Read Group:", RG)

FASTQ = config["fastq_names"].split(",")
print("Fastqs:", FASTQ)

ALN_CMD = "minimap2/minimap2 " + config['opts'] + " -t " + config['threads'] 

AUX_THREADS = int(config['threads']) - 1

SAMPLES=config['name']

ruleorder: sortBam > makeBam

rule dummy:
     input: expand("{sample}.read.depth.smooth.txt", sample=SAMPLES)

rule smoother:
     message : "[INFO] smoothing read depth"
     input   : DEPTH="{sample}.read.depth.txt", SMOOTHER="vcflib/bin/smoother"
     output  : "{sample}.read.depth.smooth.txt"
     shell   : """
     	          {input.SMOOTHER} -o col3 -w 100 -s 100 -t -f {input.DEPTH} > {output}
     """


rule meanDepth:
     message: "[INFO] getting read depth."
     input  : SORTED_BAM="{sample}.sort.bam", ST="samtools/samtools"
     output : "{sample}.read.depth.txt"
     shell  : """
     	    {input.ST} depth -aa {input.SORTED_BAM} >  {output}
     """
     
rule sortBam:
     message: "[INFO] sorting BAM."
     input  : BAM="{sample}.bam", ST="samtools/samtools"
     output : protected("{sample}.sort.bam")
     shell  : """
            {input.ST} sort -@ {AUX_THREADS} {input.BAM} -o {output}
     """  

rule makeBam:
     message: "[INFO] converting sam to bam."
     input  :  SAM="{sample}.sam", ST="samtools/samtools"
     output :  temp("{sample}.bam")
     shell  : """
     	   {input.ST} view -bS -@ {AUX_THREADS} {input.SAM} > {output}
     """

rule makeSam:
     message: "[INFO] running alignment."
     input  : FA=config["fasta_name"], MM="minimap2/minimap2", FQ=FASTQ
     output : temp("{sample}.sam")
     shell  : """
          {ALN_CMD} {input.FA} {input.FQ} > {output}
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

rule vcflib:
     message: "[INFO] installing vcflib"
     output : "vcflib/bin/smoother"
     shell  : """
     	    git clone --recursive https://github.com/vcflib/vcflib.git
     	    cd vcflib
	    git checkout b17eed65ed6b40f1244c4f09ae86800e9ae9a1d6
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