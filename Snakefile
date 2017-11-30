
configfile: "config.json"

RG = "'@RG\\tID:" + config['lib'] + "\\tSM:" + config['name'] + "'"
print("Read Group:", RG)

FASTQ = config["fastq_names"].split(",")
print("Fastqs:", FASTQ)

ALN_CMD = "minimap2/minimap2 " + config['opts'] + " -t " + config['threads'] 

AUX_THREADS = int(config['threads']) - 1

SAMPLES=config['name']

ruleorder: sortBam > makeBam

rule wrappingUp  :
     input  : RESULT=expand("{sample}.new_fasta.fasta", sample=SAMPLES), BED=expand("{sample}.broken.sorted.bed", sample=SAMPLES)
     message: "[INFO] getting fasta"
     output : "RESULTS.tar.gz"
     shell  : """
     	    cat {input.BED} | perl scripts/summary.pl > REPORT.txt 2> MATLOCK_EXCLUDE_LIST.txt
	    
	    cp config.json config.json.bk
	    
	    tar -cvf RESULTS.tar.gz REPORT.txt MATLOCK_EXCLUDE_LIST.txt {input.RESULT} {input.BED} docs/README.md config.json.bk
     """     

rule getFasta:
     message: "[INFO] getting fasta"
     input  : BF="{sample}.broken.bed", BT="bedtools2/bin/bedtools", FA=config["fasta_name"],  ST="samtools/samtools"
     output : RFA="{sample}.new_fasta.fasta", BD="{sample}.broken.sorted.bed"
     shell  : """
     	    sort -k1,1 -k2,2n {input.BF} > {output.BD}
	    {input.BT} getfasta -name -fi {input.FA} -fo {output.RFA} -bed {output.BD}
	    {input.ST} faidx {output.RFA}
	    

          """ 	
     


rule lowdepth:
     message: "[INFO] finding low depth regions: <= %s" % config['low_depth']
     input  : MEAN="{sample}.read.depth.smooth.mean.txt", SMOOTHED="{sample}.read.depth.smooth.txt", BT="bedtools2/bin/bedtools"
     output : "{sample}.broken.bed"
     params : LOW=config['low_depth'], MULT=config['times_mean']
     shell  : """
     	    cat {input.SMOOTHED} | perl -lane 'print if $F[4] <= {params.LOW}' | {input.BT} merge  -c 5 -o collapse -i - | perl -lane '$F[3] = "$F[0]_ld:$F[1]-$F[2]"; print join "\\t", @F' > {output}
	    
	    export HIGH=$(cat {input.MEAN})
	    echo $HIGH	    
	    
	    cat {input.SMOOTHED} | perl -lane 'print if $F[4] >= {params.MULT} * '"$HIGH"';' | {input.BT} merge  -c 5 -o collapse -i - | perl -lane '$F[3] = "$F[0]_hd:$F[1]-$F[2]"; print join "\\t", @F' >> {output}

	      cat {input.SMOOTHED} | perl -lane 'print if ($F[4] < {params.MULT} * '"$HIGH"' ) && ($F[4] > {params.LOW})' |  {input.BT} merge  -c 5 -o collapse -i - | perl -lane '$F[3] = "$F[0]_nd:$F[1]-$F[2]"; print join "\\t", @F' >> {output}

     """

rule meanSmooth:
     message : "[INFO] calculating mean depth"
     input   : "{sample}.read.depth.smooth.txt"
     output  : "{sample}.read.depth.smooth.mean.txt" 
     shell   : """
     	       cat {input} | perl scripts/mean.pl > {output}
          """

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
               git checkout f4dc22aa25f0d2a7a09b5d8a8299f6749ef4fcda
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
            git checkout 746549da5371c7689ebd81f693c9bd10aa984623
            make
     """

rule vcflib:
     message: "[INFO] installing vcflib"
     output : "vcflib/bin/smoother"
     shell  : """
     	    rm -rf vcflib
     	    git clone --recursive https://github.com/vcflib/vcflib.git
     	    cd vcflib
	    git checkout b17eed65ed6b40f1244c4f09ae86800e9ae9a1d6
	    make
     """
     

rule gdrive :
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

rule bedtools2:
     message: "[INFO] installing bedtools2"
     output: "bedtools2/bin/bedtools"
     shell: """
     	    rm -rf bedtools2
     	    git clone https://github.com/arq5x/bedtools2.git
	    cd bedtools2
	    git checkout f3bc2435d6ec41dfaff148a18034d4610439aa6a
	    make
          """     
