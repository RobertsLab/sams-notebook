---
layout: post
title: Data Received - C.bairdi RNAseq Day9-12-26 Infected-Uninfected
date: '2019-10-03 13:30'
tags:
  - tanner crab
  - RNAseq
  - Chionoecetes bairdi
categories:
  - Tanner Crab RNAseq
---
#### UPDATE (20191024): This post details receipt of incomplete data. Additional sequencing was performed and that additional data was received 20191024. This [notebook entry on 20191024](https://robertslab.github.io/sams-notebook/2019/10/24/Data-Received-C.bairdi-RNAseq-Day9-12-26-Infected-Uninfected.html) contains details on FastQ concatenation of the data below and the data received on 20191024.

Finally received the RNAseq data back from NWGC that we submitted on [20190521](https://robertslab.github.io/sams-notebook/2019/05/21/Sample-Submission-Tanner-Crab-Infected-vs-Uninfected-RNAseq.html)!

Here's a table with the library names and the FastQ naming schemes.


| NWGC Sample ID | Investigator Sample ID |
|----------------|------------------------|
| 329772         | D9_infected            |
| 329773         | D9_uninfected          |
| 329774         | D12_infected           |
| 329775         | D12_uninfected         |
| 329776         | D26_infected           |
| 329777         | D26_uninfected         |

---

Here's the list of FastQ files:

- 329774_S1_L001_R1_001.fastq.gz

- 329774_S1_L001_R2_001.fastq.gz

- 329774_S1_L002_R1_001.fastq.gz

- 329774_S1_L002_R2_001.fastq.gz

- 329775_S2_L001_R1_001.fastq.gz

- 329775_S2_L001_R2_001.fastq.gz

- 329775_S2_L002_R1_001.fastq.gz

- 329775_S2_L002_R2_001.fastq.gz

- 329776_S3_L001_R1_001.fastq.gz

- 329776_S3_L001_R2_001.fastq.gz

- 329776_S3_L002_R1_001.fastq.gz

- 329776_S3_L002_R2_001.fastq.gz

- 329777_S4_L001_R1_001.fastq.gz

- 329777_S4_L001_R2_001.fastq.gz

- 329777_S4_L002_R1_001.fastq.gz

- 329777_S4_L002_R2_001.fastq.gz


All files have been added to nightingales/C_bairdi:

- [nightingales/C_bairdi](https://owl.fish.washington.edu/nightingales/C_bairdi/)

Will update readme and [Nightingales Google sheet](http://b.link/nightingales)

---

I just realized that the list of FastQ files does not match the list of NWGC Sample IDs (329772 and 329773 do not have corresponding FastQ files). I've emailed the facility and this was their response:


>Machiko Threlkeld
>6:14 PM (3 hours ago)
>to Sam, Peter, Stephanie
>
>Hi Sam,
>
>I am sorry. I should have been more clear. 2 samples of yours failed sequencing steps and we didn't have any more samples left to repeat the process. The QC results show that those two had less than 10ul to start with.
>
>Here is the summary of your project:
>
>\# total samples submitted = 6
>
>\# samples approved for sequencing = 6
>
>\# samples passed sequencing QC and released = 4
>
>I hope you understand.
>
>Thank you,
>Machiko

So, this is the first I'm hearing of any concern with these two particular samples. Especially since they passed the initial QC on [20190610](https://robertslab.github.io/sams-notebook/2019/05/21/Sample-Submission-Tanner-Crab-Infected-vs-Uninfected-RNAseq.html)!

Here's my response; I'll update this post when they respond:


>Sam White <samwhite@uw.edu>
>8:58 PM (32 minutes ago)
>to Machiko, Peter, Stephanie
>
>Hi Machiko,
>
>I definitely do not understand.
>
>The initial QC report you sent to me indicated that these two samples PASSED QC (there was only one sample that failed QC - that sample ended up getting sequenced without issue).
>
>Additionally, I'm not sure why the volume of the samples is relevant. The QC report clearly indicated that both samples had less than 10uL, yet they PASSED QC. Also, if there was a concern with low sample volume, why not add the additional water to each sample? If the volumes had been adjusted to 10uL, the resulting concentrations for both of those samples would have been ~100ng/uL; on par with the other samples. So, I am having difficulty believing that the sample volume was an issue of any sort.
>
>Regardless, the QC report indicated those two samples passed QC. So now what?
>
>Thanks for any insight you can provide.
>
>
>Sam

---

>Stephanie A Krauter
>Tue, Oct 8, 9:29 PM
>to Sam, Machiko, Peter
>
>Hi Sam,
>
>Hopefully I can clarify. If not, I'm happy to set up a phone call.
>
>Samples pass initial sample QC if they have enough mass and the quality is good.  Six samples passed this QC step and entered the sequencing pipeline.  Once samples move into library preparation a certain volume is needed for the prep.  This is the volume aspect Machiko was speaking about.  The two samples that failed sequencing QC did have enough sample for one prep but not multiple. Library prep is only repeated if there is an instrument error or kit issue.  This was not the case for the two samples that unfortunately failed library prep as the control looked good as did all the other samples in that batch. The volume of the samples does not have an affect on the success of a library prep.  Machiko brings up the volume aspect just to note that if you wanted to attempt to sequence these samples again you would need to resubmit samples as all the sample you provided was used in library preparation.
>
>Hope this helps.  If you have any other questions, I am happy to help.

>Best,
>Stephanie

---

>Sam White <samwhite@uw.edu>
>Tue, Oct 8, 9:54 PM
>to Stephanie, Machiko, Peter
>
>Thanks for the clarification, Stephanie.
>
>So, those two samples were not sequenced due to an instrument error and/or kit error? Did we just get lucky that the other four samples in this project did not get affected by the same instrument/kit error?
>
>I'm also still confused on why the sample volumes wouldn't have been adjusted to the minimum of 10uL, particularly if they had sufficient RNA...
>
>Regardless, I guess these samples are toast.
>
>May we please get refunded for the costs associated with those two samples ($299sample; total = $598)?
>
>I've also noticed that we received ~20 - 33%% less data for each sample than we were expecting, based on the project quote. We were expecting ~50M reads per sample, but have received 40M reads or less per sample (sample 329777 is an exception with ~48M reads).
>
>What are your thoughts on this data output, relative to what was promised?
>
>Thanks for all of your help and time with this project.>
>
>
>
>Sam

---


>Stephanie A Krauter
>Oct 8, 2019, 10:04 PM
>to Sam, Machiko, Peter
>
>Hi Sam,
>
>As I stated in my previous email. Your samples did not fail because of an instrument error or kit failure. The library process looked good as evidence by the successful control and the success of other samples in that batch. Your samples failed due to the samples themselves.
>
>Since this was not an instrument or kit failure, but rather a sample issue, you will still be charged the cost to prep these samples.
>
>Again the volume of the samples was not a concern and had no bearing on the outcome of the library for these samples.
>
>I will look into your concern regarding the number of reads per sample tomorrow.
>
>Best,
>Stephanie

---


>Sam White <samwhite@uw.edu>
>Wed, Oct 9, 9:01 AM
>to Stephanie, Machiko, Peter
>
>Ah, thanks Stephanie. I didn't follow what you were saying in your initial email. Thanks for re-wording!
>
>For additional clarification on what went wrong, primarily to attempt to avoid failures in future sequencing projects that we send to you, may I have more info?
>
>When did the failure for these samples occur? When they were sequenced?
>
>I'm still unclear as to why these two samples could not be repeated? Could you please elaborate on this?
>
>Could you please send me the initial Bioanalyzer electropherograms for the samples associated with this project? I'd like to see if there's any noticeable differences between the failed samples and the successful samples to try to screen samples in the future.
>
>Also, in regards to you blaming the failure on the samples (which is certainly a possibility), then what's the point of your initial QC? Since the samples passed your standards as acceptable samples, then I don't see how the sample failure doesn't fall on your facility's shoulders. Don't get me wrong, I fully understand your point of view in that the controls worked and all that, but your facility said the samples I submitted were acceptable for sequencing, based on the standards set by your lab. Thus, our samples met the necessary requirements for processing and sequencing. Subsequent failure should no longer be relegated back to us, the customer, since you already approved the samples.
>
>Another point that I wanted to address was the turnaround time for this project. From initial sample drop off to data receipt was 4.5 months. After samples passed QC and were entered into the pipeline, it took 3.75 months to get data. This is well beyond the 10 - 12 week window that was promised. This was disappointing and frustrating. Adding to the frustration was that I received no communication from NWGC regarding the project status, why it was delayed, an updated ETA, when our data was ready, etc.
>
>We have some upcoming RNAseq later this year and we'd like to continue to use NWGC and support a fellow Univ. of Washington lab. However, the turnaround time is a serious concern. Is there anything we can do in the future to ensure that our samples would be processed in the 10 - 12 week time frame? Is there an "expedited" service available?
>
>Finally, I neglected to say "thanks" last night for your quick, after-hours email responses! Thanks for that! That's going above and beyond, and is definitely not necessary.
>
>And, thanks for sticking with me and helping me understand what went on with this project. I sincerely appreciate your time and help.
>
>
>Sam

---


>Stephanie A Krauter
>Wed, Oct 9, 10:23 AM
>to Sam, Machiko, Peter
>
>Absolutely, Sam!  Again, I am happy to set up a phone call if that is easier to answer all of your questions.
>
>In the meantime, I'd like to apologize for the delay in your project and lack of communication. The center's turnaround time is about 10-12 weeks once samples pass QC.  That being said, we do try to get samples returned as soon as possible meaning there are times that investigators receive their samples much sooner than the 10 weeks. Conversely the turnaround time may be longer if the production queue is long.  However, that does not excuse the lack of communication and you absolutely should have been contacted. I will make sure to talk with my team about this today.
>
>We do have a rush option which includes a fee of 10% of the total project cost.
>
>Initial QC only means that samples meet the minimum requirements to enter the pipeline. It absolutely does not guarantee that a successful library can be made from the sample nor do we guarantee that. To ensure that a sample failure was not due to something we did we include a control sample. All of these samples were prepped with liquid handlers and again, the control and all other samples in this batch were successful indicating that the reason these samples failed was an issue with the sample.
>
>One main reason a sample fails to successfully generate a library is sample quality. Typically any sample with a RIN less than 7 fails initial QC. However, a bioanalyzer wasn't run since you stated "Additionally, I just wanted to pass along the heads up that these samples will not generate a Bioanalyzer RIN. The samples we're submitting are from tanner crab and this species only generates a single rRNA band, thus, no RIN." and therefore quality was not assessed. This may or may not have been a contributing factor in why these samples failed.
>
>In regards to billing, you were quoted ~$299 per sample.  That is the cost for the entire service.  However, when Peter invoices he only bills for the portion of the service performed.  Since the two samples were not sequenced, you will only be billed up through library prep.
>
>Hope this clarifies things. I will circle back after my 10:30 meeting regarding the number of reads per sample.
>
>Best,
>Stephanie

---


>Stephanie A Krauter
>Fri, Oct 11, 11:12 AM
>to Sam, Machiko, Peter
>
>Hi Sam,
>
>It appears our project manager did jump the gun a bit on releasing these.  I have asked the sequencing team to top these samples off and they will be going on the sequencers today.
>
>Best,
>Stephanie

---


>Sam White <samwhite@uw.edu>
>Mon, Oct 14, 7:14 AM (11 days ago)
>to Stephanie, Machiko, Peter
>
>Thanks for the update and billing clarification. The quote didn't break out individual costs of library prep/sequencing, so I just assumed it was a all/none per sample pricing scheme.
>
>Sorry about the confusion on the Bioanalyzer. My intent was to simply give the heads up that the samples would appear "abnormal" (compared to mammalian samples); not suggest they not be run. Would've been useful to see if these samples appeared different than the others.
>
>Anyway, thanks again for taking the time to handle my ranting and taking the time to explain what was happening here! Looking forward to the additional data.
>
>
>Sam

---
