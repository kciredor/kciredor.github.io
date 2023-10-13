---
title: "First bounty, time to step up my game"
date: 2017-09-19 15:20:00 +0200
Categories: ["Security"]
Tags: ["BugBounty", "XSS"]
---
# What happened #
Hello again and thanks for reading my second blog post! After publishing my [first blog]({{< ref "my-first-month-as-a-full-time-bug-bounty-hunter" >}}) I kept on trying to hack different companies and websites. Not as easy as I had hoped for! It took me quite some time to find another security issue after the IDOR in my first month. This SOME issue I found is not to be made public, so I won't be able to mention company details and will have to mask url's etc.

# SOME attack #
Extensive recon of different websites owned by my target company learned that they were using an old version of an upload plugin. This plugin attempts to allow user uploads for as many different browsers and versions as possible and includes a flash component. Funny thing is this flash component was vulnerable to XSS:
{% highlight url %}https://company.com/lib/upload.swf/?target%g=alert&uid%g=kciredor{% endhighlight %}
This wil pop an alert box containing kciredor. How did I know? While browsing the website and proxying everything through Burp to create a sitemap, the Retire.js chrome extension pointed out that this specific library was out of date. So I started looking into it and searched for published issues.

So far so good but it does not end with an alert of my nickname. Can I also alert document.cookie for instance? The anwser is: no. Simply reporting this XSS right now would end up getting myself in trouble, because I cannot prove exploitability. Cloning the library from github including submodules and browsing through the code I found out the target parameter has a regex filter like this: a-zA-Z0-9.\_ and the uid parameter has a regex filter like this: a-zA-Z0-9\_ which does not leave us a lot of room to get things done.

This is where I want to thank smiegles for giving me a heads up on SOME attacks: Same Origin Method Execution. There's even a PoC to get inspired! The impact of SOME attacks is roughly the same as XSS. Using only alphanumeric input and a dot is enough to make a SOME attack work, meaning this could do the trick! Ben Hayak wrote an excellent [whitepaper](http://files.benhayak.com/Same_Origin_Method_Execution__paper.pdf) on these kind of attacks.

In the context of the website I was attacking I tried to build a DOM path to the user profile delete button, but to no avail: yes it calls the delete profile function but there's a confirm box asking if you really want to delete your profile. This kind of user interaction is not what we're looking for. Trying to manually submit the form by calling the form submit function I found out the submit name was DOM clobbered by a form input. Come on, lol! But finally a call to the delete profile picture worked out just fine. This function was well hidden but I found it by downloading all the obfuscated/concatenated javascript the site had to offer and analyzing it after deobfuscation.

Now there's only one more thing: how do I make sure someone actually clicks on the link containing my attack? That depends given the context of the website. If it's something like eBay you could add a link claiming there's more info and pictures behind it. Given the context of the company I was attacking it was pretty easy to find a good reason.

The end result looked something like this (poc.html):
{{< highlight html >}}
<!-- Profile picture deletion 'SOME attack' PoC -->

<button onclick="fire()">Click</button>
<script>
function fire() {
  open('javascript:setTimeout("location=\'https://company.com/lib/upload.swf?target=opener.document.body.firstElementChild.nextElementSibling.nextElementSibling.nextElementSibling.nextElementSibling.nextElementSibling.firstElementChild.nextElementSibling...etc...firstElementChild.click&uid=poc_kciredor&\'", 2000)');
  setTimeout('location="https://company.com/profile/"')
}
</script>
{{< /highlight >}}
What happens is this: A user is given the link to this poc.html and clicks the button. A new browser tab will be opened with our target location and after timeout the javascript will 'click' a DOM element that does the actual profile picture deletion. Done. My suggestion on how to fix this issue was simply to upgrade the library because the issue has been fixed in more recent versions.


# Meanwhile #
The 'first month IDOR issue' has been resolved by the company, but it's still not published. As soon as it's publically disclosed I'll write a detailed blog post about it, without having to mask anything! During my second month I invested a lot of time, perhaps most of my time, into coding a successor of recon.sh. I kept on having to fix and customize recon.sh to work with each and every target I tried and it kept on crashing, etc. The new setup is what I call recon-docker. It's a python/django dockerized set of scanners with a web frontend, leveraging the usual tools like masscan and recon-ng. For now I'm able to define targets with exact scope and let it run from one or more vm's. If a tool crashes then recon-docker will recover and continue. Next up would be continues scanning and change detection: send me a push notification as soon as company X has new sub domain Y! Hoping this investment will help me in the long run.

# ~~Wrapping~~ Stepping up #
So far I've found an IDOR in the first month, a SOME attack in the second month and an open S3 bucket (yet to be triaged) in the third month. Mixed feelings: out of nowhere I stepped into the world of bug bounties, having a professional background in software engineering, but not in information security let alone web hacking. So finding one bug each month so far as a beginner should be a good start... but it does not feel like it's enough. Far from it! Bills will have to be paid for. I'm eager to pursue my dreams. So it's time to step up my game. When I was young I fell in love with reverse engineering: disassemblers, debuggers, hex editors, you name it. Let's find out what the possibilities are in that specific area of expertise: a healthy (?) mix between *binary exploitation/reverse engineering/vm escapes* and *web application hacking*.

Let's keep on hacking!

Cheers,
kciredor

{{< tweet user="kciredor_" id="910148254695854083" >}}
