# CHANGELOG

## v1.2.1 - 2021-07-15

Fix a bug in the v1.2.0 module.

## v1.2.0 - 2021-07-15

This removes the `aws_region` variable from the `queue` module, in favour of getting the region directly from the provider.
This should make it easier to create queues in other regions.

## v1.1.5 - 2020-09-24

Bump for release.

## v1.1.4 - 2020-09-01

This release adds the possibility to create FIFO queues. 

FIFO queues are useful if you want messages to be delivered in order and exactly once.

## v1.1.3 - 2020-04-17

autoscaling module:

*   This release adds NumberOfMessageDeleted to SQS scale down metric.

## v1.1.2 - 2019-11-25

autoscaling module:

*   This release tweaks the type constraints so they don't emit a deprecation
    warning from Terraform.  There should be no user-visible change.

## v1.1.1 - 2019-11-12

If you're using the `read_policy` output from the queue module, you get the `sqs:ChangeMessageVisibility` IAM permission.

This is useful for non-deterministic failures: an app can receive a message, try to process it, fail, then mark it as ready for other workers to try.

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
