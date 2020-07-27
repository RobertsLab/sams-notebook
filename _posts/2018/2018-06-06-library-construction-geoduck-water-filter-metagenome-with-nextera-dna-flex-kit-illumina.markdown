---
author: kubu4
comments: true
date: 2018-06-06 22:19:38+00:00
layout: post
slug: library-construction-geoduck-water-filter-metagenome-with-nextera-dna-flex-kit-illumina
title: Library Construction - Geoduck Water Filter Metagenome with Nextera DNA Flex
  Kit (Illumina)
wordpress_id: 3400
author:
  - kubu4
categories:
  - Miscellaneous
tags:
  - bioanalyzer
  - geoduck
  - library prep
  - metagenomics
  - nextera
  - Panopea generosa
  - Qubit 1x dsDNA HS Assay Kit
  - Qubit 3.0
---

Made Illumina libraries with goeduck metagenome water filter DNA I previously isolated on:





  * [20180411](https://robertslab.github.io/sams-notebook/2018/04/11/dna-isolation-quantification-metagenomics-water-filters.html)



  * [20180426](https://robertslab.github.io/sams-notebook/2018/04/26/dna-isolation-quantification-metagenomics-water-filters-2.html)






We used a free Nextera DNA Flex Kit (Illumina) that we won in a contest held by Illumina!

Followed the manufacturer's protocol for input DNA quantities <10ng with the following changes/notes:





  * PCR steps performed in 200uL thin-walled PCR tubes.



  * Magnetic separations were performed in 1.7mL snap cap tubes.



  * Thermalcycler: PTC-200 (MJ Research)



  * Magnet: DynaMag 2 (Invitrogen)






See the Library Calcs sheet (link below) for original sample names and subsequent library sample names.



##### IMPORTANT!



_The sheet also contains the indexes used for each library. This info will be necessary for sequencing facility._

Library Calcs (Google Sheet):





  * [20180606_nextera_library_geoduck_metagenome_calcs](https://docs.google.com/spreadsheets/d/131Z45uaUycJhyZJRxbEVlOviyoGqV44GehUxaaOWcGo/edit?usp=sharing)



Links to the Illumina manuals are below:



  * [Nextera DNA Flex Kit Manual (PDF)](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/Illumina_nextera-dna-flex-library-prep-reference-guide-1000000025416-01_20180523.pdf)



  * [Illumina Index Adapters Pooling Guide (PDF)](https://github.com/RobertsLab/resources/blob/master/protocols/Commercial_Protocols/Illumina_index-adapters-pooling-guide-1000000041074-02_20180523.pdf)






After library construction was completed, individual libraries were quantified on the Roberts Lab Qubit 3.0 (Invitrogen) with the Qubit 1x dsDNA HS Assay Kit.

2uL of each sample was used for each assay.

Library quality was assessed using the Seeb Lab 2100 Bioanalyzer (Agilent) with a High Sensitivity DNA Kit, using 1uL of each sample.

Libraries were stored in the small -20C in FTR213:





  * [Sam's gDNA Box #2](https://docs.google.com/spreadsheets/d/1SWzKMKh7LBOgTfvEhJamE6pZFsTpRXY7otzXUC5fZSM/edit?usp=sharing)



  * Slots H6 - I3






* * *





##### Results:





Qubit Raw Data (Google Sheet):





  * [20180606_qubit_geoduck_metagenome_libraries](https://docs.google.com/spreadsheets/d/1UzLYw0LIyN9SF9qs51Kk3Keozeqzor1RIjFKRPuzLwM/edit?usp=sharing)



Bioanalyzer File (XAD):



  * [20180606_133725.xad](https://owl.fish.washington.edu/Athaliana/20180606_133725.xad)



All libraries have DNA in them, so that's good!

Except for one library (Library Geoduck MG #04 is bad), the other libraries look OK (i.e. not great). Compared to the example on Pg. 12 in the manual, these libraries all have some extra high molecular weight stuff.

When selecting the range listed in the Nextera Kit manual, the average fragment size is ~530bp - the expected size should be ~600bp.





![](https://owl.fish.washington.edu/Athaliana/20180606_bioanalyzer_all_electropherograms_geoduck_mg_libraries.PNG)

Spoke with Steven about Library Geoduck MG #04 and we've opted to just leave it out.

All other samples were pooled into a single samples according to the manufacturer's protocol.

This pooled sample was stored in the same -20C box as above, in position I4.



* * *



UPDATE 20180808

After some confusion with the sequencing facility, I contacted Illumina regarding adapter sequences. I used the sequences provided for the Nextera DNA 24 CD Indexes (which was the index kit we used) on p.18 of the [Illumina Index Adapter Pooling Guide](https://support.illumina.com/content/dam/illumina-support/documents/documentation/chemistry_documentation/experiment-design/index-adapters-pooling-guide-1000000041074-02.pdf).

As it turns out, these sequences are incorrect. The correct sequences are on p.12 of that document (the Nextera DNA 96 CD Indexes).

I've updated the Google Sheet (linked above) to reflect the correct index sequences.

Email from Illumina is below. Even though he specifically references the H705 adapter, the correct sequence information for all i7 index adapters is found on p.12.



<blockquote>
  Hi Sam,

  Thanks for the clarification! For the index sequence H705, this sequence is incorrect in the Index Adapters Pooling Guide. The correct information is found on page 12 of the same document and should be:

  H705 “AGGAGTCC” (Bases in Adapter) and “GGACTCCT” (bases for sample sheet.

  This is also consistent with the Illumina Adapters letter.

  We have provided this feed back to our colleagues to update the document so that all the information is consistent.

  Thanks for your patience and understanding while we evaluated this issue. If we do have any other questions or concerns, please let us know and we would be happy to discuss this further.

  Best,

  Russell

  Russell Chan, Ph.D.

  Technical Applications Scientist

  Illumina Technical Support

  Telephone available 24 hours

  Monday through Friday

  Technical Bulletins: https://support.illumina.com/bulletins.html

  Trainings: https://support.illumina.com/traidexes
</blockquote>
