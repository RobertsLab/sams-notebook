---
layout: post
title: Computer Management - Disable Sleep and Hibernation on Raven
date: '2021-08-24 07:15'
tags: 
  - raven
  - ubuntu
  - sleep
categories: 
  - Computer Servicing
---
We've been having an issue with our computer Raven where it would become inaccessible after some time after a reboot. Attempts to remote in would just indicate no route to host or something like that. We realized it seemed like this was caused by a power saving setting, but changing the sleep setting in the Ubuntu GUI menu didn't fix the issue. It also seemd like the sleep/hibernate issue was only a problem after the computer had been rebooted _and_ no one had logged in yet...

After some internet sleuthing, [I came across the following command which prevents sleep/hibernate](https://ahoi7.com/disable-hibernate-suspend/), even when no one is logged in:

`sudo systemctl mask sleep.target suspend.target hibernate.target`

Voila! No more sleep/hibernate issues preventing remote logins!


