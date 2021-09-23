---
layout: post
title: Transcriptome Comparisons - C.bairdi Transcriptomes Evaluations with DETONATE rsem-eval on Mox
date: '2020-12-29 11:22'
tags:
  - DETONATE
  - Tanner crab
  - Chionoecetes bairdi
  - mox
  - transcriptome
categories:
  - Tanner Crab RNAseq
---
UPDATE: I'll lead in with the fact that this failed with an error message that I can't figure out. This will save the reader some time. I've posted the problem as [an Issue on the DETONATE GitHub repo](https://github.com/deweylab/detonate/issues/1), however it's clear that this software is no longer maintained, as the repo hasn't been updated in >3yrs; even lacking responses to Issues that are that old.

Here's the error message and some other details that could be useful for troubleshooting (which are beyond my knowledge - although I suspect that the `XM` tag is the culprit and the first entry in the BAM file has `XM:i:2` and the error message might suggest that `2` is not an acceptable value e.g. `Assertion `val == 0 || val == 1 || val == 5' failed.`):


```
rsem-synthesis-reference-transcripts cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta 0 0 0 /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta
Transcript Information File is generated!
Group File is generated!
Extracted Sequences File is generated!

rsem-preref cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta.transcripts.fa 1 cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta
Refs.makeRefs finished!
Refs.saveRefs finished!
cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta.idx.fa is generated!
cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta.n2g.idx.fa is generated!

rsem-parse-alignments cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.stat/cbai_transcriptome_v3.1.fasta b /gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments/cbai_transcriptome_v3.1.fasta.sorted.bam -t 3 -tag XM
rsem-parse-alignments: parseIt.cpp:92: void parseIt(SamParser*) [with ReadType = PairedEndReadQ; HitType = PairedEndHit]: Assertion `val == 0 || val == 1 || val == 5' failed.
"rsem-parse-alignments cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.stat/cbai_transcriptome_v3.1.fasta b /gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments/cbai_transcriptome_v3.1.fasta.sorted.bam -t 3 -tag XM" failed! Plase check if you provide correct parameters/options for the pipeline!
```

Here's what the head of the BAM file looks like:

```
[samwhite@n2233 20201224_cbai_bowtie2_transcriptomes_alignments]$ /gscratch/srlab/programs/samtools-1.10/samtools view cbai_transcriptome_v3.1.fasta.sorted.bam | head
A00147:108:HLLJFDMXX:1:1369:3893:6637	163	TRINITY_DN5604_c0_g2_i1	1	42	101M	=	81	181	GAAAGAAAAACCGACAGGAGGAATTTCTTTGTTACCAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAA	:FFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFF:FFFFFFFFFFFF:FFF:FFFFFFFFFFFFFFFFFFFFFFFF	AS:i:-2	XN:i:0	XM:i:2	XO:i:0	XG:i:0	NM:i:2	MD:Z:2G31A66	YS:i:0	YT:Z:CP
A00147:121:HLLVMDMXX:1:2159:5674:25786	163	TRINITY_DN5604_c0_g2_i1	4	42	101M	=	72	169	AGAAAAACCGACAGGAGGAATTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTA	FFFFFF:FFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:101	YS:i:0	YT:Z:CP
A00147:108:HLLJFDMXX:2:1420:13702:14920	163	TRINITY_DN5604_c0_g2_i1	5	42	101M	=	197	293	GAAAAACCGACAGGAGGAATTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAA	FFFFFFFFFFFFFFFFFF:FFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,FFFFFFFFFFF	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:101	YS:i:0	YT:Z:CP
A00147:108:HLLJFDMXX:2:1420:13431:15796	163	TRINITY_DN5604_c0_g2_i1	5	42	101M	=	197	293	GAAAAACCGACAGGAGGAATTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAA	FFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:101	YS:i:0	YT:Z:CP
A00147:121:HLLVMDMXX:1:1258:5141:32377	163	TRINITY_DN5604_c0_g2_i1	5	42	101M	=	107	203	GAAAAACCGACAGGAGGAATTTCTTTGTTACCAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAA	FFFFF,FFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:FFF:F:FFFFFFFF	AS:i:-1	XN:i:0	XM:i:1	XO:i:0	XG:i:0	NM:i:1	MD:Z:30A70	YS:i:0	YT:Z:CP
A00147:121:HLLVMDMXX:1:1259:7645:5838	163	TRINITY_DN5604_c0_g2_i1	5	42	101M	=	107	203	GAAAAACCGACAGGAGGAATTTCTTTGTTACCAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAA	FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFF	AS:i:-1	XN:i:0	XM:i:1	XO:i:0	XG:i:0	NM:i:1	MD:Z:30A70	YS:i:0	YT:Z:CP
A00147:108:HLLJFDMXX:1:1351:27082:1705	163	TRINITY_DN5604_c0_g2_i1	6	42	101M	=	158	253	AAAAACCGACAGGAGGAATTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAAA	FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:101	YS:i:0	YT:Z:CP
A00147:108:HLLJFDMXX:1:1475:28926:32706	163	TRINITY_DN5604_c0_g2_i1	6	42	101M	=	158	253	AAAAACCGACAGGAGGAATTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAAA	FFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:101	YS:i:0	YT:Z:CP
A00147:121:HLLVMDMXX:1:2162:31385:26381	163	TRINITY_DN5604_c0_g2_i1	6	42	101M	=	158	253	AAAAACCGACAGGAGGAANTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAAA	FFFFFFFFFFFFFFFFFF#FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:FFFFFFFFFFFFFF:	AS:i:-1	XN:i:0	XM:i:1	XO:i:0	XG:i:0	NM:i:1	MD:Z:18T82	YS:i:0	YT:Z:CP
A00147:121:HLLVMDMXX:2:1425:28745:30639	163	TRINITY_DN5604_c0_g2_i1	7	42	101M	=	169	263	AAAACCGACAGGAGGAATTTCTTTGTTAACAACAAAAACTAATATATTTCGCATACCTGACAGACATGGTGACAGCGCCTCTGATGTTCGCCGAATTAAAG	FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF:	AS:i:0	XN:i:0	XM:i:0	XO:i:0	XG:i:0	NM:i:0	MD:Z:101	YS:i:0	YT:Z:CP

```

[`bowtie2`](https://github.com/BenLangmead/bowtie2) commands to generate the BAM file:

```shell
  # Use bowtie2 and paired-end options
  # Uses settings specified for use with DETONATE
  # and for paired end reads when using DETONATE.
  ${programs_array[bowtie2]} \
  -x ${transcriptome_name} \
  -S ${transcriptome_name}.sam \
  --threads ${threads} \
  -1 ${R1_list} \
  -2 ${R2_list} \
  --sensitive \
  --dpad 0 \
  --gbar 99999999 \
  --mp 1,1 \
  --np 1 \
  --score-min L,0,-0.1 \
  --no-mixed \
  --no-discordant

  # Convert SAM to sorted BAM
  #
  ${programs_array[samtools_view]} \
  -b \
  ${transcriptome_name}.sam \
  | ${programs_array[samtools_sort]} \
  -m ${mem_per_thread} \
  --threads ${threads} \
  -o ${transcriptome_name}.sorted.bam \
  -
```

With all of that out of the way, you can find the original post below.

---

Using [`bowtie2`](https://github.com/BenLangmead/bowtie2), I generated [transcriptome alignments on 20201224](https://robertslab.github.io/sams-notebook/2020/12/24/Alignments-C.bairdi-RNAseq-Transcriptome-Alignments-Using-Bowtie2-on-Mox.html) to provide as input to the program [DETONATE (rsem-eval)](http://deweylab.biostat.wisc.edu/detonate/) which should be able to generate a score to allow for an assessment of which transcriptome assembly is most accurate. My previous attempt to [compare all of our _C.bairdi_ transcriptome assemblies using DETONATE on 20200601](https://robertslab.github.io/sams-notebook/2020/06/01/Transcriptome-Comparison-C.bairdi-Transcriptomes-Evaluations-with-DETONATE-on-Mox.html) consistently failed due to hitting time limits on Mox and that is why I created the [`bowtie2`](https://github.com/BenLangmead/bowtie2) alignments in a separate job; it was significantly faster than doing so within the [DETONATE (rsem-eval)](http://deweylab.biostat.wisc.edu/detonate/) software.

The job was run on Mox.

SBATCH script (GitHub):

- [20201229_cbai_detonate_transcriptome_evaluations.sh](https://github.com/RobertsLab/sams-notebook/blob/master/sbatch_scripts/20201229_cbai_detonate_transcriptome_evaluations.sh)

```shell
#!/bin/bash
## Job Name
#SBATCH --job-name=20201229_cbai_detonate_transcriptome_evaluations
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
#SBATCH --chdir=/gscratch/scrubbed/samwhite/outputs/20201229_cbai_detonate_transcriptome_evaluations

# Script runs DETONATE on each of the C.bairdi transcriptomes
# using Bowtie2 BAM alignments generated on 20201224.
# DETONATE will generate a corresponding "score" for each transcriptome,
# providing another metric by which to compare each assembly.

# Requires Bash >=4.0, as script uses associative arrays.


###################################################################################
# These variables need to be set by user

# Assign Variables
## frag_size is guesstimate of library fragment sizes
frag_size=500
bams_dir=/gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments
transcriptomes_dir=/gscratch/srlab/sam/data/C_bairdi/transcriptomes
threads=28

# Associative array of the transcriptomes and corresponding BAM file
declare -A transcriptomes_array
transcriptomes_array=(
["${transcriptomes_dir}/cbai_transcriptome_v1.5.fasta"]="${bams_dir}/cbai_transcriptome_v1.5.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v1.6.fasta"]="${bams_dir}/cbai_transcriptome_v1.6.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v1.7.fasta"]="${bams_dir}/cbai_transcriptome_v1.7.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v2.0.fasta"]="${bams_dir}/cbai_transcriptome_v2.0.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v2.1.fasta"]="${bams_dir}/cbai_transcriptome_v2.1.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v3.0.fasta"]="${bams_dir}/cbai_transcriptome_v3.0.fasta.sorted.bam" \
["${transcriptomes_dir}/cbai_transcriptome_v3.1.fasta"]="${bams_dir}/cbai_transcriptome_v3.1.fasta.sorted.bam"
)


###################################################################################

# Exit script if any command fails
set -e

# Load Python Mox module for Python module availability

module load intel-python3_2017


# Programs array

declare -A programs_array
programs_array=(
[detonate_trans_length]="/gscratch/srlab/programs/detonate-1.11/rsem-eval/rsem-eval-estimate-transcript-length-distribution" \
[detonate]="/gscratch/srlab/programs/detonate-1.11/rsem-eval/rsem-eval-calculate-score"
)




# Loop through each comparison
for transcriptome in "${!transcriptomes_array[@]}"
do

  # Remove path from transcriptome
  transcriptome_name="${transcriptome##*/}"

  # Set RSEM distance output filename
  rsem_eval_dist_mean_sd="${transcriptome_name}_true_length_dis_mean_sd.txt"


  # Determine transcript length
  # Needed for subsequent rsem-eval command.
  ${programs_array[detonate_trans_length]} \
  "${transcriptome}" \
  "${rsem_eval_dist_mean_sd}"


  # Run rsem-eval
  # Use paired-end options
  ${programs_array[detonate]} \
  --transcript-length-parameters "${rsem_eval_dist_mean_sd}" \
  --bam \
  --paired-end \
  "${transcriptomes_array[$transcriptome]}" \
  "${transcriptome}" \
  "${transcriptome_name}" \
  ${frag_size}

  # Capture FastA checksums for verification
  echo "Generating checksum for ${transcriptome_name}"
  md5sum "${transcriptome}" >> fasta.checksums.md5
  echo "Finished generating checksum for ${transcriptome_name}"
  echo ""

  # Capture BAM checksums for verification
  echo "Generating checksum for ${transcriptomes_array[$transcriptome]}"
  md5sum "${transcriptomes_array[$transcriptome]}" >> bam.checksums.md5
  echo "Finished generating checksum for ${transcriptomes_array[$transcriptome]}"
  echo ""

done

# Capture program options
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

echo ""
echo "Finished logging program options."
echo ""

echo ""
echo "Logging system PATH."
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

The job failed (virtually instantly) with this message:

```
rsem-synthesis-reference-transcripts cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta 0 0 0 /gscratch/srlab/sam/data/C_bairdi/transcriptomes/cbai_transcriptome_v3.1.fasta
Transcript Information File is generated!
Group File is generated!
Extracted Sequences File is generated!

rsem-preref cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta.transcripts.fa 1 cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta
Refs.makeRefs finished!
Refs.saveRefs finished!
cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta.idx.fa is generated!
cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta.n2g.idx.fa is generated!

rsem-parse-alignments cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.stat/cbai_transcriptome_v3.1.fasta b /gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments/cbai_transcriptome_v3.1.fasta.sorted.bam -t 3 -tag XM
rsem-parse-alignments: parseIt.cpp:92: void parseIt(SamParser*) [with ReadType = PairedEndReadQ; HitType = PairedEndHit]: Assertion `val == 0 || val == 1 || val == 5' failed.
"rsem-parse-alignments cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.temp/cbai_transcriptome_v3.1.fasta cbai_transcriptome_v3.1.fasta.stat/cbai_transcriptome_v3.1.fasta b /gscratch/scrubbed/samwhite/outputs/20201224_cbai_bowtie2_transcriptomes_alignments/cbai_transcriptome_v3.1.fasta.sorted.bam -t 3 -tag XM" failed! Plase check if you provide correct parameters/options for the pipeline!
```
