RELEASE_TYPE: patch

If you're using the `read_policy` output from the queue module, you get the `sqs:ChangeMessageVisibility` IAM permission.

This is useful for non-deterministic failures: an app can receive a message, try to process it, fail, then mark it as ready for other workers to try.