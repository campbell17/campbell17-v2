---
layout: post
category: writing
title: 'I Was a Dumbass At Least Once This Week'
date: '2020-09-11'
---

Toward the end of the workday yesterday, I began having trouble running our app locally. Like everything in life, the problem wasn't what it seemed at first. I've been working on updating the color palette in the app since some of the theming didn't precisely match some recent marketing changes we made. Dozens and dozens of haml and css files later, my find/replace cleanup was done and my new Sass variables were all nice and shiny. 🧐 Yup, everything still works.

<!--more-->

I wanted to merge in any updates from the main branch so I could make a nice clean pull request and be on my way. Merge done. Cool. Time to restart the app to make sure ev..._it's broken now_. 😑

I poked around, Googling some of the build hieroglyphics in the terminal, but no luck. Breaking my Google-it-again rule as I often do, I got an entire team channel in Slack (and a DM thread) all frothed up about it. It was late. I decided to sleep on it and try again today.

One of the colors we replaced is the reddest red there is: #ff0000. Formerly "Fulcrum Red". I noted to myself at some point yesterday that the shorthand for that hex value is #f00 so I better find/replace that, too. I was so careful during the main color replacement about which files I included and excluded, but for this change, I didn't pay attention as closely. I think we can all see where this is going...

Does anyone want to guess what the new hex value for our red is?

![screenshot of a typo in some code](/assets/img/posts/dumbass.jpg)

There's a moral here somewhere, I know it. Maybe I'll find it tomorrow in another file.