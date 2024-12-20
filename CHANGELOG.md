# CHANGELOG

## v1.5.0 - 2024-11-01

This change adds a main queue alarm that triggers when the main queue has messages older than a certain age. 

This is useful for monitoring the health of the queue and ensuring that messages are being processed in a timely manner.

Adds the variables:

- `dlq_alarm_action_arns` - The ARNs of the resources to send DLQ alarm notifications to
- `main_q_age_alarm_action_arns` - The ARN of the resources to send main queue age alarm notifications to
- `max_age_in_hours` - The maximum age of a message in the main queue before the alarm triggers
- `enable_dlq_not_empty_alarm` - Whether to enable the DLQ not empty alarm (default: `false`), overridden if `dlq_alarm_action_arns` is not empty
- `enable_main_q_age_alarm` - Whether to enable the main queue age alarm (default: `false`), overridden if `main_q_age_alarm_action_arns` is not empty

We deprecate the `alarm_topic_arn` variable in favour of the new `dlq_alarm_action_arns` and `main_q_age_alarm_action_arns` variables.

## v1.4.0 - 2024-09-06

Make the DLQ alarm optional by allowing a `null` value for the `alarm_topic_arn` variable.

## v1.3.0 - 2022-02-16

Allow configuring the "cooldown period" variable in the autoscaling module.
It allows us to trade off two competing concerns:

*   A shorter cooldown period means apps will scale down more quickly when they're not doing any work.
    This reduces wasted compute capacity and saves money.

*   A longer cooldown period means apps are less likely to scale down prematurely when they're in the middle of a task.
    This avoids flapping tasks if SQS queue metrics [are delayed by an inactive queue](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-monitoring-using-cloudwatch.html).

Most applications should continue to use the default behaviour, but the longer cooldown is useful for apps with long-running tasks.

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
