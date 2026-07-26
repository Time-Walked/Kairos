# Reticulum at it's core:

If someone's tried to explain Reticulum to you using words like "mesh," "nodes," and "interfaces," and your eyes glazed over, that's not on you. The problem is that Reticulum asks you to throw out an assumption you've been making your whole life and didn't even know you were making.
## The assumption you don't know you're making

Every app you've ever used works like this: your phone talks to a server somewhere, and the server is the middleman. You send a text, it goes to a company's server, which finds your friend and delivers it. You load a webpage, your browser asks a server, "give me this page," and then proceeds to reach out across multiple network hops across the world for the search. 
There's always a _someone in charge_. A company that owns the server. A company that can go down, get bought, get hacked, get pressured by a government, etc. 

Reticulum starts from a completely different place: **what if there's no middleman at all?**
Not "a smaller, cheaper middleman." None. Your device can talk directly to another device, and that device can pass the message along to the next one, until it reaches whoever it's meant for, even if you and that person never touch the same wire, the same WiFi, or the same servers.
## Your "address" is you, not a location

On the normal internet, your address is like a street address. It's tied to _where_ you are plugged in. Unplug your router, and that address is gone. Someone else might get assigned it tomorrow.

In Reticulum, there's no such thing as that "street address." Instead, every device (or every person, or every app) has an identity. Think of it less like an address and more like a **name that can never be faked**. It's created using cryptography, so no one else can pretend to be you, and no company hands it out or can take it away from you. 

Wherever you physically are, on your home WiFi, on a LoRa radio in the woods, plugged into a different network in a different country, that name stays exactly the same. The network doesn't ask "where does this message need to go on a map?" It asks "who is this message for?" and figures out the path itself, hop by hop, without ever needing a central lookup table.
## Nobody's listening in by default, not by choice

Normally, encryption is something you have to remember to turn on, like the little padlock icon, enabling your VPN, the "https" in the address bar. It's a patch bolted onto a system that was never private to begin with.

In Reticulum, every single thing sent between two points is encrypted automatically. There's no "insecure mode." You can't accidentally send something in the open, because the protocol simply doesn't work that way. Encryption isn't a setting, it's baked into how messages get routed altogether. You don't have to trust that the coffee shop WiFi is safe, or that whoever owns the radio tower in between isn't peeking, because it genuinely doesn't matter. Even the person relaying your message for you can't read it.
## It doesn't care what it's traveling over

This is the part that makes Reticulum possible at all: it doesn't care _how_ your message physically moves. A wire, WiFi, the actual internet, a $30 LoRa radio, an old packet radio setup a ham operator already owns, Reticulum treats all of it the same way. You can mix and match all of these at once in a single network, and messages will automatically flow across whichever path actually works, and reroute themselves the moment something changes. For example a radio goes out of range, a WiFi drops, etc. then your messages will be routed through other paths or reach a propagation node to "store and forward" it for when you're back online. 

This is also why it works when the internet doesn't. There's no dependency on any of it being present. If every server on Earth vanished tomorrow, two Reticulum radios within range of each other would still talk just fine.
## It's okay with waiting

Most apps panic if a response doesn't come back in a second or two. Spinning wheel, error message, "check your connection." Reticulum was built assuming links might be painfully slow, or might disappear for hours and come back later (a radio out of range, a device that's asleep). So messages aren't lost when that happens, they just wait, and get delivered whenever a path opens up, sort of like a letter instead of a phone call. You don't need a live connection to have a real conversation.
## Why this actually matters, not just as a feature list

Put it together and you get a network that:

- No single company or government can turn off, because there's no "off switch." There's no central thing to shut down
- Nobody can spy on communications by just tapping a cable, because everything's encrypted by default, all the time
- Keeps working when the internet, the power grid, or cell towers don't
- Can be built by regular people with regular hardware, not telecom companies with billions of dollars
- Lets you be reached by the same "name" no matter what device or medium you're actually using right now
## TLDR: 

**Normal networks connect you to a server that someone else controls. Reticulum connects you directly to the person you're trying to reach, encrypts everything automatically, and doesn't care what medium it has to travel over to get there.**

---

_This explaination leans on two real sources if you want to go deeper: the [Reticulum Manual](https://reticulum.network/manual/index.html) for the technicals, and the [Zen of Reticulum](https://reticulum.network/manual/zen.html) for the philosophy behind why it's built this way. I highly encourage you read these to fully understand Reticulum. 
