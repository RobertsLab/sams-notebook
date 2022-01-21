---
layout: post
title: Metagenomics - Refining Anvio Binning
date: '2019-06-19 08:25'
tags:
  - metagenomics
  - Panopea generosa
  - geoduck
  - anvio
categories:
  - Miscellaneous
---
UPDATE 20220121: THIS IS AN INCOMPLETE POST AND IS ONLY POSTED FOR POSTERITY.

Due to time constraints and limits on the amount of effort wanted to be put into this project, I did not proceed with a complete analysis using [Anvi'o](https://anvio.org/). However, there was a fair amount of work put into using this program, so I've decided to post what I had originally written up, despite it being incomplete. It may serve as a useful reference for someone else in the lab in the future. Since this stage of analysis requires a graphical user interface, it was performed on in a dedicated `conda` envrionment for [Anvi'o](https://anvio.org/) on `swoose` and not on `Mox`. Original [Anvi'o](https://anvio.org/) database generation was [performed on 20190401](https://robertslab.github.io/sams-notebook/2019/04/01/Metagenomics-Taxonomic-Diversity-Comparisons-from-Geoduck-Water-with-Anvio-on-Mox.html). 

---

Check the initial data binning:

```shell
anvi-interactive \
--profile-db PROFILE.db \
--contigs-db contigs.db \
--collection-name CONCOCT
```

That generates this:

![initial anvio dendrogram screencap](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_initial_dendrogram.png?raw=true)



Table representation of initial data binning:

```shell
anvi-summarize \
--pan-or-profile-db PROFILE.db \
--contigs-db contigs.db \
--collection-name CONCOCT \
--output-dir MERGED_SUMMARY
```

This command generates an `index.html` file (see Results section below for link) and takes ~10 minutes to complete. Here's the portion showing the binning completion/redundancy info (there's much, much more data present in that file):

![initial Anvio binning table showing completion/redundancy](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_initial_bins_table.png?raw=true)



Refine the bins:

```shell
anvi-refine \
--profile-db PROFILE.db \
--contigs-db contigs.db \
--collection-name CONCOCT \
--bin-id Bin_75
```

In the screencap below, the region of the dendrogram marked as "Bin_75_1" shows a drastic difference in coverage in the MG7 track at this particular split. Additionally, looking at the quick stats shown for this newly identified bin (in the window pane to the left), one can see that Completion is now 99% and Redundancy is only 1.4%; a marked improvement on the automatic binning.

![Screencap of Bin_75 refinement dendrogram](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin75-01.png?raw=true)



There does appear to be a problem with the binning data, though. It appears that many bins exhibit Completion/Redundancy data of 0.00%, however clicking on that data in the summary table reveals that is incorrect:

![Screencap of summary table showing incorrect Completion/Redundancy info](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_summarize_zero-percent-completion-problem-01.png?raw=true)


Here's an example of what happens when refining Bin 3:

![Screencap of Bin 3 refinement dendrogram showing incorrect Completion/Redundancy info](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_summarize_zero-percent-completion-problem-02.png?raw=true)

![Screencap of Bin 3 summary table after refinement - table still shows Completion/Redundancy of 0.00% ](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_summarize_zero-percent-completion-problem-03.png?raw=true)

![Screencap of interactive dendrogram with Bin_3_1 highlighted to show continuing display of 0.00% Completion/Redundancy](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_summarize_zero-percent-completion-problem-04.png?raw=true)

---

Ah, as it turns out, this has been fixed in the "master" commit in Anvi'o (thanks to the Anvi'o devs for their fast responses to my questions on their [Slack channel](https://anvio.slack.com/archives/C8SFMGYF3/p1561043792054900)!!).

Here's how the upgrade process went.

Clone current version of Anvio's GitHub repo:

```shell
git clone --recursive https://github.com/merenlab/anvio.git
```
---

Create an Anaconda environment for Anvio', using Python version 3.6.

Then, activate the newly created Anaconda environment.

Within the cloned Anvi'o repo, use Python to execute the `setup.py` file.

Finally, use `pip` to complete the Anvi'o installation.

```shell
conda create --yes --name anvio python=3.6

conda activate anvio

python setup.py

pip install --editable
```

---

Now, we should be able to run `anvio-interactive` on the database again and get an updated version of stats for each bin:

```shell
conda activate anvio
(anvio) sam@swoose:~/analyses/20190619_anvio$ ~/programs/anvio_git_master_bfbcbb3/bin/anvi-interactive --profile-db PROFILE.db --contigs-db contigs.db --collection-name CONCOCT


Config Error: The database at 'contigs.db' is outdated (its version is v12, but your anvi'o
              installation only knows how to deal with v13). You can migrate your database
              without losing any data using the program `anvi-migrate-db`.  
```

So, I ran the `anvi-migrate-db` command as recommended:

`~/programs/anvio_git_master_bfbcbb3/bin/anvi-migrate-db contigs.db`

This message popped up:

```shell
* The contigs database is now 13. Unfortunatly this update removed all single-copy
core gene HMMs from your contigs database :( We are very sorry about this, but
we only did it to be able to offer you nicer things. It is best if you re-run
`anvi-run-hmms` program from scratch. Doing that will not remove any 'non-
default' HMM profiles you may have added in this contigs database, so you have
nothing to worry about.
```

So, I ran the `anvi-run-hmms` command on the database to complete the upgrae process:

`~/programs/anvio_git_master_bfbcbb3/bin/anvi-run-hmms -c contigs.db --num-threads 23`

---

After upgrading, here's how things look:

![Screencap of dendgrogram after update now shows Completion/Redundancy info for all bins](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_interactive_dendrogram_fix-01.png?raw=true)


![Screencap of Summarize table after update](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_summarize_zero-percent-completion-problem-fix-01.png?raw=true)

![Screencap of Summarize table after update with inset](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_summarize_zero-percent-completion-problem-fix-02.png?raw=true)

Additionally, the Anvi'o refine interface provides an informative pop up when clicking on the Completion info on the left pane that explains in user-friendly lingo what your Completion/Redundancy data might suggest:

![Screencap of Anvi'o refine binning dendrogram pop up info for mediocre bin with "composite" genome](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_c-r_info_box-01.png?raw=true)

![Screencap of Anvi'o refine binning dendrogram pop up info for bad bin with low confidence](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_c-r_info_box-02.png?raw=true)

![Screencap of Anvi'o refine binning dendrogram pop up info for high quality/confidence bin](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin25-1_c-r_info_box.png?raw=true)


Clearly, there's a _lot_ of manual binning that needs to take place in order to refine the bins with excessive Completion/Redundancy info...

![Screencap of dendrogram after extensive refinement](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_interactive_dendrogram_refined.png?raw=true)

Here are some examples of how you perform further binning (refinement) of the intial bins. Basically, visually examing the coverage plots (the black histograms), along with the tree in the center of the plot. Select regions where there is a noticeable difference in magnitude of the histograms _and_ where there are distinct branches in the tree. Anvi'o practically has these already identified, but for some reason doesn't bin them separately; sometimes even when there are high Completion and low Redudnacy scores.

#### Bin 46 Manual Refinement

![Manual refinement of Bin 46](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin46-01.png?raw=true)

---

#### Bin 61 Manual Refinement

![Manual refinement of Bin 61](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin61-01.png?raw=true)

---

#### Bin 68 Manual Refinement

![Manual refinement of Bin 68](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin68-01.png?raw=true)

---

#### Bin 73 Manual Refinement

![Manual refinement of Bin 73](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin73-01.png?raw=true)

---

#### Bin 74 Manual Refinement

![Manual refinement of Bin 74](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin74-01.png?raw=true)

---

#### Bin 75 Manual Refinement

![Manual refinement of Bin 75](https://github.com/RobertsLab/sams-notebook/blob/master/images/screencaps/20190619_anvio_refine_bin75-01.png?raw=true)