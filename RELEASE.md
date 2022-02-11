RELEASE_TYPE: minor

Allow configuring the "cooldown period" variable in the autoscaling module.
It allows us to trade off two competing concerns:

*   A shorter cooldown period means apps will scale down more quickly when they're not doing any work.
    This reduces wasted compute capacity and saves money.

*   A longer cooldown period means apps are less likely to scale down prematurely when they're in the middle of a task.
    This avoids flapping tasks if SQS queue metrics [are delayed by an inactive queue](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-monitoring-using-cloudwatch.html).

Most applications should continue to use the default behaviour, but the longer cooldown is useful for apps with long-running tasks.
