---
layout: post
title: sRNA-seq Alignments - E5 Coral A.pulchra P.meandrina Using ShortStack on Mox
date: '2023-06-28 14:20'
tags: 
  - sRNAseq
  - E5
  - coral
  - Pocillopora meandrina
  - Acropora pulchra
  - shortstack
  - mox
categories: 
  - E5
---
Steven had [asked that I align the coral E5 sRNA-seq reads using ShortStack](https://github.com/urol-e5/deep-dive/issues/19) (GitHub Issue). I previously [trimmed the sRNA-seq reads to 35bp in length](https://robertslab.github.io/sams-notebook/2023/06/20/Trimming-and-QC-E5-Coral-sRNA-seq-Data-fro-A.pulchra-P.evermanni-and-P.meandrina-Using-FastQC-flexbar-and-MultiQC-on-Mox.html) (notebook). Next up was to actually perform the alignments using [ShortStack4](https://github.com/MikeAxtell/ShortStack). _A.pulchra_ was aligned to the _P.millepora_ genome, per [this GitHub Issue](https://github.com/urol-e5/deep-dive/issues/20#issuecomment-1574121809). This was run on Mox.

NOTE: Up to this point, I've processed all three species simultaneously for which we currently have sRNA-seq data: _A.pulchra_, _P.evermanni_, and _P.meandrina_. However, [we currently haven't decided on the canonical genome to use for _P.evermanni_](https://github.com/urol-e5/deep-dive/issues/21#issuecomment-1579178682) (GitHub Issue), so _P.evermanni_ is _not_ included in this analysis.

Skip to [RESULTS](#results).

SLURM script (GitHub):

- [20230628-E5_coral-ShortStack-sRNAseq.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20230628-E5_coral-ShortStack-sRNAseq.sh)


```bash
#!/bin/bash
## Job Name
#SBATCH --job-name=20230628-E5_coral-ShortStack-sRNAseq
## Allocation Definition
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-00:00:00
## Memory per node
#SBATCH --mem=500G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq

### E5 sRNA-seq alignments using trimmed reads from 20230620 with ShortStack.

### Expects FastQ read directory paths to be formatted like:

# /gscratch/srlab/sam/data/P_meandrina/sRNAseq/trimmed

### Uses trimmed reads from 20230620. Expect FastQ filename format like:

# *flexbar_trim.20230621_[12]*.fastq.gz


###################################################################################
# These variables need to be set by user

## Assign Variables

# Set FastQ filename patterns
fastq_pattern='**flexbar_trim.20230621*.fastq.gz'

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
species_array=("A_pulchra" "P_meandrina")

# Programs associative array
declare -A programs_array
programs_array=(
    [ShortStack]="ShortStack"
    )

# Genomes associative array
declare -A genomes_array
genomes_array=(
    [A_pulchra]="/gscratch/srlab/sam/data/A_millepora/genomes/GCF_013753865.1_Amil_v2.1_genomic.fasta" \
    [P_meandrina]="/gscratch/srlab/sam/data/P_meandrina/genomes/Pocillopora_meandrina_HIv1.assembly.fasta"
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

Run time seemed relatively fast; just a bit over 4hrs:

![Screencap showing ShortStack runtime on Mox of 4hrs 11mins 59secs](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20230628-E5_coral-ShortStack-sRNAseq-runtime.png?raw=true)

Output folder:

- [20230628-E5_coral-ShortStack-sRNAseq/](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/)


### [_A.pulchra_](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/)

&nbsp;&nbsp;&nbsp;&nbsp;#### Results files:
- [alignment_details.tsv](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/alignment_details.tsv) (48K)

  - MD5: `d301b898b36c2022f22db538fa28b9eb`

| readfile                                                                                                                                          | mapping_type | read_length | count   |
|---------------------------------------------------------------------------------------------------------------------------------------------------|--------------|-------------|---------|
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | U            | <21         | 120030  |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | U            | 21          | 43333   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | U            | 22          | 105592  |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | U            | 23          | 65039   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | U            | 24          | 84409   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | U            | >24         | 3636233 |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | P            | <21         | 196501  |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | P            | 21          | 61672   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | P            | 22          | 73193   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | P            | 23          | 69147   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | P            | 24          | 73631   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | P            | >24         | 5674586 |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | R            | <21         | 25655   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | R            | 21          | 11222   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | R            | 22          | 12916   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | R            | 23          | 14482   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | R            | 24          | 19433   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | R            | >24         | 1400108 |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | H            | <21         | 7685    |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | H            | 21          | 2697    |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | H            | 22          | 3260    |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | H            | 23          | 3166    |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | H            | 24          | 4394    |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | H            | >24         | 238409  |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | N            | <21         | 104184  |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | N            | 21          | 60191   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | N            | 22          | 52988   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | N            | 23          | 59083   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | N            | 24          | 76366   |
| /gscratch/scrubbed/samwhite/outputs/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam | N            | >24         | 5252357 |

- [Counts.txt](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/Counts.txt) (1.3M)

  - MD5: `593069a45787e4176c5e17efe3b87d49`

| Coords                    | Name      | MIRNA | sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1 | sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_2 | sRNA-ACR-145-S1-TP2.flexbar_trim.20230621_1 | sRNA-ACR-145-S1-TP2.flexbar_trim.20230621_2 | sRNA-ACR-150-S1-TP2.flexbar_trim.20230621_1 | sRNA-ACR-150-S1-TP2.flexbar_trim.20230621_2 | sRNA-ACR-173-S1-TP2.flexbar_trim.20230621_1 | sRNA-ACR-173-S1-TP2.flexbar_trim.20230621_2 | sRNA-ACR-178-S1-TP2.flexbar_trim.20230621_1 | sRNA-ACR-178-S1-TP2.flexbar_trim.20230621_2 |
|---------------------------|-----------|-------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|---------------------------------------------|
| NC_058066.1:152483-152906 | Cluster_1 | N     | 1                                           | 3                                           | 126                                         | 137                                         | 1                                           | 2                                           | 2                                           | 2                                           | 2                                           | 3                                           |
| NC_058066.1:161082-161790 | Cluster_2 | N     | 46                                          | 57                                          | 48                                          | 54                                          | 210                                         | 319                                         | 33                                          | 25                                          | 190                                         | 270                                         |
| NC_058066.1:203244-203650 | Cluster_3 | N     | 17                                          | 15                                          | 37                                          | 30                                          | 11                                          | 15                                          | 15                                          | 10                                          | 41                                          | 33                                          |
| NC_058066.1:204535-205150 | Cluster_4 | N     | 6                                           | 6                                           | 270                                         | 254                                         | 18                                          | 16                                          | 12                                          | 6                                           | 56                                          | 59                                          |
| NC_058066.1:205746-206966 | Cluster_5 | N     | 82                                          | 93                                          | 450                                         | 453                                         | 66                                          | 71                                          | 253                                         | 239                                         | 239                                         | 127                                         |
| NC_058066.1:210855-211344 | Cluster_6 | N     | 340                                         | 351                                         | 213                                         | 210                                         | 83                                          | 81                                          | 0                                           | 1                                           | 656                                         | 647                                         |
| NC_058066.1:349656-351297 | Cluster_7 | N     | 497                                         | 510                                         | 1246                                        | 1247                                        | 841                                         | 772                                         | 768                                         | 762                                         | 19                                          | 21                                          |
| NC_058066.1:351491-353439 | Cluster_8 | N     | 3253                                        | 3186                                        | 2069                                        | 2014                                        | 2158                                        | 2159                                        | 2113                                        | 2084                                        | 169                                         | 174                                         |
| NC_058066.1:776275-776779 | Cluster_9 | N     | 0                                           | 0                                           | 318                                         | 280                                         | 10                                          | 11                                          | 58                                          | 61                                          | 180                                         | 175                                         |

- [Results.txt](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/Results.txt) (2.8M)

  - MD5: `0ae9d3267579e8614e57a73a3490430d`

| Locus                     | Name      | Chrom       | Start  | End    | Length | Reads | UniqueReads | FracTop           | Strand | MajorRNA                       | MajorRNAReads | Short | Long  | 21 | 22  | 23  | 24  | DicerCall | MIRNA | known_miRNAs |
|---------------------------|-----------|-------------|--------|--------|--------|-------|-------------|-------------------|--------|--------------------------------|---------------|-------|-------|----|-----|-----|-----|-----------|-------|--------------|
| NC_058066.1:152483-152906 | Cluster_1 | NC_058066.1 | 152483 | 152906 | 424    | 279   | 77          | 0.512544802867383 | .      | UAAGUACUUUAUCAACUAACUCUAGGCA   | 77            | 3     | 260   | 0  | 3   | 0   | 13  | N         | N     | NA           |
| NC_058066.1:161082-161790 | Cluster_2 | NC_058066.1 | 161082 | 161790 | 709    | 1252  | 475         | 0.623801916932907 | .      | AGUCGACGAAUUUGCCAUGAAGCUAGUA   | 71            | 39    | 1129  | 26 | 10  | 5   | 43  | N         | N     | NA           |
| NC_058066.1:203244-203650 | Cluster_3 | NC_058066.1 | 203244 | 203650 | 407    | 224   | 112         | 0.535714285714286 | .      | UUCUGACUCUAUUAGCAACGAAGACUUU   | 38            | 2     | 217   | 2  | 1   | 0   | 2   | N         | N     | NA           |
| NC_058066.1:204535-205150 | Cluster_4 | NC_058066.1 | 204535 | 205150 | 616    | 703   | 343         | 0.500711237553343 | .      | UCCCAACACGUCUAGACUGUACAAUUUCU  | 33            | 4     | 682   | 2  | 0   | 7   | 8   | N         | N     | NA           |
| NC_058066.1:205746-206966 | Cluster_5 | NC_058066.1 | 205746 | 206966 | 1221   | 2073  | 732         | 0.535455861070912 | .      | CAAAAGAGCGGACAAAAUAGUCGACAGAUU | 152           | 15    | 1999  | 8  | 6   | 13  | 32  | N         | N     | NA           |
| NC_058066.1:210855-211344 | Cluster_6 | NC_058066.1 | 210855 | 211344 | 490    | 2582  | 667         | 0.497676219984508 | .      | UAAUACUUGUAGUGAAGGUUCAAUCUCGA  | 97            | 17    | 2355  | 13 | 18  | 39  | 140 | N         | N     | NA           |
| NC_058066.1:349656-351297 | Cluster_7 | NC_058066.1 | 349656 | 351297 | 1642   | 6683  | 2375        | 0.501571150680832 | .      | UCAGCUUGGAAAUGACAGCUUUUGACGU   | 294           | 53    | 6417  | 22 | 45  | 44  | 102 | N         | N     | NA           |
| NC_058066.1:351491-353439 | Cluster_8 | NC_058066.1 | 351491 | 353439 | 1949   | 19379 | 3490        | 0.498632540378761 | .      | UUUCAAAUCAAAGAUCUUCGCAACGAUGA  | 1115          | 135   | 18526 | 59 | 101 | 247 | 311 | N         | N     | NA           |
| NC_058066.1:776275-776779 | Cluster_9 | NC_058066.1 | 776275 | 776779 | 505    | 1093  | 284         | 0.517840805123513 | .      | UGUUAUUGUCUUUGAGUGCCCAAAUGUGU  | 64            | 3     | 1080  | 2  | 3   | 2   | 3   | N         | N     | NA           |


&nbsp;&nbsp;&nbsp;&nbsp;#### GFFs:

- [Results.gff3](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/Results.gff3) (1.8M)

  - MD5: `84be69fd3fc4a02fd64c83ad0cbdaa63`

- [known_miRNAs.gff3](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/known_miRNAs.gff3) (88K)

  - MD5: `d9c407fde49dad766805eed720ef56b0`

&nbsp;&nbsp;&nbsp;&nbsp;#### BAMs:

- [merged_alignments.bam](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/merged_alignments.bam) (3.2G)

  - MD5: `6cdc0a903f5761528518453c5cf735c4`

- [sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_1.bam) (301M)

  - MD5: `519cb501a0f5fa32539d3571c9017929`

- [sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_2.bam](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-140-S1-TP2.flexbar_trim.20230621_2.bam) (307M)

  - MD5: `4b01b68a60ae5563c1dbada3eae9cde9`

- [sRNA-ACR-145-S1-TP2.flexbar_trim.20230621_1.bam](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-145-S1-TP2.flexbar_trim.20230621_1.bam) (337M)

  - MD5: `3347abd91870d380d719281e091571a0`

- [sRNA-ACR-145-S1-TP2.flexbar_trim.20230621_2.bam](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-145-S1-TP2.flexbar_trim.20230621_2.bam) (340M)

  - MD5: `056895a4d142c5c0bc0cd0ea52f866a7`

- [sRNA-ACR-150-S1-TP2.flexbar_trim.20230621_1.bam](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/A_pulchra/ShortStack_out/sRNA-ACR-150-S1-TP2.flexbar_trim.20230621_1.bam) (358M)

  - MD5: `968fcf9472f4d9da500878a7bc4d4e87`

### [_P.meandrina_](https://gannet.fish.washington.edu/Atumefaciens/20230628-E5_coral-ShortStack-sRNAseq/P_meandrina/)

&nbsp;&nbsp;&nbsp;&nbsp;#### Results files:

  - 

&nbsp;&nbsp;&nbsp;&nbsp;#### GFFs:

&nbsp;&nbsp;&nbsp;&nbsp;#### BAMs: