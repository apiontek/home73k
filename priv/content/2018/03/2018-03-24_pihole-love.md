---
%{
  title: "Pi-Hole Love",
  id: "pihole-love",
  date: ~N[2018-03-24 15:00:00],
  author: "Adam Piontek",
  tags: ~w(tech privacy raspberrypi deprecated home)
}
---

***April 2021 update:*** while the pi-hole is a very cool project, I eventually grew tired of maintaining a separate DNS service. I still use unbound on my edgerouter but now my raspberry pi just runs some local web services.

Original post below:

<!--more-->

---

I'm really liking my [Pi-Hole](https://pi-hole.net/)

Katie gave me a Raspberry Pi Zero W for Christmas, and while it's also inspired other projects to come down the line, I finally settled on using it for Pi-hole.


It's better than an ad-blocker in your browser because it means the ads — and a lot of malware! — never get loaded in the first place. Nothing on your network can even *find* the stuff you don't want, so you save some meagre bandwidth, and computing power that would be spent scanning stuff as it comes in.

It's really easy to set up and use — as long as you can change the DNS setting for your router — and has a helpful browser interface.

The default block lists are plenty good, but since it's so easy to use it's well worth adding some more block lists.

I'm using every "ticked" list from "[The Big Blocklist Collection](https://firebog.net/)," and it's working well so far.

I also whitelisted several relevant domains from both the bottom of the Big Blocklist page, and Pi-hole's own "[Commonly Whitelisted Domains](https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212)" page.

### What happens if something I need is blocked?

We found my partner couldn't use a website related to her profession. It would just get stuck loading and it wasn't clear why. With Chrome (can do this in Firefox, too) I was able to use F12 to open the DevTools, click Network, reload the page, and see in red what was failing to load.

In this case, the Pi-hole was blocking "cdns.gigya.com," a content delivery service hosting a javascript the page wanted to use. Off to the Pi-hole web interface (or cli with ``pihole -w``{:.lang-shell}) to quickly whitelist, and the site worked again.

The same for "prod.imgur.map.fastlylb.net," apparently needed for imgur to work.

And the best part is you don't really need anything other than a Raspberry Pi Zero W, an SD card, and a micro USB power connection to make it work -- though I added in a USB OTG cable and a USB ethernet adapter I had laying around to avoid any issues with wifi.
