---
layout: log
title: "From Support to Secure Delivery"
date: 2026-02-26
summary: "What changes when you stop seeing infrastructure as ticket work and start treating it as an engineered system."
category: notes
tags: [career, devops, security-engineering, operator]
reading_time: "5 min"
id: log-2026-02-26-support-to-secure-delivery
---

The shift is not about learning more tools.

Support work teaches you what breaks. You develop pattern recognition for failure modes, user behaviour, and the gap between how a system was designed and how it is actually used. That is genuinely valuable knowledge. It does not transfer automatically into engineering work.

What changes is the frame.

## The support frame

In support, the unit of work is the ticket. A problem arrives, you resolve it, it closes. The system's state before and after the ticket is someone else's concern. Your job is containment and restoration.

This is a reasonable frame for reactive work. It is a limiting frame for everything else.

## The engineering frame

Engineering treats recurring problems as signals. When the same failure appears three times, the right response is not a faster resolution path — it is a control that prevents the fourth occurrence.

This means:

- Writing runbooks that outlive the engineer who wrote them
- Treating manual processes as technical debt
- Asking why a system allows a class of failure before asking how to recover from it

## What the transition actually looks like

It is not a credential or a job title change. It is a set of habits that compound over time.

Document the incident, not just close it. Understand the blast radius before touching production. Write the fix in a way that can be reviewed, not just applied. Treat access as a surface to be minimised, not a convenience to be maximised.

The operational background is an asset, not a liability. You already know what failure looks like at the edges. The goal is to bring that knowledge upstream — into design decisions, delivery patterns, and security controls — before the ticket is raised.

This site is part of that work.
