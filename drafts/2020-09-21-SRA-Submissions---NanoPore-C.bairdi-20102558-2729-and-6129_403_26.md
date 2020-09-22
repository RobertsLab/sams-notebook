---
layout: post
title: SRA Submissions - NanoPore C.bairdi 20102558-2729 and 6129_403_26
date: '2020-09-21 20:35'
tags:
  - Tanner crab
  - Chionoecetes bairdi
  - NanoPore
  - SRA
  - sequencing read archive
  - NCBI
  - sra submission
categories:
  - SRA Submission
---
Submitted our _C.bairdi_ NanoPore sequencing data from [20200109 (Sample 20102558-2729 - uninfected EtOH-preserved muscle)](https://robertslab.github.io/sams-notebook/2020/01/09/NanoPore-Sequencing-C.bairdi-gDNA-Sample-20102558-2729.html) and from [20200311 (Sample 6129_403_26 - RNAlater-preserved _Hematodinium_-infected hemolymph)](https://robertslab.github.io/sams-notebook/2020/03/11/NanoPore-Sequencing-C.bairdi-gDNA-6129_403_26.html) to the [NCBI Sequencing Read Archive(SRA)](https://www.ncbi.nlm.nih.gov/sra).

I submitted the FastQ files instead of the raw Fast5 files ([20102558-2729-Run-01 conversion on 20200904](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-20102558-2729-Run-01-on-Mox-with-GPU-Node.html), [20102558-2729-Run-02 conversion on 20200904](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-20102558-2729-Run-02-on-Mox-with-GPU-Node.html), and [6129_403_26 conversion on 20200904](https://robertslab.github.io/sams-notebook/2020/09/04/Data-Wrangling-NanoPore-Fast5-Conversion-to-FastQ-of-C.bairdi-6129_403_26-on-Mox-with-GPU-Node.html)) because NCBI SRA requires NanoPore Fast5 files to be basecalled; I did _not_ perform basecalling during the original sequencing runs - only during FastQ conversion.

All samples were submitted to NCBI SRA [BioProject PRJNA625480](https://www.ncbi.nlm.nih.gov/sra/?term=PRJNA625480). NCBI indicates this is what should be referenced in publications. However, here are the SRA "Run" accessions:

| Sample        | Run                                                                        |
|---------------|----------------------------------------------------------------------------|
| 20102558-2729 | [SRR12683090](https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR12683090)  |
| 6129_403_26   | [SRR12689542)](https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR12689542) |

Will add info to [Nightingales](http://b.link/nightingales) (Google Sheet).
