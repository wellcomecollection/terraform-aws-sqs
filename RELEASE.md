RELEASE_TYPE: minor

This removes the `aws_region` variable from the `queue` module, in favour of getting the region directly from the provider.
This should make it easier to create queues in other regions.