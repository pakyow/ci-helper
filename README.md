# Pakyow CI Helpers

Helpers for creating and interacting with a Pakyow CI environment.

We run CI in containers from ephemeral DigitalOcean droplets, created on demand from a base image. This gives us predictable performance since we can create droplets of any size for a given workload. It also gives us complete ownership of CI, helps make everything more portable, and keeps costs down.

# Commands

* `commands/build-image`: Builds a base CI image.
* `commands/runner`: Runs a command on an ephemeral CI instance.

# Improvements

- [ ] Use Ansible instead of hard-coded commands for building images.
  * This is a pattern we already use elsewhere at Metabahn.
- [ ] Assign resources to a specific project.
  * More useful once DigitalOcean supports billing statements by project.
