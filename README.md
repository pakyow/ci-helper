# Pakyow CI Helpers

Helpers for creating and interacting with a Pakyow CI environment.

We run CI in containers from ephemeral, preemptible Google Compute Engine instances, created on demand from a base image. This gives us predictable performance since we can create instances of any size for a given workload. It also gives us complete ownership of CI, helps make everything more portable, and keeps costs down.

As of 2019-10-25, the Pakyow tests take about 5.57 hours of compute time, costing ~$0.0557 per run.

# Commands

* `commands/build-image`: Builds a base CI image.
* `commands/runner`: Runs a command on an ephemeral CI instance.

# Improvements

- [ ] Use Ansible instead of hard-coded commands for building images.
  * This is a pattern we already use elsewhere at Metabahn.
- [ ] Add provider-specific server classes to correctly map attributes.
