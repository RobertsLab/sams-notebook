---
layout: post
title: Server Maintenance - Fix Server Certificate Authentication Issues
date: '2022-04-02 10:38'
tags: 
  - github
  - InCommon
  - certificate
  - servers
  - gannet
  - owl
  - eagle
categories: 
  - Computer Servicing
---
We had been encounterings issues when linking to images in GitHub (e.g. notebooks, Issues/Discussions) hosted on our servers (primarily Gannet). Images always showed up as broken links and, with some work, we could see an error message related to server authentication. More recently, I also noticed that Jupyter Notebooks hosted on our servers could not be viewed in [NB Viewer](). Attempting to view a Jupyter Notebook hosted on one of our servers results in a 404 error, with a note regarding server certificate problems. Finally, the most annoying issue was encountered when running the shell programs `wget` to retrieve files from our servers. This program always threw an error regarding our server certificates. The only way to run `wget` without this error was to add the option `--no-check-certificate` (which, thankfully, was a suggestion by `wget` error message). 

The perplexing thing is that we have InCommon CA certificates provided by the University of Washington for each of our servers, so it was confusing that we kept encountering these certificate-related errors. I finally got fed up with the problem and decided to do some sleuthing. I had done so in the past, but never came across anything that could point me to what was wrong. Well, today, I stumbled across the problem:

We didn't have an _intermediate_ InCommon certificate!

I wasn't previously aware this was a requirement, as this was not mentioned when I initially requested certificates from our department IT group. But, during my (remarkably) bried searching, I stumbled across [this guide for installing a certificate on a Synology NAS](https://www.ssl.com/how-to/enable-https-generate-csr-install-ssl-tls-certificate-in-synology-nas/) (which is the brand for all three of our servers) and noticed that the process included an intermediate certificate. The phrasing of the instructions also implied that it was necessary, which is what prompted me to explore this further. Of note, not only did the department IT not mention intermediate certificates, but the Synology "wizard" for guiding the user through the certificate generation/upload process doesn't _require_ an intermediate certificate; suggesting it's optional (which, I guess, technically, it is; but it'd be nice if they explained what the impacts might be if one does _not_ procide an intermediate certificate).

Searching for UW intermediate server certificates led me to [this page which _actually provides the InCommon RSA Server intermediate certficates for UW_!](https://wiki.cac.washington.edu/display/infra/InCommon+SSL+Intermediate+Certificates). Doing a bit more research, I found the UW page [describing InCommon CA server certificates](https://wiki.cac.washington.edu/display/infra/UW+Certificate+Services). On that page is this crucial piece of information:

> Server admins must install the InCommon CA intermediate certificate.

Notably, that page _doesn't_ provide a link to find the InCommon CA intermediate certificate...

So, seeing those two pages made me realize that the solution was, indeed, installing the InCommon CA intermediate certificate from that UW page! To do so, I generated a new Certificate Signing Request (CSR) for each server via the Synology interface, sent them off to our department IT group, and then used Synology interface to import the updated server certificate _and_ the intermediate certificate.

And with that, I have managed to resolve all of the issues described in the intial paragraph! It is a great day! Huzzah!
