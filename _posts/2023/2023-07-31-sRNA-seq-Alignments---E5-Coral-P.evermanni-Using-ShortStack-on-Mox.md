---
layout: post
title: sRNA-seq Alignments - E5 Coral P.evermanni Using ShortStack on Mox
date: '2023-07-31 06:02'
tags: 
  - sRNA
  - E5
  - Porites evermanni
  - ShortStack
  - mox
categories: 
  - E5
---
[Steven asked that I run ShortStack on the E5 _P.evermanni_ sRNA-seq](https://github.com/urol-e5/deep-dive/issues/19#issuecomment-1656494994) (GitHub Issue) data we had. I used [trimmed sRNA-seq reads from 20230620](https://robertslab.github.io/sams-notebook/2023/06/20/Trimming-and-QC-E5-Coral-sRNA-seq-Data-fro-A.pulchra-P.evermanni-and-P.meandrina-Using-FastQC-flexbar-and-MultiQC-on-Mox.html) (notebook entry) and the _P.evermanni_ genome (`Porites_evermanni_v1.fa`) from [https://www.genoscope.cns.fr/corals/genomes.html](https://www.genoscope.cns.fr/corals/genomes.html), along with the known, mature miRNAs FastA from [https://www.mirbase.org/download/](https://www.mirbase.org/download/) (downloaded 20230628). The job was run on Mox.

SLURM script (GitHub):

- [20230731-peve-E5_coral-ShortStack-sRNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230731-peve-E5_coral-ShortStack-sRNAseq.sh)

```bash
#!/bin/bash
## Job Name
#SBATCH --job-name=20230731-peve-E5_coral-ShortStack-sRNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq

### E5 sRNA-seq alignments using trimmed reads from 20230620 with ShortStack.

### Expects FastQ read directory paths to be formatted like:

# /gscratch/srlab/sam/data/P_evermanni/sRNAseq/trimmed

### Uses trimmed reads from 20230620. Expect FastQ filename format like:

# *flexbar_trim.20230621_[12]*.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set FastQ filename patterns
fastq_pattern='*flexbar_trim.20230621*.fastq.gz'

# Set number of CPUs to use
threads=40


# Input/output files
fastq_checksums=input_fastq_checksums.md5
sRNA_FastA="/gscratch/srlab/sam/data/miRBase/20230628-miRBase-mature.fa"

# Data directories
reads_dir=/gscratch/srlab/sam/data

## Inititalize arrays
trimmed_fastq_array=()



# Species array (must match directory name usage)
species_array=("P_evermanni")

# Programs associative array
declare -A programs_array
programs_array=(
    [ShortStack]="ShortStack"
    )

# Genomes associative array
declare -A genomes_array
genomes_array=(
    [P_evermanni]="/gscratch/srlab/sam/data/P_evermanni/genomes/Porites_evermanni_v1.fa" \
    )


###################################################################################

# Exit script if any command fails
set -e

# Load Anaconda
# Uknown why this is needed, but Anaconda will not run if this line is not included.
. "/gscratch/srlab/programs/anaconda3/etc/profile.d/conda.sh"

# Activate flexbar environment
conda activate ShortStack4_env


# Set working directory
working_dir=$(pwd)

for species in "${species_array[@]}"
do
    ## Inititalize arrays
    trimmed_fastq_array=()


    echo "Creating ${species} directory ..." 

    mkdir --parents "${species}"

    # Change to species directory
    cd "${species}"


    # ShortStack output directory
    output_dir=$(pwd)

    echo "Now in ${PWD}."

    # Sync raw FastQ files to working directory
    echo ""
    echo "Transferring files via rsync..."

    rsync --archive --verbose \
    ${reads_dir}/${species}/sRNAseq/trimmed/${fastq_pattern} .

    echo ""
    echo "File transfer complete."
    echo ""

    ### Run ShortStack ###

    ### NOTE: Do NOT quote trimmed_fastq_list
    # Create array of trimmed FastQs
    trimmed_fastq_array=(${fastq_pattern})

    # Pass array contents to new variable as space-delimited list
    trimmed_fastq_list=$(echo "${trimmed_fastq_array[*]}")

    echo "Beginning ShortStack on ${species} sRNAseq using genome FastA:"
    echo "${genomes_array[${species}]}"
    echo ""

    ## Run ShortStack ##
    ${programs_array[ShortStack]} \
    --genomefile "${genomes_array[${species}]}" \
    --readfile ${trimmed_fastq_list} \
    --known_miRNAs ${sRNA_FastA} \
    --dn_mirna \
    --threads ${threads} \
    --outdir ${output_dir}/ShortStack_out

    echo "ShortStack on ${species} complete!"
    echo ""


    ######## Create MD5 checksums for raw FastQs ########

    for fastq in ${fastq_pattern}
    do
        echo "Generating checksum for ${fastq}"
        md5sum "${fastq}" | tee --append ${fastq_checksums}
        echo ""
    done

    ######## END MD5 CHECKSUMS ########

    ######## REMOVE INPUT FASTQS ########
    echo "Removing input FastQs."
    echo ""
    rm ${fastq_pattern}
    echo "Input FastQs removed."
    echo""

    echo "Now moving back to ${working_dir}."
    cd "${working_dir}"
    echo ""

done

####################################################################

# Capture program options
if [[ "${#programs_array[@]}" -gt 0 ]]; then
  echo "Logging program options..."
  for program in "${!programs_array[@]}"
  do
    {
    echo "Program options for ${program}: "
    echo ""
    # Handle samtools help menus
    if [[ "${program}" == "samtools_index" ]] \
    || [[ "${program}" == "samtools_sort" ]] \
    || [[ "${program}" == "samtools_view" ]]
    then
      ${programs_array[$program]}

    # Handle DIAMOND BLAST menu
    elif [[ "${program}" == "diamond" ]]; then
      ${programs_array[$program]} help

    # Handle NCBI BLASTx menu
    elif [[ "${program}" == "blastx" ]]; then
      ${programs_array[$program]} -help

    # Handle fastp menu
    elif [[ "${program}" == "fastp" ]]; then
      ${programs_array[$program]} --help
    else
    ${programs_array[$program]} -h
    fi
    echo ""
    echo ""
    echo "----------------------------------------------"
    echo ""
    echo ""
  } &>> program_options.log || true

    # If MultiQC is in programs_array, copy the config file to this directory.
    if [[ "${program}" == "multiqc" ]]; then
      cp --preserve ~/.multiqc_config.yaml multiqc_config.yaml
    fi
  done
fi


# Document programs in PATH (primarily for program version ID)
{
date
echo ""
echo "System PATH for $SLURM_JOB_ID"
echo ""
printf "%0.s-" {1..10}
echo "${PATH}" | tr : \\n
} >> system_path.log
```


---

#### RESULTS

Job took just under two hours to run:

![Screencap showing Mox job runtime of 1hr 10mins and 54secs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230731-peve-E5_coral-ShortStack-sRNAseq-runtime.png?raw=true)

Output folder:

- [20230731-peve-E5_coral-ShortStack-sRNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/)

  - [20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/)

- [alignment_details.tsv](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/alignment_details.tsv) (32K)

  - MD5: `12e0c5eee19a1909734db85ec4512536`

  ```
  readfile                                                                                                                                                 mapping_type  read_length  count
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  U             <21          566073
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  U             21           169195
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  U             22           208380
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  U             23           173305
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  U             24           168110
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  U             >24          3403975
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  P             <21          369674
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  P             21           137171
/gscratch/scrubbed/samwhite/outputs/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam  P             22           108728
  ```

- [Counts.txt](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/Counts.txt) (1.2M)

  - MD5: `3f98fd9f50c5eaa7b70f40b552303538`

  ```
  Coords                                     Name       MIRNA  sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1  sRNA-POR-73-S1-TP2.flexbar_trim.20230621_2  sRNA-POR-79-S1-TP2.flexbar_trim.20230621_1  sRNA-POR-79-S1-TP2.flexbar_trim.20230621_2  sRNA-POR-82-S1-TP2.flexbar_trim.20230621_1  sRNA-POR-82-S1-TP2.flexbar_trim.20230621_2
Porites_evermani_scaffold_1:45716-46131    Cluster_1  N      0                                           0                                           78                                          78                                          18                                          17
Porites_evermani_scaffold_1:406306-406734  Cluster_2  N      157                                         169                                         24                                          26                                          11                                          12
Porites_evermani_scaffold_1:409840-410269  Cluster_3  N      121                                         100                                         30                                          39                                          24                                          21
Porites_evermani_scaffold_1:465246-465668  Cluster_4  N      12                                          12                                          35                                          33                                          137                                         137
Porites_evermani_scaffold_1:468473-468950  Cluster_5  N      55442                                       55280                                       31667                                       31535                                       28192                                       28143
Porites_evermani_scaffold_1:476827-477250  Cluster_6  N      27                                          27                                          22                                          22                                          68                                          68
Porites_evermani_scaffold_1:486441-486868  Cluster_7  N      16                                          16                                          6                                           6                                           36                                          35
Porites_evermani_scaffold_1:534424-534866  Cluster_8  N      158                                         157                                         117                                         116                                         352                                         348
Porites_evermani_scaffold_1:729097-729587  Cluster_9  N      2122                                        2115                                        1684                                        1663                                        2840                                        2833
  ```

- [Results.txt](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/Results.txt) (2.7M)

  - MD5: `11ade4844fc32dfe52b9d1544353740d`

  ```
  Locus                                      Name       Chrom                        Start   End     Length  Reads   UniqueReads  FracTop              Strand  MajorRNA                           MajorRNAReads  Short  Long    21   22   23   24    DicerCall  MIRNA  known_miRNAs
Porites_evermani_scaffold_1:45716-46131    Cluster_1  Porites_evermani_scaffold_1  45716   46131   416     191     91           0.5026178010471204   .       CCAAGGAGCUGUUAAAAC                 8              45     72      18   16   18   22    N          N      NA
Porites_evermani_scaffold_1:406306-406734  Cluster_2  Porites_evermani_scaffold_1  406306  406734  429     399     124          0.5162907268170426   .       UGAGUGUAUUCUUGAACUGUUUUCCAAC       47             9      367     3    1    5    14    N          N      NA
Porites_evermani_scaffold_1:409840-410269  Cluster_3  Porites_evermani_scaffold_1  409840  410269  430     335     82           0.48656716417910445  .       UGGAACUCCGAUUUAGAACUUGCAAACUUU     56             0      326     1    2    0    6     N          N      NA
Porites_evermani_scaffold_1:465246-465668  Cluster_4  Porites_evermani_scaffold_1  465246  465668  423     366     115          0.4972677595628415   .       AAGUUGCUCUGAAGAUUAUGU              39             66     135     96   15   40   14    N          N      NA
Porites_evermani_scaffold_1:468473-468950  Cluster_5  Porites_evermani_scaffold_1  468473  468950  478     230259  2291         0.49925518655079715  .       AGCACUGAUGACUGUUCAGUUUUUCUGAAUU    68303          3892   223407  229  276  305  2150  N          N      NA
Porites_evermani_scaffold_1:476827-477250  Cluster_6  Porites_evermani_scaffold_1  476827  477250  424     234     76           0.5                  .       GUACGAGACGAUUACGAAGACACG           14             66     78      0    24   30   36    N          N      NA
Porites_evermani_scaffold_1:486441-486868  Cluster_7  Porites_evermani_scaffold_1  486441  486868  428     115     22           0.4956521739130435   .       AUAUUGACGAAUCCUGGCCUAGUGAACC       27             0      107     0    0    8    0     N          N      NA
Porites_evermani_scaffold_1:534424-534866  Cluster_8  Porites_evermani_scaffold_1  534424  534866  443     1248    232          0.49759615384615385  .       GAGACGUAAACUUAUAGCUUUGGCU          205            62     888     120  28   70   80    N          N      NA
Porites_evermani_scaffold_1:729097-729587  Cluster_9  Porites_evermani_scaffold_1  729097  729587  491     13257   889          0.49867994267179605  .       CACUUAGUGACAAGCCAGAACUGUCUGACCACA  3000           409    11622   262  478  244  242   N          N      NA
  ```

#### BAMs

- [merged_alignments.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/merged_alignments.bam) (1.5G)

  - MD5: `cbebc137669b7499b2fce8e75be0099f`

- [sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_1.bam) (225M)

  - MD5: `b4186554eb1d3b5716ef4de298d2487b`

- [sRNA-POR-73-S1-TP2.flexbar_trim.20230621_2.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-73-S1-TP2.flexbar_trim.20230621_2.bam) (227M)

  - MD5: `65f842c98ced9f818f93aae051a89d7f`

- [sRNA-POR-79-S1-TP2.flexbar_trim.20230621_1.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-79-S1-TP2.flexbar_trim.20230621_1.bam) (254M)

  - MD5: `f36efde12eaa25e035e3b8f999f9f866`

- [sRNA-POR-79-S1-TP2.flexbar_trim.20230621_2.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-79-S1-TP2.flexbar_trim.20230621_2.bam) (256M)

  - MD5: `faf18e5de4c946c8c9129aa203d2a8eb`

- [sRNA-POR-82-S1-TP2.flexbar_trim.20230621_1.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-82-S1-TP2.flexbar_trim.20230621_1.bam) (280M)

  - MD5: `bbc58e1486202c3b02caa3a8e4220765`

- [sRNA-POR-82-S1-TP2.flexbar_trim.20230621_2.bam](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/sRNA-POR-82-S1-TP2.flexbar_trim.20230621_2.bam) (281M)

  - MD5: `7d75154b4b2b7132f5a89a2a00c84bd7`

#### GFFs

- [Results.gff3](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/Results.gff3) (1.7M)

  - MD5: `087bba3ed90b43f3c663a61bdbabbf82`

- [known_miRNAs.gff3](https://gannet.fish.washington.edu/Atumefaciens/20230731-peve-E5_coral-ShortStack-sRNAseq/P_evermanni/ShortStack_out/known_miRNAs.gff3) (204K)

  - MD5: `5df2467b645659472bc23d041756e94e`
