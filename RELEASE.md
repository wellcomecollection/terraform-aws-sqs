RELEASE_TYPE: minor

Alarms can be tied to a Backplane Component and given a severity, as the alert routing ADR describes (wellcomecollection/docs#185, part of wellcomecollection/platform#6876).

Adds to `queue`:

- `alarm_component`, `alarm_repository`: set the `backplane:component` and `github.com/project-slug` tags and a `[component=NAME severity=LEVEL]` description prefix
- `dlq_alarm_severity` (default medium) and `age_alarm_severity` (default low): set the `severity` tag
- `alarm_tags`: extra tags

Adds `alarm_tags` to `autoscaling`, and tags its alarms `purpose = autoscaling`.

Behaviour changes:

- The queue age alarm is only created when `main_q_age_alarm_action_arns` is not empty. `enable_queue_age_alarm` no longer has an effect.
- `alarm_topic_arn = ""` is treated like null.
- `autoscaling` skips both alarms when it has no scaling actions, and needs Terraform 1.1 or later for its `moved` blocks.
