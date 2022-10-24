---
layout: post
title: "Throwing 500 vm's at your fuzzing target being an individual security researcher"
date:   2019-05-03 10:00:00 +0200
categories: devops fuzzing pdf
---
# Adobe Reader progress #
One year ago I blogged about my many attempts and failures at [fuzzing Adobe Reader]({{ site.baseurl }}{% post_url 2018-04-24-fuzzing-adobe-reader-for-exploitable-vulns-fun-not-profit %}) and finding exploitable security issues.

Meanwhile, I realized that writing your own fuzzers is the way to go as confirmed by my first [CVE-2018-19713](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-19713) for Adobe Reader. Found the bug using 'What The Fuzz' targeting a custom plugin I coded which integrates with Adobe Reader.

So what's the next step?

# Fuzzing FoxitReader #
Excellent research has been shared on exploiting FoxitReader by @steventseeley, which inspired me to switch from Adobe to Foxit as a target.

Having learned from Adobe Reader I immediately tried to find a way to fuzz FoxitReader using What The Fuzz. There are many routes to fuzzing FoxitReader and it's out of the scope of this blog post to go in depth.

To summarize: my fuzzer generates inputs and replaces them in target process memory, resetting FoxitReader's instruction pointer to evaluate new inputs over and over. No inputs ever touch the harddisk, meaning it's pretty fast!

# The importance of scaling up #
So far so good, now let's do some calculations to get an understanding of the importance of scaling up your fuzzing efforts.

According to a presentation given by @ifsecure, testing browsers you should try about 100.000.000 different inputs. Let's make this our target number. Given my ability to fuzz at about 1.5 inputs per second per vm this would take about 771 days running 1 vm. This makes no sense: within that long period of time, FoxitReader has been updated multiple times and bugs have been fixed. Even worse: it will take way too long to find out if your fuzzing strategy actually works or needs improvement. Even with 10 vm's, which is still manually manageable, it will take months.

Sure, fuzzing 1.5 inputs per second is generally considered to be slow. Let's take into account that my input files are quite large on purpose, so parsing takes time. Furthermore, I'm targeting FoxitReader as a whole, not a small dll or harness, which is also the reason I can only run 1 fuzzer per vm instead of simply using multiple cores. FoxitReader can't run multiple instances in parallel.

What if we could use 500 vm's instead of 1 or 10? We'll end up needing only 2 days!

This makes for a solid case of scaling up. But where to find enough power without spending too much money? How to orchestrate a massive amount of vm's?

# How to scale up #
Keep in mind some of the bigger tech companies may have in house fuzzing at scale 'as a service', but what if you are on your own?

Here's a list of things we need to accomplish:
- Fuzzing your target (e.g. FoxitReader)
- Running on Windows 8
- At scale
- Keeping costs low
- Collecting crashes

Quickly you'll realize you need a cloud provider with enough power. Yet running 500 instances with Google, Amazon or Azure will certainly become an expensive experience. Let alone not all of them will allow you to bring your own Windows version/license. It's advisable not to settle for a ready-made Windows Server image: FoxitReader is the target, not the exploit mitigations Windows may have added. Currently, I'd stick to Windows 8.

## Keeping costs low ##
Let's look at the problem of the costs. Think in terms of spare capacity. Most cloud providers will not be selling 100% of their capacity to their customers all the time. Many cloud providers offer their spare capacity at reduced costs, but of course, there's always a catch. For instance: you may buy a spare vm at 20% of the normal costs, but within 24 hours maximum, it will be removed from your account because it was sold for the regular price to another customer.

## Collecting crashes ##
Now you might be thinking 'what happens to my crashes when I suddenly lose my running vm's and fuzzers?'. Good question ;-) How about creating some external storage like an S3 bucket and having your fuzzer push every crash it finds to the bucket? While you're at it, using something like pushbullet you can make your fuzzer send you a push notification to your phone every time you find a crash!

## At scale ##
But you keep on losing vm's during fuzzing because of the usage of spare capacity, right? In comes the autoscaling feature of your cloud provider! Autoscaling groups allow you to define a minimum/maximum set of instances running a certain image and instance type. Setting the minimum and maximum amount to the same number and ensuring we use spare capacity and our own image, it doesn't matter if the cloud provider decides to remove one or multiple vm's all the time: new ones will automatically be launched to stay in shape with the min/max we defined. This process may take some time (vm's need to be allocated and booted), so we just add this overhead to our calculations targeting the number of inputs we want to fuzz.

## Running on Windows 8 ##
Time to think about running your own Windows version next. You may not be able to create an image to launch new vm's with Windows 8, but we sure are able to create images from a Linux vm offered by the cloud provider. What if you could split a multi-core Linux vm into multiple nested single core Windows 8 vm's? In comes Proxmox! Proxmox allows you to manage resource allocation using a web interface and installing vm's using any .iso you prefer, including Windows. As long as your cloud provider offers instances that allow for nested VT-X, the performance penalty of nesting will be minimal.

## Step by step ##
If you do not fully understand the pieces of the puzzle, please award yourself some time to learn more about engineering and then try this again. Start by getting yourself a cloud account and playing with things, building things, breaking things and fixing them.

So let's put two and two together:
- Find yourself a cloud provider offering the usage of nested vm's (VT-X) and spare capacity usage
- Calculate the sweet spot of instances x cores in terms of costs, for me 50 vm's with 10 cores each was the cheapest. This works out to 24gb ram (10 \* 2 + slack) and 50gb SSD each.
- Install Proxmox on a Linux instance and install Windows in a nested vm on a single core.
- Code the pushing of crashing inputs to external storage like S3 into your fuzzer of choice.
- Install both your fuzzer and target application.
- Set your fuzzer to run automatically at Windows startup.
- Convert the Windows vm into a 'template'. Now create linked clones until you have as many Windows vm's as you have cores available on this instance. Linked clones save space and the performance penalty is minimal.
- Toggle all of the vm's to run automatically at Proxmox boot.
- Create an image of your fully ready Proxmox instance.
- Create an autoscaling group using your image and instance type of choice, using spare capacity, setting the minimum and maximum number of instances to 2. Always ensure everything works exactly as expected before scaling up.
- Everything good? Then let's go and up the min/max to 50, effectively resulting in 500 Windows vm's fuzzing FoxitReader in parallel!
- You may hit limits set by your cloud provider, like the maximum number of cores you may use at once. Respectfully requesting a limit increase truthfully explaining your intentions worked out for me.

<p><img src="/assets/post_500-scaling.png" alt="Fuzzing with 500 vm's" title="" /></p>

Ending up with 48 hours of fuzzing hitting the 100.000.000 inputs mark, I was charged about $250,-.

# Room for improvement #
It would be nice if the fuzzer could update itself upon vm launch by downloading and extracting 'latest.zip'. This way you can update your fuzzer, settings, grammar, etc. without having to create a new vm image saving you time between iterations.

# Last words #
On a day to day basis, I experience the advantage of knowing how to code and automate things, supporting my security research. It works out both ways: security awareness actively improves your quality of work as a developer / engineer. Having experience with all of dev/sec/ops gives you many new opportunities to step up your game.

Don't forget to document and git version your work. After a couple of months you need to be able to pick up where you left, certain things will not make sense anymore by that time.

Thanks @rnotcln for inspiring me to think about properly scaling fuzzing jobs. Thanks @steventseeley for sharing high-quality posts on FoxitReader and proofreading this blog post. Thanks @ifsecure for the magic inputs number and open sourced tooling.

Let's keep on hacking!

Cheers,
kciredor

{% twitter https://twitter.com/kciredor_/status/1124327843352252417 %}
