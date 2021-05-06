---
layout: post
title: RepeatMasker - C.gigas Rosling NCBI Genome GCA_902806645.1 on Mox
date: '2021-05-04 11:33'
tags: 
  - GCA_902806645.1
  - mox
  - repeatmasker
  - Crassostrea gigas
  - Pacific oyster
categories: 
  - Miscellaneous
---
Decided to [tackle this GitHub Issue about creating a transposable elements IGV track with the new Roslin _C.gigas_ genome](https://github.com/RobertsLab/resources/issues/1141), since it had been sitting for a while and I have code sitting around that's ready to roll for this type of thing.

Downloaded the NCBI [_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster) genome assembly [GCA_902806645.1](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/902/806/645/GCA_902806645.1_cgigas_uk_roslin_v1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.gz) and verified the MD5 checksum (not shown).

NOTE: The above listed NCBI assembly is from the "GenBank" assembly. There is another version, [GCF_902806645.1](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/806/645/GCF_902806645.1_cgigas_uk_roslin_v1/GCF_902806645.1_cgigas_uk_roslin_v1_genomic.fna.gz), from NCBI RefSeq. As far as I can tell, the only difference between the two is the sequence IDs; numbers of sequences and their lengths are the same.

Analysis was performed using [RepeatMasker](https://www.repeatmasker.org/) with two different species settings for comparison, if someone is interested.

- "all"

- "[_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster)"

The analysis was run on Mox.

SBATCH script (GitHub):

- [20210504_cgig_repeatmasker_roslin-GCA_902806645.1.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20210504_cgig_repeatmasker_roslin-GCA_902806645.1.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20210504_cgig_repeatmasker_roslin-GCA_902806645.1
## Allocation Definition
#SBATCH --account=coenv
#SBATCH --partition=coenv
## Resources
## Nodes
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=6-00:00:00
## Memory per node
#SBATCH --mem=120G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=samwhite@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20210504_cgig_repeatmasker_roslin-GCA_902806645.1

# Script to run RepeatMasker 4.1.0 on "Roslin" C.gigas NCBI genome assembly GCA_902806645.1


###################################################################################
# These variables need to be set by user

# Set working directory
wd=$(pwd)

# Set number of CPUs to use
threads=40

# Input/output files
source_genome_fasta=/gscratch/srlab/sam/data/C_gigas/genomes/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna
genome_fasta=GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna

# Programs
## Minimap2
repeat_masker=/gscratch/srlab/programs/RepeatMasker-4.1.0/RepeatMasker

# Species array (used for RepeatMasker species setting)
species=("all" "crassostrea gigas")

# Programs associative array
declare -A programs_array
programs_array=(
[repeat_masker]=${repeat_masker} \
)



###################################################################################

# Exit script if any command fails
set -e


# Generate checksum for "new" FastA
md5sum ${source_genome_fasta} > genome_fasta.md5

for species in "${species[@]}"
do

  # Check species name and create appropriate directory naem
  if [ "${species}" = "crassostrea gigas" ]; then

    mkdir "repeatmasker-species_C.gigas_roslin-GCA_902806645.1" && cd $_
    rsync -av ${source_genome_fasta} .

    else
    mkdir "repeatmasker-species_all_roslin-GCA_902806645.1" && cd $_
    rsync -av ${source_genome_fasta} .

  fi

  # Run RepeatMasker
  # Uses all species
  # Generates GFF output
  # 'excln' calculates repeat densities excluding runs of X/N >20bp
  ${programs_array[repeat_masker]} \
  ${genome_fasta} \
  -species "${species}" \
  -parallel ${threads} \
  -gff \
  -excln
  
  # Remove the genome FastA file
  rm ${genome_fasta}

  cd ${wd}

done

###################################################################################

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
    fi
    ${programs_array[$program]} -h
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

echo "Finished logging system PATH"
```

---

#### RESULTS

Was much faster than I expected, as previous runs on Emu/Roadrunner have taken _days_. This was just 1.5hrs:

![RepeatMasker runtime for GCA_902806645.1 on Mox](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20210504_cgig_repeatmasker_roslin-GCA_902806645.1_runtime.png?raw=true)

Important to note is the stark differences between results with the species set to "all" vs. "[_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster)". For example, the number of "Retroelements" identified with the "all" setting was 14,694 vs 23 with the "[_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster)" setting!

Output folder:

- [20210504_cgig_repeatmasker_roslin-GCA_902806645.1/](https://gannet.fish.washington.edu/Atumefaciens/20210504_cgig_repeatmasker_roslin-GCA_902806645.1/)

##### Species Setting: [_Crassostrea gigas_ (Pacific oyster)](http://en.wikipedia.org/wiki/Pacific_oyster)

  - RepeatMasker GFF:

    - [20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_C.gigas_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.out.gff](https://gannet.fish.washington.edu/Atumefaciens/20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_C.gigas_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.out.gff)

  - Summary Table (text):

    - [20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_C.gigas_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.tbl](https://gannet.fish.washington.edu/Atumefaciens/20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_C.gigas_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.tbl)

    ```
    ==================================================
    file name: GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna
    sequences:           236
    total length:  647887097 bp  (647868030 bp excl N/X-runs)
    GC level:         33.50 %
    bases masked:   12745378 bp ( 1.97 %)
    ==================================================
                  number of      length   percentage
                  elements*    occupied  of sequence
    --------------------------------------------------
    Retroelements           23         1649 bp    0.00 %
      SINEs:               23         1649 bp    0.00 %
      Penelope              0            0 bp    0.00 %
      LINEs:                0            0 bp    0.00 %
        CRE/SLACS            0            0 bp    0.00 %
        L2/CR1/Rex          0            0 bp    0.00 %
        R1/LOA/Jockey       0            0 bp    0.00 %
        R2/R4/NeSL          0            0 bp    0.00 %
        RTE/Bov-B           0            0 bp    0.00 %
        L1/CIN4             0            0 bp    0.00 %
      LTR elements:         0            0 bp    0.00 %
        BEL/Pao             0            0 bp    0.00 %
        Ty1/Copia           0            0 bp    0.00 %
        Gypsy/DIRS1         0            0 bp    0.00 %
          Retroviral        0            0 bp    0.00 %

    DNA transposons          0            0 bp    0.00 %
      hobo-Activator        0            0 bp    0.00 %
      Tc1-IS630-Pogo        0            0 bp    0.00 %
      En-Spm                0            0 bp    0.00 %
      MuDR-IS905            0            0 bp    0.00 %
      PiggyBac              0            0 bp    0.00 %
      Tourist/Harbinger     0            0 bp    0.00 %
      Other (Mirage,        0            0 bp    0.00 %
        P-element, Transib)

    Rolling-circles          0            0 bp    0.00 %

    Unclassified:            2           84 bp    0.00 %

    Total interspersed repeats:        1733 bp    0.00 %


    Small RNA:              68        12259 bp    0.00 %

    Satellites:              0            0 bp    0.00 %
    Simple repeats:     231620     11214786 bp    1.73 %
    Low complexity:      32034      1516600 bp    0.23 %
    ==================================================

    * most repeats fragmented by insertions or deletions
      have been counted as one element
      Runs of >=20 X/Ns in query were excluded in % calcs


    The query species was assumed to be crassostrea gigas
    RepeatMasker Combined Database: Dfam_3.1
                                            
    run with rmblastn version 2.10.0+
    ```
    
##### Species Setting: All

- RepeatMasker GFF:

  - [20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_all_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.out.gff](https://gannet.fish.washington.edu/Atumefaciens/20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_all_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.out.gff)

- Summary Table (text):

  - [20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_all_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.tbl](https://gannet.fish.washington.edu/Atumefaciens/20210504_cgig_repeatmasker_roslin-GCA_902806645.1/repeatmasker-species_all_roslin-GCA_902806645.1/GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna.tbl)

```
==================================================
file name: GCA_902806645.1_cgigas_uk_roslin_v1_genomic.fna
sequences:           236
total length:  647887097 bp  (647868030 bp excl N/X-runs)
GC level:         33.50 %
bases masked:   19522553 bp ( 3.01 %)
==================================================
               number of      length   percentage
               elements*    occupied  of sequence
--------------------------------------------------
Retroelements        14694      4937654 bp    0.76 %
   SINEs:              585        34638 bp    0.01 %
   Penelope            262        28681 bp    0.00 %
   LINEs:             7164      1209298 bp    0.19 %
    CRE/SLACS            0            0 bp    0.00 %
     L2/CR1/Rex       1266       159741 bp    0.02 %
     R1/LOA/Jockey     157        13339 bp    0.00 %
     R2/R4/NeSL        129        65251 bp    0.01 %
     RTE/Bov-B         980       263384 bp    0.04 %
     L1/CIN4          1582       175410 bp    0.03 %
   LTR elements:      6945      3693718 bp    0.57 %
     BEL/Pao           863      1015388 bp    0.16 %
     Ty1/Copia          38        10630 bp    0.00 %
     Gypsy/DIRS1      3578      2423374 bp    0.37 %
       Retroviral     1416        90219 bp    0.01 %

DNA transposons      13542      2099703 bp    0.32 %
   hobo-Activator     3213       229649 bp    0.04 %
   Tc1-IS630-Pogo      560        47379 bp    0.01 %
   En-Spm                0            0 bp    0.00 %
   MuDR-IS905            0            0 bp    0.00 %
   PiggyBac             30         2479 bp    0.00 %
   Tourist/Harbinger   711       100695 bp    0.02 %
   Other (Mirage,       37         1842 bp    0.00 %
    P-element, Transib)

Rolling-circles       2594       517630 bp    0.08 %

Unclassified:          508        42673 bp    0.01 %

Total interspersed repeats:     7080030 bp    1.09 %


Small RNA:            2485       177888 bp    0.03 %

Satellites:           1212       172569 bp    0.03 %
Simple repeats:     223699     10101220 bp    1.56 %
Low complexity:      31668      1475381 bp    0.23 %
==================================================

* most repeats fragmented by insertions or deletions
  have been counted as one element
  Runs of >=20 X/Ns in query were excluded in % calcs


The query species was assumed to be root          
RepeatMasker Combined Database: Dfam_3.1
                                         
run with rmblastn version 2.10.0+
```