---
layout: post
title: Nextflow - Trials and Tribulations of Installing and Using NF-Core RNAseq
date: '2022-03-25 13:11'
tags: 
  - mox
  - nextflow
  - RNAseq
  - nf-core
categories: 
  - Miscellaneous
---
#### INSTALLATION

For some reason, I struggled to get things installed correctly. Installing [Nextflow](https://www.nextflow.io/) was straightforward and didn't have any issues. First bump in the road came from the [installation directions(https://nf-co.re/rnaseq/3.6#quick-start)] for [NF-Core RNAseq](https://nf-co.re/rnaseq). The instructions say "Download the pipeline and test it..". Well, that doesn't indicate how/where to download. To add to the confusion (will be evident how in a bit), the previous step says to "only use Conda as a last resort". Okay, so how do I get the [NF-Core RNAseq](https://nf-co.re/rnaseq)? I downloaded the latest release from the [GitHub Release page](https://github.com/nf-core/rnaseq/releases/tag/3.6). After doing that, I couldn't figure out how to just get a basic command (e.g. `nf-core download`) to run. I managed to discover that I likely needed to install [nf-core Tools](https://nf-co.re/tools/). However, doing that meant that I would have to use either [Conda](https://bioconda.github.io/recipes/nf-core/README.html) or Docker. Docker seemed overly complicated (didn't want to have to deal with re-learning container/image usage _and_ within the confines of a SLURM environment like Mox - this whole thing was supposed to be quick and easy!) and using Conda was strongly discouraged for the [NF-Core RNAseq](https://nf-co.re/rnaseq). For "simplicity" I went the Conda route. This is where everything went awry...

The pipeline is designed to have internet access to update and download newer config files automatically. Knowing that running SLURM job wouldn't have internet access, I followed the [instructions for downloading a pipeline for offlne use](https://nf-co.re/tools/#downloading-pipelines-for-offline-use). Running the `nf-core download` command initiated an interactive mode to specify things, like which version to download, whether or not to provide a directory for `$NXF_SINGULARITY_CACHEDIR`, and whether or not to compress the Singularity container that would be downloaded. Setting `$NXF_SINGULARITY_CACHEDIR` seemed to cause issues. Additionally, the Singulairity download was surprisingly fast.

As it all turns out, I think the issue was that I had downloaded [NF-Core RNAseq](https://nf-co.re/rnaseq) from the GitHub release _and_ installed via Conda. Essentially, Conda creates the same directory structure in the same location as the [NF-Core RNAseq](https://nf-co.re/rnaseq) install from the GitHub release. And, this fact, I think broke everything. 

To fix the installation, I uninstalled all things related to [NF-Core RNAseq](https://nf-co.re/rnaseq), but I left the [Nextflow](https://www.nextflow.io/) installation. Then, I installed [nf-core Tools](https://nf-co.re/tools/) (and, subsequently the RNAseq package) using _only_ the Conda installation. Once I did that (and activated the nf-core/rnaseq conda environment) and ran the `nf-core download`, I noticed that the Singularity download took _significantly_ longer than previous attempts, which led me to think that things were working, finally.

#### RUNNING

After finally getting things installed properly, I encountered a number of problems just trying to get the pipeline to run successfully. There were a number of small issues that lead to a lot of troubleshooting:

Error:

Transcript names not matching GFF.

Solution:

If supplying a transcriptome, the names in the FastA description lines have to match those in the GFF. Since we _de novo_ assembled our transcriptome using [`Trinity`](https://github.com/trinityrnaseq/trinityrnaseq/wiki), it has Trinity IDs which do not correspond to the genome assembly/annotation. So, I dropped the transcriptome option for the run.

Error:

```
Unable to parse config file: '/gscratch/srlab/programs/nf-core-rnaseq-3.6/workflow/nextflow.config'

  Cannot compare java.lang.Boolean with value 'true' and java.lang.Integer with value '0'
```

Solution:

```--trim_nextseq``` option actually requires an integer. Documentation didn't indicate such at the time, but may now though as I brought this to the attention of the developers via their Slack group and the discussion indicated they should add this info to the websit.

Error:

```
Unable to parse config file: '/gscratch/srlab/programs/nf-core-rnaseq-3.6/workflow/nextflow.config'
```

Solution:

When using a custom config file, one cannot use the `check_max()`. I had just been modifying the values for RAM, CPUs, run times that were in the `base.config` file. The `base.confi` file utilizes the `check_max()` function. After a bunch of sleuthing on the NF-Core RNAseq GitHub and Slack groups, I finally discovered this solution. Here's what the custom, functional config looks like:

- `/gscratch/srlab/programs/nf-core-rnaseq-3.6/configs/conf/base-srlab_500GB_node.config`

```
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/rnaseq Nextflow base config file modified by Sam White on 20220321 for use
    on Roberts Lab 500GB Mox node.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    A 'blank slate' config file, appropriate for general use on most high performance
    compute environments. Assumes that all software is installed and available on
    the PATH. Runs in `local` mode - all jobs will be run on the logged in environment.
----------------------------------------------------------------------------------------
*/

process {

    cpus   = 28
    memory = 500.GB
    time   = 30.d

    errorStrategy = { task.exitStatus in [143,137,104,134,139] ? 'retry' : 'finish' }
    maxRetries    = 1
    maxErrors     = '-1'

    // Process-specific resource requirements
    withLabel:process_low {
        cpus   = 28
        memory = 500.GB
        time   = 30.d
    }
    withLabel:process_medium {
        cpus   = 28
        memory = 500.GB
        time   = 30.d
    }
    withLabel:process_high {
        cpus   = 28
        memory = 500.GB
        time   = 30.d
    }
    withLabel:process_long {
        time   = 30.d
    }
    withLabel:process_high_memory {
        memory = 500.GB
    }
    withLabel:error_ignore {
        errorStrategy = 'ignore'
    }
    withLabel:error_retry {
        errorStrategy = 'retry'
        maxRetries    = 2
    }
    withName:CUSTOM_DUMPSOFTWAREVERSIONS {
        cache = false
    }
}
```

Error:

`Error Message: Strand is neither '+' nor '-'!`

```
ERROR nextflow.processor.TaskProcessor - Error executing process > 'NFCORE_RNASEQ:RNASEQ:PREPARE_GENOME:MAKE_TRANSCRIPTS_FASTA (rsem/Panopea-generosa-v1.0.fa)'
Caused by:
  Process `NFCORE_RNASEQ:RNASEQ:PREPARE_GENOME:MAKE_TRANSCRIPTS_FASTA (rsem/Panopea-generosa-v1.0.fa)` terminated with an error exit status (255)
Command executed:
  rsem-prepare-reference \
      --gtf Panopea-generosa-v1.0_genes.gtf \
      --num-threads 28 \
       \
      rsem/Panopea-generosa-v1.0.fa \
      rsem/genome
  
  cp rsem/genome.transcripts.fa .
  
  cat <<-END_VERSIONS > versions.yml
  "NFCORE_RNASEQ:RNASEQ:PREPARE_GENOME:MAKE_TRANSCRIPTS_FASTA":
      rsem: $(rsem-calculate-expression --version | sed -e "s/Current version: RSEM v//g")
      star: $(STAR --version | sed -e "s/STAR_//g")
  END_VERSIONS
Command exit status:
  255
Command output:
  rsem-extract-reference-transcripts rsem/genome 0 Panopea-generosa-v1.0_genes.gtf None 0 rsem/Panopea-generosa-v1.0.fa
  "rsem-extract-reference-transcripts rsem/genome 0 Panopea-generosa-v1.0_genes.gtf None 0 rsem/Panopea-generosa-v1.0.fa" failed! Plase check if you provide correct parameters/options for the pipeline!
Command error:
  The GTF file might be corrupted!
  Stop at line : Scaffold_02    GenSAS_5d82b316cd298-trnascan   transcript      27467   27541   38.1    .       .       transcript_id "21513.GS22252506.PGEN_.tRNA00000001"; gene_id "21513.GS22252506.PGEN_.tRNA00000001"; Name "Thr"; anti_codon "CGT"; gene_no "1376";
```

Solution:

As it turns out, this wasn't an issue with the pipeline, it's really an issue with [how RSEM handles GTF strand parsing](https://github.com/deweylab/RSEM/blob/e4dda70e90fb5eb9b831306f1c381f8bbf71ef0e/GTFItem.h#L64). Even though the [GFF spec](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md) indicates that strand column can be one of `+`, `-`, `.`, or `?`, RSEM only parses for `+` or `-`. And, as it turns out, our genome GFF has some `.` for strand info. Looking through our "merged" GenSAS GFF, it turns out there are two sets of annotations that only have `.` for strand info (`GenSAS_5d82b316cd298-trnascan` & `RNAmmer-1.2`). So, the decision needed to be made if we should convert these sets strands to an "artificial" value (e.g. set all of them to `+`), or eliminate them from the input GFF. I ended up converting `GenSAS_5d82b316cd298-trnascan` strand to `+` and eliminated `RNAmmer-1.2` from the final input GFF.

Overall, it was a bit of an arduos process, but it's all running now... Will update if I encounter any more hurdles.