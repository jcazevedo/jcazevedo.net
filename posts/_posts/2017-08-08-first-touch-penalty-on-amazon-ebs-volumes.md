---
layout: post
date: "Tue Aug  8 00:42:15 WEST 2017"
---

# First Touch Penalty on Amazon EBS Volumes

Apparently, storage blocks on Amazon EBS volumes that were restored from
snapshots incur in significant latency penalties on I/O operations the first
time they're accessed.

> New EBS volumes receive their maximum performance the moment that they are
> available and do not require initialization (formerly known as pre-warming).
> However, storage blocks on volumes that were restored from snapshots must be
> initialized (pulled down from Amazon S3 and written to the volume) before you
> can access the block. This preliminary action takes time and can cause a
> significant increase in the latency of an I/O operation the first time each
> block is accessed. For most applications, amortizing this cost over the
> lifetime of the volume is acceptable. Performance is restored after the data
> is accessed once.
> 
> &mdash; <cite>[Initializing Amazon EBS Volumes](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-initialize.html)</cite>

This can be particularly painful when restoring Amazon RDS DB snapshots, as the
performance can be severely impacted. In order to overcome the first touch
penalty, it is advisable to warm up the disk by performing a full table scan or
a vacuum on all tables in the database.
