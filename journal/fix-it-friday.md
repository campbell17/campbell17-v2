---
layout: post
category: writing
title: 'Fix-it Friday'
date: '2020-09-25'
---

In a recent [CSS Tricks newsletter](https://css-tricks.com/newsletter/217-small-changes-in-the-right-direction/), [Robin Rendle](https://twitter.com/robinrendle) explains how he practices incremental improvements by scrutinizing Sentry's CSS every Friday afternoon.

> ...after rummaging about looking at a component I realized that there were all sorts of places where our styles were coming from: there was no single source of truth. So! Instead of panicking, the first thing I did was make a list of every problem I could see with our styles. Then, the more spelunking into our codebase that I did, I started to refine that list into tasks.

<!--more-->

I was taken aback at how closely this mirrors what I've been doing on Fulcrum for the past few months in our UI Audits. I did the first one back in March and I've been tending to it weekly ever since. 

![a looping animation of productivity software scrolling down with numerous checked boxes](https://campbell17.s3.amazonaws.com/posts/ui-audits.gif)

I didn't initially set out to make this a regular practice, but that's exactly what it grew into organically. And since these are small changes that usually don't take longer than a few hours per week (if that), the payoff of constant improvement and momentum is well worth the modest cost in time.

Further down in the newsletter, Robin wrote something that made me look over my shoulder to see if he was reading my Slack messages:

> This list of tasks isn’t really meant to be added to a Jira board or anything, it’s really just to inspire me to break up my pull requests into tiny chunks and then ship code every Friday afternoon. Each list item should ideally be one shippable chunk of code.

With a few exceptions (sorry devs 😬), I've been making a habit of creating tiny PR's to make them easier to review and more likely to get deployed as soon as possible. The UI Audits go hand in hand with this, and the consistent routine has made things a lot more manageable that they used to be when I wrote giant spaghetti-monster PR's with dozens of file changes.

I'm claiming "keeping at it" as my personal philosophy until something that produces better results comes along. Good luck to whatever that might be.
