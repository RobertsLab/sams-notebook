---
layout: post
title: SNP Characterization - C.bairdi v3.1 Transcriptome Assembly and Day2 DEG Pooled Samples RNAseq Data
date: '2021-10-05 06:45'
tags: 
  - Tanner crab
  - bcftools
  - R project
  - Chionoecetes bairdi
categories: 
  - Tanner Crab RNAseq
---
I previously identified variants across the four Day 2 DEG pooled RNAseq samples (380822, 380823, 380824, 380825) [on 20210909](https://robertslab.github.io/sams-notebook/2021/09/09/SNP-Identification-C.bairdi-Day-2-DEG-Pooled-Samples-Using-bcftools-on-Mox.html) within the `cbai_transcriptome_v3.1` transcriptome assembly. Now, I needed to actually do some analysis on the SNPs for the revisions to the [Tanner crab gene expression paper](https://github.com/RobertsLab/paper-tanner-crab) (GitHub Repo).

I created an R Project and an R Markdown file to perform the analysis:

- [20211005_cbai_SNP_stats](https://github.com/RobertsLab/code/tree/master/r_projects/sam/20211005_cbai_SNP_stats)

The R Markdown file ([20211005_cbai_SNP_stats/20211005_cbai_SNP_stats.Rmd](https://github.com/RobertsLab/code/blob/master/r_projects/sam/20211005_cbai_SNP_stats/20211005_cbai_SNP_stats.Rmd))will allow for complete reproduction of the analysis, including downloading necessary input files, as well as generating the final figure. Dependencies (i.e. external programs for VCF manipulation, R libraries, etc) are detailed at the beginning of the R Markdown file.


---

#### RESULTS

The `knitr` to markdown rendering of the completed R Markdown file is here:

- [20211005_cbai_SNP_stats/20211005_cbai_SNP_stats.md](https://github.com/RobertsLab/code/blob/master/r_projects/sam/20211005_cbai_SNP_stats/20211005_cbai_SNP_stats.md) (GitHub)


Rendering is pasted below:

# Explore and extract SNP data from *C.bairdi* transcritpome assembly v3.1

REQUIRES Linux-based system to run all cells properly; some cells will
not work on Mac OS!

REQUIRES the following programs:

-   [bcftools](https://github.com/samtools/bcftools)

-   [samtools](https://github.com/samtools/samtools)

-   [seqtk](https://github.com/lh3/seqtk)

REQUIRES the following R libraries and dependencies:

-   `goslim_generic.obo` Downloaded from
    <http://geneontology.org/docs/go-subset-guide/>

    -   then i moved it to the R library for GSEABase in the extdata
        folder in addition to using the command here - I think they’re
        both required.

-   `GSEABase` (BioConductor)

-   `tidyverse`

### Display system info

    ## TODAY'S DATE:
    ## Thu 07 Oct 2021 12:54:49 PM PDT
    ## ------------
    ## 
    ## No LSB modules are available.
    ## Distributor ID:  Ubuntu
    ## Description: Ubuntu 20.04.3 LTS
    ## Release: 20.04
    ## Codename:    focal
    ## 
    ## ------------
    ## HOSTNAME: 
    ## computer
    ## 
    ## ------------
    ## Computer Specs:
    ## 
    ## Architecture:                    x86_64
    ## CPU op-mode(s):                  32-bit, 64-bit
    ## Byte Order:                      Little Endian
    ## Address sizes:                   45 bits physical, 48 bits virtual
    ## CPU(s):                          2
    ## On-line CPU(s) list:             0,1
    ## Thread(s) per core:              1
    ## Core(s) per socket:              1
    ## Socket(s):                       2
    ## NUMA node(s):                    1
    ## Vendor ID:                       GenuineIntel
    ## CPU family:                      6
    ## Model:                           165
    ## Model name:                      Intel(R) Core(TM) i9-10885H CPU @ 2.40GHz
    ## Stepping:                        2
    ## CPU MHz:                         2400.007
    ## BogoMIPS:                        4800.01
    ## Hypervisor vendor:               VMware
    ## Virtualization type:             full
    ## L1d cache:                       64 KiB
    ## L1i cache:                       64 KiB
    ## L2 cache:                        512 KiB
    ## L3 cache:                        32 MiB
    ## NUMA node0 CPU(s):               0,1
    ## Vulnerability Itlb multihit:     KVM: Mitigation: VMX unsupported
    ## Vulnerability L1tf:              Not affected
    ## Vulnerability Mds:               Not affected
    ## Vulnerability Meltdown:          Not affected
    ## Vulnerability Spec store bypass: Mitigation; Speculative Store Bypass disabled via prctl and seccomp
    ## Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    ## Vulnerability Spectre v2:        Mitigation; Full generic retpoline, IBPB conditional, IBRS_FW, STIBP disabled, RSB filling
    ## Vulnerability Srbds:             Not affected
    ## Vulnerability Tsx async abort:   Not affected
    ## Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon nopl xtopology tsc_reliable nonstop_tsc cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single ssbd ibrs ibpb stibp fsgsbase tsc_adjust bmi1 avx2 smep bmi2 invpcid rdseed adx smap clflushopt xsaveopt xsavec xgetbv1 xsaves arat flush_l1d arch_capabilities
    ## 
    ## ------------
    ## 
    ## Memory Specs
    ## 
    ##               total        used        free      shared  buff/cache   available
    ## Mem:           54Gi       5.6Gi        43Gi       135Mi       5.3Gi        48Gi
    ## Swap:         2.0Gi          0B       2.0Gi

### User-defined bash variables

Set program paths for your own computer.

Variables are saved to a “dot file” and that file needs to be sourced in
each Bash chunk to have access to the Bash variables across Bash chunks.

    {
    echo "# CPU threads"
    echo 'export threads=8'
    echo ""
    echo "# Programs"
    echo 'export seqtk="/home/sam/programs/seqtk-1.3/seqtk"'
    echo 'export bcftools="/home/sam/programs/bcftools-1.13/bcftools"'
    echo 'export samtools="/home/sam/programs/samtools-1.12/samtools"'
    echo ""
    } > .rvars

### Input/output files variables

    {
    echo "# SNP coverage"
    echo 'export SNP_coverage=10'
    echo ""
    echo "# SNP quality"
    echo 'export SNP_quality=30'
    echo ""

    echo "# Input files"
    echo ""
    echo "## Transcriptome assembly"
    echo 'export orig_fasta_url_dir="https://owl.fish.washington.edu/halfshell/genomic-databank"'
    echo 'export transcriptome_fasta="cbai_transcriptome_v3.1.fasta"'
    echo ""
    echo "## Transcriptome md5 checksum"
    echo 'export transcriptome_fasta_md5="aeec8ffbf8fa44fb1750caee6abaf68a"'
    echo ""
    echo "## Transcriptome GO terms"
    echo 'export cbai_v3_1_GO_url="https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1"'
    echo 'export cbai_v3_1_GO="20200828.cbai_transcriptome_v3.1.fasta.trinotate.go_annotations.txt"'
    echo ""
    echo "## VCF with variant calls"
    echo 'export orig_vcf_url_dir="https://gannet.fish.washington.edu/Atumefaciens/20210909-cbai-bcftools-snp_calling"'
    echo 'export orig_vcf="cbai_v3.1-SNPS.vcf"'
    echo ""

    echo "# Output files"
    echo 'export transcriptome_SNPS_fasta="cbai_transcriptome_v3.1_SNPs-${SNP_quality}Q-${SNP_coverage}x.fasta"'
    echo 'export contigs_list="cbai_v3.1-SNPS_${SNP_quality}Q-${SNP_coverage}x_contig-IDs.txt"'
    echo 'export genes_list="cbai_v3.1-SNPS_${SNP_quality}Q-${SNP_coverage}x_gene-IDs.txt"'
    echo 'export vcf_filtered="cbai_v3.1-SNPS-${SNP_quality}Q-${SNP_coverage}x.vcf"'
    echo 'export genes_GO_list"=cbai_v3.1-SNPS_${SNP_quality}Q-${SNP_coverage}x_GO.tab"'
    echo 'export flattened_GO="cbai_v3_1-SNPS_${SNP_quality}Q-${SNP_coverage}x_GO.flattened-go.txt"'
    echo ""

    echo "# Print formatting"
    echo 'export line="-------------------------------------------------------------------------------------------------"'
    echo ""
    } >> .rvars

### Confirm variables are accessible.

    # Confirm contents of .rvars
    cat .rvars

    # Load contents of .rvars into the environment
    source .rvars

    echo ""

    echo "Confirm variables are accessible."
    echo "Checking the variable \$line:"
    echo "${line}"

    ## # CPU threads
    ## export threads=8
    ## 
    ## # Programs
    ## export seqtk="/home/sam/programs/seqtk-1.3/seqtk"
    ## export bcftools="/home/sam/programs/bcftools-1.13/bcftools"
    ## export samtools="/home/sam/programs/samtools-1.12/samtools"
    ## 
    ## # SNP coverage
    ## export SNP_coverage=10
    ## 
    ## # SNP quality
    ## export SNP_quality=30
    ## 
    ## # Input files
    ## 
    ## ## Transcriptome assembly
    ## export orig_fasta_url_dir="https://owl.fish.washington.edu/halfshell/genomic-databank"
    ## export transcriptome_fasta="cbai_transcriptome_v3.1.fasta"
    ## 
    ## ## Transcriptome md5 checksum
    ## export transcriptome_fasta_md5="aeec8ffbf8fa44fb1750caee6abaf68a"
    ## 
    ## ## Transcriptome GO terms
    ## export cbai_v3_1_GO_url="https://gannet.fish.washington.edu/Atumefaciens/20200828_cbai_trinotate_transcriptome-v3.1"
    ## export cbai_v3_1_GO="20200828.cbai_transcriptome_v3.1.fasta.trinotate.go_annotations.txt"
    ## 
    ## ## VCF with variant calls
    ## export orig_vcf_url_dir="https://gannet.fish.washington.edu/Atumefaciens/20210909-cbai-bcftools-snp_calling"
    ## export orig_vcf="cbai_v3.1-SNPS.vcf"
    ## 
    ## # Output files
    ## export transcriptome_SNPS_fasta="cbai_transcriptome_v3.1_SNPs-${SNP_quality}Q-${SNP_coverage}x.fasta"
    ## export contigs_list="cbai_v3.1-SNPS_${SNP_quality}Q-${SNP_coverage}x_contig-IDs.txt"
    ## export genes_list="cbai_v3.1-SNPS_${SNP_quality}Q-${SNP_coverage}x_gene-IDs.txt"
    ## export vcf_filtered="cbai_v3.1-SNPS-${SNP_quality}Q-${SNP_coverage}x.vcf"
    ## export genes_GO_list"=cbai_v3.1-SNPS_${SNP_quality}Q-${SNP_coverage}x_GO.tab"
    ## export flattened_GO="cbai_v3_1-SNPS_${SNP_quality}Q-${SNP_coverage}x_GO.flattened-go.txt"
    ## 
    ## # Print formatting
    ## export line="-------------------------------------------------------------------------------------------------"
    ## 
    ## 
    ## Confirm variables are accessible.
    ## Checking the variable $line:
    ## -------------------------------------------------------------------------------------------------

### Get VCF

    # Load contents of .rvars into the environment
    source .rvars

    # Download with wget. Use --no-check-certificate to avoid issues with Gannet certificate
    # Use --quiet option to prevent wget output from printing too many lines to notebook
    wget --continue --no-check-certificate --quiet ${orig_vcf_url_dir}/${orig_vcf} \
    --directory-prefix ./data

    wget --continue --no-check-certificate --quiet ${orig_vcf_url_dir}/checksums.md5 \
    --directory-prefix ./data

    # Confirm checksum for transcriptome FastA is good
    cd ./data
    md5sum --check checksums.md5 | grep "${orig_vcf}"

    ## md5sum: 20210909-cbai-bcftools-snp_calling.sh: No such file or directory
    ## md5sum: input_bam_checksums.md5: No such file or directory
    ## md5sum: slurm-2194047.out: No such file or directory
    ## md5sum: WARNING: 3 listed files could not be read
    ## cbai_v3.1-SNPS.vcf: OK

### Get transcriptome

    # Load contents of .rvars into the environment
    source .rvars

    # Download with wget. Use --no-check-certificate to avoid issues with Gannet certificate
    # Use --quiet option to prevent wget output from printing too many lines to notebook
    wget --continue --no-check-certificate --quiet ${orig_fasta_url_dir}/${transcriptome_fasta} \
    --directory-prefix ./data


    # Confirm checksum for transcriptome FastA is good
    # Uses grep to highlight the desired file.
    if [ "$(md5sum ./data/${transcriptome_fasta} | awk '{print $1}')" = "${transcriptome_fasta_md5}" ]; then echo "Checksums match"; fi

    ## Checksums match

### Get transcriptome GO annotations file

    # Load contents of .rvars into the environment
    source .rvars

    # Download with wget. Use --no-check-certificate to avoid issues with Gannet certificate
    # Use --quiet option to prevent wget output from printing too many lines to notebook
    wget --continue --no-check-certificate --quiet ${cbai_v3_1_GO_url}/${cbai_v3_1_GO} \
    --directory-prefix ./data

    echo ""

    head ./data/${cbai_v3_1_GO}

    ## 
    ## TRINITY_DN100045_c0_g1   GO:0000323,GO:0001508,GO:0002027,GO:0003279,GO:0003283,GO:0003674,GO:0005198,GO:0005200,GO:0005488,GO:0005515,GO:0005575,GO:0005739,GO:0005764,GO:0005768,GO:0005769,GO:0005773,GO:0005829,GO:0005856,GO:0005886,GO:0005911,GO:0006810,GO:0006811,GO:0006812,GO:0006816,GO:0006873,GO:0006874,GO:0006875,GO:0006888,GO:0006897,GO:0006937,GO:0006942,GO:0007009,GO:0007043,GO:0007154,GO:0007165,GO:0008016,GO:0008092,GO:0008104,GO:0008150,GO:0009893,GO:0009987,GO:0010033,GO:0010468,GO:0010522,GO:0010604,GO:0010628,GO:0010646,GO:0010880,GO:0010881,GO:0010882,GO:0010927,GO:0010959,GO:0014704,GO:0015031,GO:0015833,GO:0016020,GO:0016043,GO:0016192,GO:0016323,GO:0016324,GO:0019222,GO:0019722,GO:0019725,GO:0019899,GO:0019900,GO:0019901,GO:0019932,GO:0022607,GO:0022898,GO:0023051,GO:0023052,GO:0030001,GO:0030003,GO:0030018,GO:0030054,GO:0030315,GO:0030507,GO:0030674,GO:0030913,GO:0031410,GO:0031430,GO:0031647,GO:0031672,GO:0031982,GO:0032409,GO:0032411,GO:0032412,GO:0032414,GO:0032501,GO:0032502,GO:0032844,GO:0032879,GO:0032970,GO:0033036,GO:0033267,GO:0033292,GO:0033365,GO:0034329,GO:0034330,GO:0034394,GO:0034613,GO:0034762,GO:0034764,GO:0034765,GO:0034767,GO:0035556,GO:0035637,GO:0036309,GO:0036371,GO:0042221,GO:0042383,GO:0042391,GO:0042592,GO:0042886,GO:0043034,GO:0043194,GO:0043226,GO:0043227,GO:0043228,GO:0043229,GO:0043231,GO:0043232,GO:0043266,GO:0043268,GO:0043269,GO:0043270,GO:0044057,GO:0044093,GO:0044291,GO:0044325,GO:0044422,GO:0044424,GO:0044425,GO:0044444,GO:0044449,GO:0044456,GO:0044459,GO:0044463,GO:0044464,GO:0044699,GO:0044700,GO:0044707,GO:0044763,GO:0044767,GO:0044802,GO:0045121,GO:0045184,GO:0045211,GO:0045216,GO:0046907,GO:0048193,GO:0048518,GO:0048522,GO:0048646,GO:0048856,GO:0048878,GO:0050789,GO:0050794,GO:0050801,GO:0050821,GO:0050896,GO:0051049,GO:0051050,GO:0051117,GO:0051179,GO:0051234,GO:0051239,GO:0051270,GO:0051279,GO:0051282,GO:0051597,GO:0051641,GO:0051649,GO:0051899,GO:0051924,GO:0051928,GO:0055037,GO:0055065,GO:0055074,GO:0055080,GO:0055082,GO:0055117,GO:0060090,GO:0060255,GO:0060306,GO:0060307,GO:0060341,GO:0061024,GO:0061337,GO:0065007,GO:0065008,GO:0065009,GO:0070296,GO:0070727,GO:0070838,GO:0070972,GO:0071702,GO:0071705,GO:0071840,GO:0072503,GO:0072507,GO:0072511,GO:0072657,GO:0072659,GO:0086001,GO:0086002,GO:0086004,GO:0086005,GO:0086010,GO:0086012,GO:0086014,GO:0086015,GO:0086046,GO:0086065,GO:0086066,GO:0086070,GO:0086091,GO:0090257,GO:0090279,GO:0097060,GO:0097458,GO:0097708,GO:0098589,GO:0098590,GO:0098771,GO:0098857,GO:0098900,GO:0098901,GO:0098907,GO:0098910,GO:0099623,GO:0140031,GO:1901016,GO:1901018,GO:1901019,GO:1901021,GO:1901379,GO:1901381,GO:1902578,GO:1902580,GO:1903115,GO:1903169,GO:1903522,GO:1903779,GO:1904062,GO:1904064,GO:1904427,GO:1990778,GO:2000021,GO:2001257,GO:2001259
    ## TRINITY_DN10007_c0_g1    GO:0003674,GO:0003824,GO:0004497,GO:0005488,GO:0005506,GO:0005575,GO:0006082,GO:0006629,GO:0006631,GO:0008150,GO:0008152,GO:0009987,GO:0016021,GO:0016491,GO:0016705,GO:0016712,GO:0016713,GO:0018685,GO:0019752,GO:0020037,GO:0031224,GO:0032787,GO:0043167,GO:0043169,GO:0043436,GO:0044237,GO:0044238,GO:0044255,GO:0044281,GO:0044425,GO:0044699,GO:0044710,GO:0044763,GO:0046872,GO:0046906,GO:0046914,GO:0055114,GO:0070330,GO:0071704,GO:0097159,GO:1901363
    ## TRINITY_DN10008_c0_g1    GO:0003674,GO:0003824,GO:0005488,GO:0005506,GO:0005575,GO:0005634,GO:0005654,GO:0005739,GO:0005829,GO:0006139,GO:0006259,GO:0006281,GO:0006304,GO:0006307,GO:0006725,GO:0006807,GO:0006950,GO:0006974,GO:0008150,GO:0008152,GO:0008198,GO:0008283,GO:0009451,GO:0009987,GO:0016070,GO:0016491,GO:0016705,GO:0016706,GO:0016787,GO:0032451,GO:0033554,GO:0034641,GO:0035510,GO:0035511,GO:0035513,GO:0035514,GO:0035515,GO:0035552,GO:0035553,GO:0043167,GO:0043169,GO:0043170,GO:0043226,GO:0043227,GO:0043229,GO:0043231,GO:0043412,GO:0043734,GO:0044237,GO:0044238,GO:0044260,GO:0044422,GO:0044424,GO:0044428,GO:0044444,GO:0044446,GO:0044464,GO:0044699,GO:0044710,GO:0044728,GO:0044763,GO:0046483,GO:0046872,GO:0046914,GO:0050896,GO:0051213,GO:0051716,GO:0051747,GO:0055114,GO:0070988,GO:0070989,GO:0071704,GO:0080111,GO:0090304,GO:0090305,GO:1901360,GO:1990930
    ## TRINITY_DN10009_c0_g1    GO:0003674,GO:0005488,GO:0005515,GO:0005575,GO:0005768,GO:0006810,GO:0008104,GO:0008150,GO:0015031,GO:0015833,GO:0016192,GO:0016197,GO:0031410,GO:0031982,GO:0033036,GO:0042886,GO:0043226,GO:0043227,GO:0043229,GO:0044424,GO:0044444,GO:0044464,GO:0045184,GO:0051179,GO:0051234,GO:0071702,GO:0071705,GO:0097708,GO:0098876,GO:1990126
    ## TRINITY_DN1000_c1_g1 GO:0005575,GO:0005634,GO:0005737,GO:0008150,GO:0010494,GO:0010717,GO:0030529,GO:0032991,GO:0035770,GO:0036464,GO:0043226,GO:0043227,GO:0043228,GO:0043229,GO:0043231,GO:0043232,GO:0044424,GO:0044444,GO:0044464,GO:0045595,GO:0050789,GO:0050793,GO:0050794,GO:0051239,GO:0065007,GO:1990904,GO:2000026
    ## TRINITY_DN10011_c0_g1    GO:0002082,GO:0003674,GO:0003824,GO:0004129,GO:0005215,GO:0005575,GO:0005739,GO:0005746,GO:0006140,GO:0006461,GO:0006996,GO:0007005,GO:0008150,GO:0008324,GO:0009055,GO:0009987,GO:0015002,GO:0015075,GO:0015077,GO:0015078,GO:0016021,GO:0016043,GO:0016491,GO:0016675,GO:0016676,GO:0019219,GO:0019220,GO:0019222,GO:0022607,GO:0022857,GO:0022890,GO:0022891,GO:0022892,GO:0031224,GO:0031323,GO:0034622,GO:0042325,GO:0043226,GO:0043227,GO:0043229,GO:0043231,GO:0043467,GO:0043623,GO:0043933,GO:0044422,GO:0044424,GO:0044425,GO:0044429,GO:0044444,GO:0044446,GO:0044455,GO:0044464,GO:0050789,GO:0050794,GO:0051171,GO:0051174,GO:0065003,GO:0065007,GO:0070469,GO:0071822,GO:0071840,GO:0080090,GO:0097250,GO:1900542,GO:1903578
    ## TRINITY_DN100166_c0_g1   GO:0003674,GO:0003676,GO:0003677,GO:0005488,GO:0005575,GO:0005634,GO:0006355,GO:0008150,GO:0009889,GO:0010468,GO:0010556,GO:0019219,GO:0019222,GO:0031323,GO:0031326,GO:0043167,GO:0043169,GO:0043226,GO:0043227,GO:0043229,GO:0043231,GO:0044424,GO:0044464,GO:0046872,GO:0050789,GO:0050794,GO:0051171,GO:0051252,GO:0060255,GO:0065007,GO:0080090,GO:0097159,GO:1901363,GO:1903506,GO:2000112,GO:2001141
    ## TRINITY_DN10017_c0_g1    GO:0000375,GO:0000377,GO:0000381,GO:0000398,GO:0003674,GO:0003676,GO:0003723,GO:0005488,GO:0005575,GO:0006139,GO:0006396,GO:0006397,GO:0006725,GO:0006807,GO:0007275,GO:0008150,GO:0008152,GO:0008380,GO:0009987,GO:0010468,GO:0016070,GO:0016071,GO:0016604,GO:0016607,GO:0019219,GO:0019222,GO:0031323,GO:0032501,GO:0032502,GO:0034641,GO:0043170,GO:0043484,GO:0044237,GO:0044238,GO:0044260,GO:0044422,GO:0044424,GO:0044428,GO:0044446,GO:0044451,GO:0044464,GO:0044699,GO:0044707,GO:0044767,GO:0045292,GO:0046483,GO:0048024,GO:0048856,GO:0050684,GO:0050789,GO:0050794,GO:0051171,GO:0051252,GO:0060255,GO:0065007,GO:0071704,GO:0080090,GO:0090304,GO:0097159,GO:1901360,GO:1901363,GO:1903311
    ## TRINITY_DN1001_c0_g1 GO:0000096,GO:0000097,GO:0003674,GO:0003824,GO:0003962,GO:0004121,GO:0004123,GO:0005488,GO:0005575,GO:0005737,GO:0006082,GO:0006520,GO:0006534,GO:0006555,GO:0006790,GO:0006807,GO:0008150,GO:0008152,GO:0008652,GO:0009058,GO:0009066,GO:0009067,GO:0009069,GO:0009070,GO:0009086,GO:0009092,GO:0009987,GO:0016053,GO:0016740,GO:0016765,GO:0016829,GO:0016846,GO:0019343,GO:0019344,GO:0019346,GO:0019752,GO:0019842,GO:0030170,GO:0036094,GO:0043167,GO:0043168,GO:0043436,GO:0044237,GO:0044238,GO:0044249,GO:0044272,GO:0044281,GO:0044283,GO:0044424,GO:0044464,GO:0044699,GO:0044710,GO:0044711,GO:0044763,GO:0046394,GO:0047804,GO:0048037,GO:0050667,GO:0070279,GO:0071704,GO:0097159,GO:1901363,GO:1901564,GO:1901566,GO:1901576,GO:1901605,GO:1901607
    ## TRINITY_DN10023_c0_g1    GO:0005575,GO:0005634,GO:0005730,GO:0005737,GO:0008150,GO:0022613,GO:0042254,GO:0043226,GO:0043227,GO:0043228,GO:0043229,GO:0043231,GO:0043232,GO:0044085,GO:0044422,GO:0044424,GO:0044428,GO:0044446,GO:0044464,GO:0071840

### Inspect original VCF

    # Load contents of .rvars into the environment
    source .rvars

    echo "'head' view of ${orig_vcf}:"
    echo ""
    head "./data/${orig_vcf}"
    echo ""
    echo "End of 'head' view of ${orig_vcf}"
    echo ""
    echo "${line}"
    echo ""

    echo "VCF header info:"
    echo ""

    # Capture first line of header (skipping list of contigs)
    begin=$("${bcftools}" view --header-only ./data/${orig_vcf} \
    | grep --line-number "##ALT=<ID" \
    | awk -F":" '{print $1}')

    # Caputure last line of header
    end=$("${bcftools}" view --header-only ./data/${orig_vcf} | wc -l)

    # Use sed to print range of lines
    sed --quiet "${begin},${end} p" ./data/${orig_vcf}
    echo ""
    echo "${line}"
    echo ""

    echo "List of samples in VCF:"
    echo ""
    ${bcftools} query --list-samples ./data/${orig_vcf}

    ## 'head' view of cbai_v3.1-SNPS.vcf:
    ## 
    ## ##fileformat=VCFv4.2
    ## ##FILTER=<ID=PASS,Description="All filters passed">
    ## ##bcftoolsVersion=1.13+htslib-1.13
    ## ##bcftoolsCommand=mpileup --fasta-ref /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta --threads 40 --output-type u /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380822.sorted.bam /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380823.sorted.bam /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380824.sorted.bam /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380825.sorted.bam
    ## ##reference=file:///gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta
    ## ##contig=<ID=TRINITY_DN5604_c0_g2_i1,length=2325>
    ## ##contig=<ID=TRINITY_DN9_c4_g1_i10,length=1025>
    ## ##contig=<ID=TRINITY_DN9_c4_g1_i9,length=999>
    ## ##contig=<ID=TRINITY_DN38_c0_g3_i1,length=2357>
    ## ##contig=<ID=TRINITY_DN81_c0_g1_i9,length=1451>
    ## 
    ## End of 'head' view of cbai_v3.1-SNPS.vcf
    ## 
    ## -------------------------------------------------------------------------------------------------
    ## 
    ## VCF header info:
    ## 
    ## ##ALT=<ID=*,Description="Represents allele(s) other than observed.">
    ## ##INFO=<ID=INDEL,Number=0,Type=Flag,Description="Indicates that the variant is an INDEL.">
    ## ##INFO=<ID=IDV,Number=1,Type=Integer,Description="Maximum number of raw reads supporting an indel">
    ## ##INFO=<ID=IMF,Number=1,Type=Float,Description="Maximum fraction of raw reads supporting an indel">
    ## ##INFO=<ID=DP,Number=1,Type=Integer,Description="Raw read depth">
    ## ##INFO=<ID=VDB,Number=1,Type=Float,Description="Variant Distance Bias for filtering splice-site artefacts in RNA-seq data (bigger is better)",Version="3">
    ## ##INFO=<ID=RPBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Read Position Bias (closer to 0 is better)">
    ## ##INFO=<ID=MQBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Mapping Quality Bias (closer to 0 is better)">
    ## ##INFO=<ID=BQBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Base Quality Bias (closer to 0 is better)">
    ## ##INFO=<ID=MQSBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Mapping Quality vs Strand Bias (closer to 0 is better)">
    ## ##INFO=<ID=SCBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Soft-Clip Length Bias (closer to 0 is better)">
    ## ##INFO=<ID=FS,Number=1,Type=Float,Description="Phred-scaled p-value using Fisher's exact test to detect strand bias">
    ## ##INFO=<ID=SGB,Number=1,Type=Float,Description="Segregation based metric.">
    ## ##INFO=<ID=MQ0F,Number=1,Type=Float,Description="Fraction of MQ0 reads (smaller is better)">
    ## ##FORMAT=<ID=PL,Number=G,Type=Integer,Description="List of Phred-scaled genotype likelihoods">
    ## ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
    ## ##INFO=<ID=AC,Number=A,Type=Integer,Description="Allele count in genotypes for each ALT allele, in the same order as listed">
    ## ##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
    ## ##INFO=<ID=DP4,Number=4,Type=Integer,Description="Number of high-quality ref-forward , ref-reverse, alt-forward and alt-reverse bases">
    ## ##INFO=<ID=MQ,Number=1,Type=Integer,Description="Average mapping quality">
    ## ##bcftools_callVersion=1.13+htslib-1.13
    ## ##bcftools_callCommand=call --output-type v --multiallelic-caller --variants-only --threads 40; Date=Fri Sep 10 21:20:44 2021
    ## #CHROM   POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  d2_uninfected_decreased-temp    d2_infected_decreased-temp  d2_uninfected_elevated-temp d2_infected_elevated-temp
    ## TRINITY_DN5604_c0_g2_i1  35  .   A   C   37.0646 .   DP=3;VDB=0.14;SGB=-0.314421;RPBZ=-1.22474;FS=0;MQ0F=0;AC=3;AN=4;DP4=1,0,2,0;MQ=60   GT:PL   ./.:0,0,0   0/1:31,0,31 ./.:0,0,0   1/1:37,3,0
    ## TRINITY_DN5604_c0_g2_i1  391 .   C   G   71.5526 .   DP=3;VDB=0.6;SGB=-0.314421;FS=0;MQ0F=0;AC=4;AN=4;DP4=0,0,0,2;MQ=60  GT:PL   ./.:0,0,0   1/1:60,3,0  ./.:0,0,0   1/1:37,3,0
    ## 
    ## -------------------------------------------------------------------------------------------------
    ## 
    ## List of samples in VCF:
    ## 
    ## d2_uninfected_decreased-temp
    ## d2_infected_decreased-temp
    ## d2_uninfected_elevated-temp
    ## d2_infected_elevated-temp

### Subset VCF to minimum coverage and quality

    # Load contents of .rvars into the environment
    source .rvars

    # Subset VCF to only SNPs with ${SNP_coverage}x raw read coverage
    # and quality >= ${SNP_qual}
    "${bcftools}" filter \
    --include "TYPE='snp' & MIN(DP)>=${SNP_coverage} & QUAL>=${SNP_quality}" \
    --threads ${threads} \
    ./data/${orig_vcf} \
    > ./analyses/${vcf_filtered}

### Inspect filtered VCF

    # Load contents of .rvars into the environment
    source .rvars

    echo "'head' view of ${vcf_filtered}:"
    echo ""
    head "./analyses/${vcf_filtered}"
    echo ""
    echo "End of 'head' view of ${vcf_filtered}"
    echo ""
    echo "${line}"
    echo ""

    echo "VCF header info:"
    echo ""

    # Capture first line of header (skipping list of contigs)
    begin=$("${bcftools}" view --header-only ./analyses/${vcf_filtered} \
    | grep --line-number "##ALT=<ID" \
    | awk -F":" '{print $1}')

    # Caputure last line of header
    end=$("${bcftools}" view --header-only ./analyses/${vcf_filtered} | wc -l)

    # Use sed to print range of lines
     sed --quiet "${begin},${end} p" ./analyses/${vcf_filtered}

    echo ""
    echo "${line}"
    echo ""

    echo "List of samples in VCF:"
    echo ""
    ${bcftools} query --list-samples ./analyses/${vcf_filtered}

    ## 'head' view of cbai_v3.1-SNPS-30Q-10x.vcf:
    ## 
    ## ##fileformat=VCFv4.2
    ## ##FILTER=<ID=PASS,Description="All filters passed">
    ## ##bcftoolsVersion=1.13+htslib-1.13
    ## ##bcftoolsCommand=mpileup --fasta-ref /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta --threads 40 --output-type u /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380822.sorted.bam /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380823.sorted.bam /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380824.sorted.bam /gscratch/scrubbed/samwhite/outputs/20210908-cbai-hisat2-cbai_transcriptome_v3.1/380825.sorted.bam
    ## ##reference=file:///gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta
    ## ##contig=<ID=TRINITY_DN5604_c0_g2_i1,length=2325>
    ## ##contig=<ID=TRINITY_DN9_c4_g1_i10,length=1025>
    ## ##contig=<ID=TRINITY_DN9_c4_g1_i9,length=999>
    ## ##contig=<ID=TRINITY_DN38_c0_g3_i1,length=2357>
    ## ##contig=<ID=TRINITY_DN81_c0_g1_i9,length=1451>
    ## 
    ## End of 'head' view of cbai_v3.1-SNPS-30Q-10x.vcf
    ## 
    ## -------------------------------------------------------------------------------------------------
    ## 
    ## VCF header info:
    ## 
    ## ##ALT=<ID=*,Description="Represents allele(s) other than observed.">
    ## ##INFO=<ID=INDEL,Number=0,Type=Flag,Description="Indicates that the variant is an INDEL.">
    ## ##INFO=<ID=IDV,Number=1,Type=Integer,Description="Maximum number of raw reads supporting an indel">
    ## ##INFO=<ID=IMF,Number=1,Type=Float,Description="Maximum fraction of raw reads supporting an indel">
    ## ##INFO=<ID=DP,Number=1,Type=Integer,Description="Raw read depth">
    ## ##INFO=<ID=VDB,Number=1,Type=Float,Description="Variant Distance Bias for filtering splice-site artefacts in RNA-seq data (bigger is better)",Version="3">
    ## ##INFO=<ID=RPBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Read Position Bias (closer to 0 is better)">
    ## ##INFO=<ID=MQBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Mapping Quality Bias (closer to 0 is better)">
    ## ##INFO=<ID=BQBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Base Quality Bias (closer to 0 is better)">
    ## ##INFO=<ID=MQSBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Mapping Quality vs Strand Bias (closer to 0 is better)">
    ## ##INFO=<ID=SCBZ,Number=1,Type=Float,Description="Mann-Whitney U-z test of Soft-Clip Length Bias (closer to 0 is better)">
    ## ##INFO=<ID=FS,Number=1,Type=Float,Description="Phred-scaled p-value using Fisher's exact test to detect strand bias">
    ## ##INFO=<ID=SGB,Number=1,Type=Float,Description="Segregation based metric.">
    ## ##INFO=<ID=MQ0F,Number=1,Type=Float,Description="Fraction of MQ0 reads (smaller is better)">
    ## ##FORMAT=<ID=PL,Number=G,Type=Integer,Description="List of Phred-scaled genotype likelihoods">
    ## ##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
    ## ##INFO=<ID=AC,Number=A,Type=Integer,Description="Allele count in genotypes for each ALT allele, in the same order as listed">
    ## ##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
    ## ##INFO=<ID=DP4,Number=4,Type=Integer,Description="Number of high-quality ref-forward , ref-reverse, alt-forward and alt-reverse bases">
    ## ##INFO=<ID=MQ,Number=1,Type=Integer,Description="Average mapping quality">
    ## ##bcftools_callVersion=1.13+htslib-1.13
    ## ##bcftools_callCommand=call --output-type v --multiallelic-caller --variants-only --threads 40; Date=Fri Sep 10 21:20:44 2021
    ## ##bcftools_filterVersion=1.13+htslib-1.13
    ## ##bcftools_filterCommand=filter --include 'TYPE='snp' & MIN(DP)>=10 & QUAL>=30' --threads 8 ./data/cbai_v3.1-SNPS.vcf; Date=Thu Oct  7 12:55:06 2021
    ## #CHROM   POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  d2_uninfected_decreased-temp    d2_infected_decreased-temp  d2_uninfected_elevated-temp d2_infected_elevated-temp
    ## TRINITY_DN9_c4_g1_i10    661 .   T   C   125.719 PASS    DP=139;VDB=3.781e-05;SGB=-11.5772;RPBZ=-0.349139;MQBZ=0.473562;MQSBZ=0.168907;BQBZ=3.68777;SCBZ=-3.2251;FS=0;MQ0F=0.00719424;AC=2;AN=8;DP4=44,55,5,6;MQ=58  GT:PL   0/1:89,0,255    0/0:0,60,255    0/1:77,0,196    0/0:0,18,255
    ## TRINITY_DN9_c4_g1_i10    662 .   G   A   125.924 PASS    DP=139;VDB=3.781e-05;SGB=-11.5772;RPBZ=-0.349216;MQBZ=0.473562;MQSBZ=0.168907;BQBZ=3.85055;SCBZ=-3.22016;FS=0;MQ0F=0.00719424;AC=2;AN=8;DP4=44,55,5,6;MQ=58 GT:PL   0/1:89,0,255    0/0:0,60,255    0/1:77,0,199    0/0:0,11,255
    ## 
    ## -------------------------------------------------------------------------------------------------
    ## 
    ## List of samples in VCF:
    ## 
    ## d2_uninfected_decreased-temp
    ## d2_infected_decreased-temp
    ## d2_uninfected_elevated-temp
    ## d2_infected_elevated-temp

### Extract Transcripts Having SNPs with `${SNP_coverage}x` Read Coverage and Quality &gt;= `${SNP_qual}`

The resulting FastA is useful to use in IGV, so that we don’t have to
deal with browsing contigs with no variants.

    # Load contents of .rvars into the environment
    source .rvars

    # List of FastA IDs with ${SNP_coverage}x SNP coverage
    # Uses awk to skip all lines beginning with '#'
    awk '/^[^#]/{print $1}' ./analyses/${vcf_filtered} \
    | sort -u \
    > ./analyses/${contigs_list}

    # Use seqtk to generate a FastA from original transcriptome assembly and list of contigs with ${SNP_coverage}x SNP coverage
    "${seqtk}" subseq ./data/${transcriptome_fasta} ./analyses/${contigs_list} > ./data/${transcriptome_SNPS_fasta}

    # Generate FastA index file for new FastA
    "${samtools}" faidx ./data/${transcriptome_SNPS_fasta}

    ls -ltrh ./analyses

    ## total 22M
    ## -rw-rw-r-- 1 sam sam  22M Oct  7 12:55 cbai_v3.1-SNPS-30Q-10x.vcf
    ## -rw-rw-r-- 1 sam sam 423K Oct  7 12:55 cbai_v3.1-SNPS_30Q-10x_contig-IDs.txt

### Compare number of original transcripts with number of those with SNPs

    # Load contents of .rvars into the environment
    source .rvars

    for fasta in ./data/*.fasta
    do
      grep --count --with-filename "^>" ${fasta}
    done | column -t -s ":"

    ## ./data/cbai_transcriptome_v3.1.fasta               78649
    ## ./data/cbai_transcriptome_v3.1_SNPs-30Q-10x.fasta  17680

## SNP Stats

### Summary stats

    # Load contents of .rvars into the environment
    source .rvars

    # Shows summary stats for all samples
    ${bcftools} stats \
    --samples - \
    ./analyses/${vcf_filtered} \
    | head -n 31

    ## # This file was produced by bcftools stats (1.13+htslib-1.13) and can be plotted using plot-vcfstats.
    ## # The command line was:  bcftools stats  --samples - ./analyses/cbai_v3.1-SNPS-30Q-10x.vcf
    ## #
    ## # Definition of sets:
    ## # ID [2]id   [3]tab-separated file names
    ## ID   0   ./analyses/cbai_v3.1-SNPS-30Q-10x.vcf
    ## # SN, Summary numbers:
    ## #   number of records   .. number of data rows in the VCF
    ## #   number of no-ALTs   .. reference-only sites, ALT is either "." or identical to REF
    ## #   number of SNPs      .. number of rows with a SNP
    ## #   number of MNPs      .. number of rows with a MNP, such as CC>TT
    ## #   number of indels    .. number of rows with an indel
    ## #   number of others    .. number of rows with other type, for example a symbolic allele or
    ## #                          a complex substitution, such as ACT>TCGA
    ## #   number of multiallelic sites     .. number of rows with multiple alternate alleles
    ## #   number of multiallelic SNP sites .. number of rows with multiple alternate alleles, all SNPs
    ## # 
    ## #   Note that rows containing multiple types will be counted multiple times, in each
    ## #   counter. For example, a row with a SNP and an indel increments both the SNP and
    ## #   the indel counter.
    ## # 
    ## # SN [2]id   [3]key  [4]value
    ## SN   0   number of samples:  4
    ## SN   0   number of records:  79753
    ## SN   0   number of no-ALTs:  0
    ## SN   0   number of SNPs: 79753
    ## SN   0   number of MNPs: 0
    ## SN   0   number of indels:   0
    ## SN   0   number of others:   0
    ## SN   0   number of multiallelic sites:   785
    ## SN   0   number of multiallelic SNP sites:   785

#### Transitions/Transversions and Substitution types

    # Load contents of .rvars into the environment
    source .rvars

    ${bcftools} stats \
    --samples - \
    ./analyses/${vcf_filtered} \
    | grep "ST"

    ## # TSTV, transitions/transversions:
    ## # TSTV   [2]id   [3]ts   [4]tv   [5]ts/tv    [6]ts (1st ALT) [7]tv (1st ALT) [8]ts/tv (1st ALT)
    ## TSTV 0   50173   30371   1.65    49905   29848   1.67
    ## # ST, Substitution types:
    ## # ST [2]id   [3]type [4]count
    ## ST   0   A>C 4141
    ## ST   0   A>G 10450
    ## ST   0   A>T 3428
    ## ST   0   C>A 4425
    ## ST   0   C>G 3420
    ## ST   0   C>T 14934
    ## ST   0   G>A 14055
    ## ST   0   G>C 3373
    ## ST   0   G>T 3944
    ## ST   0   T>A 3635
    ## ST   0   T>C 10734
    ## ST   0   T>G 4005

### Individual sample stats

    # Load contents of .rvars into the environment
    source .rvars

    # Shows samples stats.
    # Uses sed/column/tail to format output nicely
    ${bcftools} stats \
    --samples - \
    ./analyses/${vcf_filtered} \
    | grep "PSC" \
    | sed 's/^# *//' \
    | sed 's/average depth/avg_dp/' \
    | column -t \
    | tail -n 5

    ## PSC   [2]id       [3]sample                     [4]nRefHom  [5]nNonRefHom  [6]nHets  [7]nTransitions  [8]nTransversions  [9]nIndels  [10]avg_dp  [11]nSingletons  [12]nHapRef  [13]nHapAlt  [14]nMissing
    ## PSC   0           d2_uninfected_decreased-temp  23566       20691          28356     29276            19771              0           0.0         5658             0            0            7140
    ## PSC   0           d2_infected_decreased-temp    24704       20754          30361     30595            20520              0           0.0         4725             0            0            3934
    ## PSC   0           d2_uninfected_elevated-temp   22246       19306          33690     31942            21054              0           0.0         5052             0            0            4511
    ## PSC   0           d2_infected_elevated-temp     22970       20575          34095     32990            21680              0           0.0         5057             0            0            2113

### Percentage of transcripts with SNPS

    # Load contents of .rvars into the environment
    source .rvars

    # Count number of transcripts in transcriptome assembly
    transcripts_count=$(grep -c "^>" ./data/${transcriptome_fasta})
    printf "%s\t%s\n" "Original transcriptome transcripts:" "${transcripts_count}"

    # Count number of transcripts with SNPs
    # Parses Trinity ID and counts unique Trinity IDs
    snp_transcripts_count=$(awk '/^[^#]/{print $1}' ./analyses/${vcf_filtered} | sort -u| wc -l)
    printf "%s\t%s\n" "Transcripts with SNPs:" "${snp_transcripts_count}"

    echo ""
    # Calculate percentage
    printf "%s\t%s\n" "Percentage of transcripts with SNPs:" "$(bc <<< "scale=4; ( ${snp_transcripts_count} / ${transcripts_count} * 100)")"

    ## Original transcriptome transcripts:  78649
    ## Transcripts with SNPs:   17680
    ## 
    ## Percentage of transcripts with SNPs: 22.4700

### Get max/min/mean number of SNPs per transcript

    # Load contents of .rvars into the environment
    source .rvars

    awk '/^[^#]/{print $1}' ./analyses/${vcf_filtered} \
    | sort \
    | uniq -c \
    | sort -k1n,1 \
    | awk '{sum+=$1;cnt++;max=$1;min=cnt==1?$1:min} END{print "min="min, "max="max, "mean="sum/cnt}'

    ## min=1 max=334 mean=4.51092

### Extract FastA IDs

Strips Trinity isoform designations from end of ID to match gene IDs in
GO term annotation file

    # Load contents of .rvars into the environment
    source .rvars

    awk '/^[^#]/{print $1}' ./analyses/${vcf_filtered} \
    | awk 'BEGIN { FS = "_"; OFS = "_" } {print $1, $2, $3, $4}' \
    | sort -u \
    > ./analyses/${genes_list}

    wc -l ./analyses/"${genes_list}"

    echo ""
    echo "${line}"
    echo ""

    head ./analyses/"${genes_list}"

    ## 10332 ./analyses/cbai_v3.1-SNPS_30Q-10x_gene-IDs.txt
    ## 
    ## -------------------------------------------------------------------------------------------------
    ## 
    ## TRINITY_DN1000_c1_g1
    ## TRINITY_DN10011_c0_g1
    ## TRINITY_DN10019_c0_g1
    ## TRINITY_DN1001_c0_g1
    ## TRINITY_DN10023_c0_g1
    ## TRINITY_DN10023_c1_g1
    ## TRINITY_DN10023_c2_g2
    ## TRINITY_DN10025_c0_g1
    ## TRINITY_DN1002_c2_g1
    ## TRINITY_DN10030_c0_g1

### Extract genes with SNPs from transcriptome annotation file

    # Load contents of .rvars into the environment
    source .rvars

    # Uses a list of Trinity gene IDs to extract gene IDs and corresponding GO accessions.
    # Expects Trinotate annotations file as input.
    # Uses sed to convert commas to tabs in preparation for subsequent "flattening"
    while read -r line
    do 
      grep "${line}" ./data/${cbai_v3_1_GO}
    done < ./analyses/${genes_list} \
    | sed $'s/,/\t/g' \
    > ./analyses/${genes_GO_list}

    # Check number of records
    wc -l ./analyses/${genes_GO_list}

    echo ""
    echo "${line}"
    echo ""

    head ./analyses/${genes_GO_list}

    ## 6891 ./analyses/cbai_v3.1-SNPS_30Q-10x_GO.tab
    ## 
    ## -------------------------------------------------------------------------------------------------
    ## 
    ## TRINITY_DN1000_c1_g1 GO:0005575  GO:0005634  GO:0005737  GO:0008150  GO:0010494  GO:0010717  GO:0030529  GO:0032991  GO:0035770  GO:0036464  GO:0043226  GO:0043227  GO:0043228  GO:0043229  GO:0043231  GO:0043232  GO:0044424  GO:0044444  GO:0044464  GO:0045595  GO:0050789  GO:0050793  GO:0050794  GO:0051239  GO:0065007  GO:1990904  GO:2000026
    ## TRINITY_DN10011_c0_g1    GO:0002082  GO:0003674  GO:0003824  GO:0004129  GO:0005215  GO:0005575  GO:0005739  GO:0005746  GO:0006140  GO:0006461  GO:0006996  GO:0007005  GO:0008150  GO:0008324  GO:0009055  GO:0009987  GO:0015002  GO:0015075  GO:0015077  GO:0015078  GO:0016021  GO:0016043  GO:0016491  GO:0016675  GO:0016676  GO:0019219  GO:0019220  GO:0019222  GO:0022607  GO:0022857  GO:0022890  GO:0022891  GO:0022892  GO:0031224  GO:0031323  GO:0034622  GO:0042325  GO:0043226  GO:0043227  GO:0043229  GO:0043231  GO:0043467  GO:0043623  GO:0043933  GO:0044422  GO:0044424  GO:0044425  GO:0044429  GO:0044444  GO:0044446  GO:0044455  GO:0044464  GO:0050789  GO:0050794  GO:0051171  GO:0051174  GO:0065003  GO:0065007  GO:0070469  GO:0071822  GO:0071840  GO:0080090  GO:0097250  GO:1900542  GO:1903578
    ## TRINITY_DN1001_c0_g1 GO:0000096  GO:0000097  GO:0003674  GO:0003824  GO:0003962  GO:0004121  GO:0004123  GO:0005488  GO:0005575  GO:0005737  GO:0006082  GO:0006520  GO:0006534  GO:0006555  GO:0006790  GO:0006807  GO:0008150  GO:0008152  GO:0008652  GO:0009058  GO:0009066  GO:0009067  GO:0009069  GO:0009070  GO:0009086  GO:0009092  GO:0009987  GO:0016053  GO:0016740  GO:0016765  GO:0016829  GO:0016846  GO:0019343  GO:0019344  GO:0019346  GO:0019752  GO:0019842  GO:0030170  GO:0036094  GO:0043167  GO:0043168  GO:0043436  GO:0044237  GO:0044238  GO:0044249  GO:0044272  GO:0044281  GO:0044283  GO:0044424  GO:0044464  GO:0044699  GO:0044710  GO:0044711  GO:0044763  GO:0046394  GO:0047804  GO:0048037  GO:0050667  GO:0070279  GO:0071704  GO:0097159  GO:1901363  GO:1901564  GO:1901566  GO:1901576  GO:1901605  GO:1901607
    ## TRINITY_DN10023_c0_g1    GO:0005575  GO:0005634  GO:0005730  GO:0005737  GO:0008150  GO:0022613  GO:0042254  GO:0043226  GO:0043227  GO:0043228  GO:0043229  GO:0043231  GO:0043232  GO:0044085  GO:0044422  GO:0044424  GO:0044428  GO:0044446  GO:0044464  GO:0071840
    ## TRINITY_DN10023_c2_g2    GO:0001822  GO:0002376  GO:0003674  GO:0005488  GO:0005515  GO:0005575  GO:0005634  GO:0005829  GO:0006325  GO:0006464  GO:0006473  GO:0006475  GO:0006508  GO:0006511  GO:0006515  GO:0006807  GO:0006950  GO:0006974  GO:0006996  GO:0007130  GO:0007165  GO:0007276  GO:0007283  GO:0007420  GO:0008104  GO:0008150  GO:0008152  GO:0008630  GO:0009056  GO:0009057  GO:0009892  GO:0009894  GO:0009895  GO:0009987  GO:0010033  GO:0010243  GO:0010498  GO:0010605  GO:0010941  GO:0016043  GO:0018193  GO:0018205  GO:0018393  GO:0018394  GO:0019222  GO:0019538  GO:0019941  GO:0022402  GO:0022414  GO:0022607  GO:0030154  GO:0030162  GO:0030163  GO:0030324  GO:0030433  GO:0031323  GO:0031324  GO:0031329  GO:0031330  GO:0031593  GO:0031647  GO:0031982  GO:0032182  GO:0032268  GO:0032269  GO:0032403  GO:0032434  GO:0032435  GO:0032502  GO:0032991  GO:0033036  GO:0033554  GO:0034613  GO:0034976  GO:0035556  GO:0036211  GO:0036503  GO:0042176  GO:0042177  GO:0042221  GO:0042771  GO:0042981  GO:0043021  GO:0043022  GO:0043067  GO:0043130  GO:0043161  GO:0043170  GO:0043226  GO:0043227  GO:0043229  GO:0043230  GO:0043231  GO:0043234  GO:0043412  GO:0043543  GO:0043632  GO:0044237  GO:0044238  GO:0044248  GO:0044260  GO:0044265  GO:0044267  GO:0044421  GO:0044424  GO:0044444  GO:0044445  GO:0044464  GO:0044699  GO:0044702  GO:0044710  GO:0044712  GO:0044763  GO:0044767  GO:0044877  GO:0045048  GO:0045184  GO:0045861  GO:0045995  GO:0048232  GO:0048513  GO:0048519  GO:0048523  GO:0048609  GO:0048856  GO:0048869  GO:0050789  GO:0050793  GO:0050794  GO:0050821  GO:0050896  GO:0051171  GO:0051172  GO:0051179  GO:0051205  GO:0051234  GO:0051239  GO:0051246  GO:0051248  GO:0051276  GO:0051603  GO:0051641  GO:0051716  GO:0060255  GO:0061136  GO:0061857  GO:0065007  GO:0065008  GO:0070059  GO:0070062  GO:0070192  GO:0070193  GO:0070628  GO:0070727  GO:0071704  GO:0071712  GO:0071816  GO:0071818  GO:0071840  GO:0072331  GO:0072332  GO:0072379  GO:0072657  GO:0080090  GO:0090150  GO:0097190  GO:0097193  GO:1901564  GO:1901565  GO:1901575  GO:1901698  GO:1901799  GO:1903046  GO:1903050  GO:1903051  GO:1903362  GO:1903363  GO:1903561  GO:2000026
    ## TRINITY_DN1002_c2_g1 GO:0003674  GO:0003676  GO:0003723  GO:0003729  GO:0005488  GO:0005515  GO:0005575  GO:0005634  GO:0006139  GO:0006396  GO:0006725  GO:0006807  GO:0008150  GO:0008152  GO:0009987  GO:0016070  GO:0031050  GO:0034641  GO:0035196  GO:0043170  GO:0043226  GO:0043227  GO:0043229  GO:0043231  GO:0044237  GO:0044238  GO:0044260  GO:0044424  GO:0044464  GO:0046483  GO:0070918  GO:0071704  GO:0090304  GO:0097159  GO:1901360  GO:1901363
    ## TRINITY_DN10030_c0_g1    GO:0000166  GO:0000346  GO:0003674  GO:0003676  GO:0003677  GO:0003723  GO:0005488  GO:0005575  GO:0005730  GO:0006405  GO:0006406  GO:0006810  GO:0006913  GO:0008150  GO:0008284  GO:0008327  GO:0009893  GO:0010604  GO:0010638  GO:0015931  GO:0016604  GO:0016607  GO:0019222  GO:0030529  GO:0031056  GO:0031058  GO:0031060  GO:0031062  GO:0031323  GO:0031325  GO:0031399  GO:0031401  GO:0032268  GO:0032270  GO:0032781  GO:0032991  GO:0033043  GO:0033044  GO:0035770  GO:0036094  GO:0036464  GO:0042127  GO:0043085  GO:0043226  GO:0043228  GO:0043229  GO:0043232  GO:0043234  GO:0043462  GO:0043565  GO:0044093  GO:0044422  GO:0044424  GO:0044428  GO:0044444  GO:0044446  GO:0044451  GO:0044464  GO:0046907  GO:0048518  GO:0048522  GO:0050657  GO:0050658  GO:0050789  GO:0050790  GO:0050794  GO:0051028  GO:0051095  GO:0051096  GO:0051128  GO:0051130  GO:0051168  GO:0051169  GO:0051171  GO:0051173  GO:0051179  GO:0051234  GO:0051236  GO:0051246  GO:0051247  GO:0051336  GO:0051345  GO:0051641  GO:0051649  GO:0060255  GO:0065007  GO:0065009  GO:0071702  GO:0071705  GO:0080090  GO:0097159  GO:1901265  GO:1901363  GO:1902275  GO:1905269  GO:1990904  GO:2001252
    ## TRINITY_DN10030_c2_g1    GO:0005575  GO:0005789  GO:0008150  GO:0009987  GO:0016020  GO:0016021  GO:0019725  GO:0031224  GO:0042592  GO:0044422  GO:0044424  GO:0044425  GO:0044432  GO:0044444  GO:0044446  GO:0044464  GO:0044699  GO:0044763  GO:0045454  GO:0050789  GO:0050794  GO:0065007  GO:0065008
    ## TRINITY_DN10034_c0_g1    GO:0000166  GO:0000226  GO:0003674  GO:0003676  GO:0003677  GO:0003678  GO:0003824  GO:0004386  GO:0005488  GO:0005524  GO:0005575  GO:0005634  GO:0006139  GO:0006259  GO:0006260  GO:0006270  GO:0006725  GO:0006807  GO:0006996  GO:0007010  GO:0007017  GO:0007051  GO:0007052  GO:0008150  GO:0008152  GO:0009058  GO:0009059  GO:0009987  GO:0016043  GO:0016462  GO:0016787  GO:0016817  GO:0016818  GO:0016887  GO:0017076  GO:0017111  GO:0022402  GO:0030554  GO:0032553  GO:0032555  GO:0032559  GO:0032991  GO:0034641  GO:0034645  GO:0035639  GO:0036094  GO:0042555  GO:0043167  GO:0043168  GO:0043170  GO:0043226  GO:0043227  GO:0043229  GO:0043231  GO:0043234  GO:0044237  GO:0044238  GO:0044249  GO:0044260  GO:0044424  GO:0044464  GO:0046483  GO:0071704  GO:0071840  GO:0090304  GO:0097159  GO:0097367  GO:1901265  GO:1901360  GO:1901363  GO:1901576  GO:1902850  GO:1903047
    ## TRINITY_DN10038_c0_g2    GO:0003674  GO:0003824  GO:0016301  GO:0016740  GO:0016772

### Flatten `${genes_GO_list}` to have one GO accession per line.

    # Load contents of .rvars into the environment
    source .rvars

    # Identify first field containing a GO term.
    # Search file with grep for "GO:" and pipe to awk.
    # Awk sets tab as field delimiter (-F'\t'), runs a for loop that looks for "GO:" (~/GO:/), and then prints the field number).
    # Awk results are piped to sort, which sorts unique by number (-ug).
    # Sort results are piped to head to retrieve the lowest value (i.e. the top of the list; "-n1").
    begin_goterms=$(grep "GO:" ./analyses/"${genes_GO_list}" | awk -F'\t' '{for (i=1;i<=NF;i++) if($i ~/GO:/) print i}' | sort -ug | head -n1)

    # Flatten GO terms annotation file.
    # Expects tab-delimited input file where:
    ## First field (column) is Trinity gene IDs.
    ## Remaining fields (columns) are each individual GO accessions.
    while read -r line
    do
      # Capture maximum number of fields to handle differing number of GO terms.
      max_field=$(echo "$line" | awk -F'\t' '{print NF}')
      
      # Set which fields are "fixed" (i.e. Trinity gene IDs)
      fixed_fields=$(echo "$line" | cut -f1)
      
      # Identifies if a line has GO accessions,
      # reads them into an array,
      # and then prints the Trinity Id and single GO accession on each line.
      if (( "$max_field" < "$begin_goterms" )); then
        printf "%s\n" "$line"
      else
        # Set range of GO accessions for each line
        goterms=$(echo "$line" | cut -f"$begin_goterms"-"$max_field")
        # Set Internal Field Separator to a <tab> and read $goterms into array.
        IFS=$'\t' read -r -a array <<< "$goterms"
        # Loop through array and print tab-delimited file of Trinity ID and single GO accession.
        for element in "${!array[@]}"
          do printf "%s\t%s\n" "$fixed_fields" "${array[$element]}"
        done
      fi
    done < ./analyses/"${genes_GO_list}" > ./analyses/"${flattened_GO}"

    # Check number of records
    wc -l ./analyses/${flattened_GO}

    echo ""
    echo "${line}"
    echo ""

    head ./analyses/${flattened_GO}

    ## 550412 ./analyses/cbai_v3_1-SNPS_30Q-10x_GO.flattened-go.txt
    ## 
    ## 
    ## 
    ## TRINITY_DN1000_c1_g1 GO:0005575
    ## TRINITY_DN1000_c1_g1 GO:0005634
    ## TRINITY_DN1000_c1_g1 GO:0005737
    ## TRINITY_DN1000_c1_g1 GO:0008150
    ## TRINITY_DN1000_c1_g1 GO:0010494
    ## TRINITY_DN1000_c1_g1 GO:0010717
    ## TRINITY_DN1000_c1_g1 GO:0030529
    ## TRINITY_DN1000_c1_g1 GO:0032991
    ## TRINITY_DN1000_c1_g1 GO:0035770
    ## TRINITY_DN1000_c1_g1 GO:0036464

### Create file with path to `${flattened_GO}` file

Used to pass Bash variable to R.

    source .rvars
    echo "./analyses/${flattened_GO}" > .flattened_GO

### Create R string with path to Bash variable, `${flattened_GO}`

    string <- paste(readLines(".flattened_GO"), collapse=" ")
    print(string)

    ## [1] "./analyses/cbai_v3_1-SNPS_30Q-10x_GO.flattened-go.txt"

    library(GSEABase)

    ## Loading required package: BiocGenerics

    ## Loading required package: parallel

    ## 
    ## Attaching package: 'BiocGenerics'

    ## The following objects are masked from 'package:parallel':
    ## 
    ##     clusterApply, clusterApplyLB, clusterCall, clusterEvalQ,
    ##     clusterExport, clusterMap, parApply, parCapply, parLapply,
    ##     parLapplyLB, parRapply, parSapply, parSapplyLB

    ## The following objects are masked from 'package:stats':
    ## 
    ##     IQR, mad, sd, var, xtabs

    ## The following objects are masked from 'package:base':
    ## 
    ##     anyDuplicated, append, as.data.frame, basename, cbind, colnames,
    ##     dirname, do.call, duplicated, eval, evalq, Filter, Find, get, grep,
    ##     grepl, intersect, is.unsorted, lapply, Map, mapply, match, mget,
    ##     order, paste, pmax, pmax.int, pmin, pmin.int, Position, rank,
    ##     rbind, Reduce, rownames, sapply, setdiff, sort, table, tapply,
    ##     union, unique, unsplit, which.max, which.min

    ## Loading required package: Biobase

    ## Welcome to Bioconductor
    ## 
    ##     Vignettes contain introductory material; view with
    ##     'browseVignettes()'. To cite Bioconductor, see
    ##     'citation("Biobase")', and for packages 'citation("pkgname")'.

    ## Loading required package: annotate

    ## Loading required package: AnnotationDbi

    ## Loading required package: stats4

    ## Loading required package: IRanges

    ## Loading required package: S4Vectors

    ## 
    ## Attaching package: 'S4Vectors'

    ## The following object is masked from 'package:base':
    ## 
    ##     expand.grid

    ## Loading required package: XML

    ## Loading required package: graph

    ## 
    ## Attaching package: 'graph'

    ## The following object is masked from 'package:XML':
    ## 
    ##     addNode

    library(tidyverse)

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.4     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.2     ✓ dplyr   1.0.6
    ## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
    ## ✓ readr   1.4.0     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x stringr::boundary() masks graph::boundary()
    ## x dplyr::collapse()   masks IRanges::collapse()
    ## x dplyr::combine()    masks Biobase::combine(), BiocGenerics::combine()
    ## x dplyr::desc()       masks IRanges::desc()
    ## x tidyr::expand()     masks S4Vectors::expand()
    ## x dplyr::filter()     masks stats::filter()
    ## x dplyr::first()      masks S4Vectors::first()
    ## x dplyr::lag()        masks stats::lag()
    ## x ggplot2::Position() masks BiocGenerics::Position(), base::Position()
    ## x purrr::reduce()     masks IRanges::reduce()
    ## x dplyr::rename()     masks S4Vectors::rename()
    ## x dplyr::select()     masks AnnotationDbi::select()
    ## x dplyr::slice()      masks IRanges::slice()

    # Script to retrieve GOslims from Trinity-based, EdgeR GOseq differential gene expression.
    # Identifies enriched and depleted output files.
    # Requires "goslim_generic.obo" from http://geneontology.org/docs/go-subset-guide/
      
      ## Get max number of fields
      # Needed to handle reading in file with different number of columns in each row
      max_fields <- max(na.omit((count.fields(string, sep = "\t", blank.lines.skip = TRUE))))
      
      ## Read in tab-delimited GOseq file
      # Use "max_fields" to populate all columns with a sequentially numbered header
      go_seqs <- read.table(string,
                            sep = "\t",
                            header = FALSE,
                            col.names = paste0("V",seq_len(max_fields)),
                            fill = TRUE)
      
      ## Grab just the individual GO terms from the "2nd" column)
      goterms <- as.character(go_seqs$V2)
      
      ### Use GSEA to map GO terms to GOslims
      
      ## Store goterms as GSEA object
      myCollection <- GOCollection(goterms)

    ## 

      ## Use generic GOslim file to create a GOslim collection
      
      # I downloaded goslim_generic.obo from http://geneontology.org/docs/go-subset-guide/
      # then i moved it to the R library for GSEABase in the extdata folder
      # in addition to using the command here - I think they're both required.
      slim <- getOBOCollection("~/data/goslim_generic.obo")
      
      ## Map GO terms to GOslims and select Biological Processes group
      slims <- goSlim(myCollection, slim, "BP", verbose = TRUE)
      
      # Rename first column
      slims <- slims %>% rownames_to_column(var = "GOslim")
      
      ## Write output file
      write.csv(slims, file = "./analyses/S10-SNPs_GO-GOslims.csv", quote = FALSE, row.names = FALSE)

    # Remove GOslim accession for the generic "biological_process" term to improve visualization of other terms.
    slims <- slims[slims$GOslim != "GO:0008150",]

    # Create bar plot.
    # "Open" PNG file for saving subsequent plot
    pdf("./figures/S9-SNPs_GO-GOslims_barplot.pdf", height = 10, width = 12)

    ggplot(data = slims, aes(x=slims$Percent, y=slims$Term)) +
      labs(title = "",
           caption = "Supplemental Figure 1. Barplot of percentages of gene ontology assignments to GOslims for transcripts containing at least on SNP.
           Excludes the generic \"biological_process\" GOslim (55.53% of all GO terms) to aid in visualization of other GOslim categories.",
           x = "Percent GO terms assigned to GOslim",
           y = "GOslim") +
      geom_bar(stat = "identity") +
      theme(plot.caption = element_text(hjust = 0)
      )

    ## Warning: Use of `slims$Percent` is discouraged. Use `Percent` instead.

    ## Warning: Use of `slims$Term` is discouraged. Use `Term` instead.

    # Close PNG file
    dev.off()

    ## png 
    ##   2

---


![Barplot of percentages of gene ontology accessions assigned to Biological Process GOslims for genes with at least one SNP. Excludes the generic "biological_process" GOslim to improve visualization of remaining categories.](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20211005_cbai_SNP_stats_barplot.png?raw=true)
