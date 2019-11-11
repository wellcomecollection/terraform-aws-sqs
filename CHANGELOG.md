# CHANGELOG

## v1.1.0 - 2019-11-11

This release adds an `autoscaling` module, which allows you to trigger actions based on the size of a queue.  This is available as

    git::github.com/wellcomecollection/terraform-aws-sqs//autoscaling?ref=v1.1.0

For namespacing, the original top-level module has been moved into `queue`, but otherwise has the same inputs/outputs.  You can access it as follows:

    git::github.com/wellcomecollection/terraform-aws-sqs//queue?ref=v1.1.0

## v1.0.0 - 2019-11-07

Tidy up the README and add an example for 1.0.

## v0.1.1 - 2019-11-07

Auto-formatting changes; no interface changes.

## v0.1.0 - 2019-11-07

Initial release.
