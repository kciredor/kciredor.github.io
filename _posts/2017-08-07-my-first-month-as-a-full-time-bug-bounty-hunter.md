---
layout: post
title:  "My first month as a full-time bug bounty hunter"
date:   2017-08-07 15:00:00 +0200
categories: bugbounty infosec security
---
# Introduction #
Thank you for taking the time to read my first blog post. My name is Roderick Schaefer, known as kciredor in the exciting world of security bug bounties. I'm new and working hard to get very much involved. By sharing my journey and considerations so far, I'm hoping for more interested people to give it a shot!

My background lies in software engineering with experience in development (go, python) and operations (linux, puppet/chef, docker/kubernetes). For the past 10+ years I've been living as a freelancer working full-time on customer projects averaging half a year. Always felt the need to look into the security aspects of everything we did as a team.

When I was still in high school my favorite hobby was reverse engineering. Changing program flow, adding new functionality without having the source code.. Found it fascinating and did not see much sun during summer holidays.

# Why #
Traveling in beautiful Asia my mind started to get into a 'flow' state. What do I really want to do on a daily basis? Engineering is a lot of fun, but I could still feel the rush from back in high school when I was able to RE or hack something. Only a few months before the holidays I participated in corelanc0d3r's advanced exploit development class which kept me thinking: could I drop everything and get into security full-time?

There's so many facets to security. Exploit development is awesome, but I felt there's too much risk involved for me switching to this full-time. Payouts are high, but what if someone else gets to a bug or exploit before you, after months and months of work.. So how about bug bounty hunting, with a focus on web applications? Reading many public disclosed reports I figured this could be sustainable and most important: a ton of fun!

And that's when I knew: this is what I have to do. Companies get hacked all the time. They can use much help of the good guys. Let's help by hacking them and working together to prevent the bad guys from doing so. It's such a cool business model. Everyone involved benefits. During the holiday, I kept braindumping into Evernote and felt really happy.

# How #
Some things will not change like the need to pay your rent. So I started with saving enough money so I could dive into bounty hunting for at least half a year, without running into trouble.

First up: my so-called "attack plan". This living document started out as an Evernote, but by now it's a huge thing with each different attack vector (XSS, CSRF, IDOR, etc.) having it's own space. It has guidelines on how to proceed a bug bounty program. Recon, manual attacks, references, reporting, etc.

I have grown this attack plan by taking in as much knowledge as humanly possible, reading books, public disclosed reports, blogs and Bug Bounty Forum AMA's and summarizing everything I learned into the attack plan. Head start for me was the 'Web Hacking 101' book by Peter Yaworski. You can have it for free when applying on HackerOne, but you should probably buy it (let alone it gives you free updates!). Also of much importance was "How to shot Web" by Jason Haddix, it helped me with a layout for recon.

Besides technical knowledge about the hacking of websites and mobile apps, there's also a lot to learn on how to properly report issues and communicate fairly with the companies running the bounty programs. Don't underestimate this. For instance don't end up with 'Not Applicables' hurting your reputation simply because you have not properly verified the impact and reproducibility of what you report.

This is what I have done and will keep on doing: learn and process as much as possible about hacking and bug bounties. There's nothing more fulfilling than learning.

Meanwhile I saw a chance to meet some members of the community by attending an open bar session organized by HackerOne during the HITB conference in NL. Happy to have met great people like Jobert Abma and Edwin van Andel. I remember people's faces telling them I'm switching from software engineering to bounty hunting full-time, without having hacked anything yet! Must be crazy :-)

After the bigger part of a year I wrapped up my last project, had enough savings, learned a lot and was ready to go! Finally!

# So far so good #
It's July 2017: this is the time! What to do? Where to start? I need to organize myself. Quickly ended up with Trello to create a Bounty board with some lists like 'to do', 'interesting bounty programs', 'research', etc.

Being an engineer I figured that I should automate as much as possible so I have my hands free to do actual manual hacking. So I started with creating a recon.sh file scripting away my recon process. Of course recon.sh is never finished, but by now it can process stuff like ip ranges, portscans, subdomains combined through many ways, screenshots, version control, s3 buckets, etc.

There are so many things you can do to get a feeling of being organized and ready. But in the end you have to just.. start.. hacking.

I'm actually quite happy with the first month. Software engineering gives me a good feeling of having an understanding of how an application works below the hood. This allows me to look for security issues that I 'just know' are easy not to think about during implementation of a new feature.

The first program I worked on I was not able to find anything. A week of trying everything I could think of. What to do now? Move on!

The second program involved mobile apps. That's cool, especially considering I joined the excellent BugCrowd LevelUp online conference having watched some nice new mobile reversing tricks. Let's switch context and reverse those apps! After decompiling the android apk I ended up with more than 1500 java classes. Yes I went through them one by one manually, scanning for oddities. And yes of course I found something only at the very end with 30 files to go :-) An OAUTH2 client\_secret. Verifying using a rooted android device with ssl unpinned and proxing traffic through burp, it became more clear: the actual OAUTH2 implementation was very limited, so it was not actually a big security risk.

Moving on. Stay motivated. Working many hours a day, every day, keep seeing other people reporting many issues on many programs: I can do this too. Should I do more active scanning? I like manual testing, but.. should I?

And then I actually found something, sticking with my own way of working and mostly manually testing. Can't get into much details about the program yet as the issue is still being resolved, but I found an IDOR with at the very least a High impact considering the business model of this company. Given a user has certain belongings, it's possible for me to instantly take over those belongings and change them. Also this can trivially be scripted to take over thousands of objects in no time.

Triaged.

The feelz. Went crazy. Is this real? Have to go for drinks now and chill a bit!

# Thanks #
Would like to shout out to the bug bounty community. I love how inclusive and helpful everyone is. Really gives you a feeling of being in it together.

Special thanks to Jobert for having trust in me and helping me out, before I proved anything.

Hopefully the next thing you'll see from me is the IDOR report being publically disclosed!

Let's keep on hacking!

Cheers,
kciredor

{% twitter https://twitter.com/kciredor_/status/894558894235820032 %}
