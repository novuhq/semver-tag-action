# Semver Tag Action
___

The action determines the appropriate version bump (major, minor, or patch) based on the labels assigned to a pull request and updates the version accordingly.

## Parameters
___

### Outputs
| Output            | Description                                                | Examples   |
| ----------------- | ---------------------------------------------------------- | -----------|
| `sha`             | The current SHA of the code.                                | 3b361f13d119d34b2247ac25993f5e99fb424352 |
| `sha_short`       | The short version of the current SHA of the code.           | 3b361f13d  |
| `new_version`     | The new version of the application after the bump.          | v2.5.3     |
| `previous_version`| The previous version of the application before the bump.    | v2.5.2     |



### Inputs

| Input                   | Description                                                                                 | Examples                 |
| ------------------------|---------------------------------------------------------------------------------------------|--------------------------|
| `current_version`       | The version that we'd like to bump.                                                         | v2.5.2                   |
| `list_labels_file_patch`| File path to the file with a list of labels from the PR to define the version bump action. | bump:release, bump:patch |


## Usage
___

In our case we had to the version bump on `PUSH` action via a call, when the PR is already merged. Then a workflow will be looking like:

```yaml
name: Get version for applications

# Controls when the action will run. Triggers the workflow on push or pull request
on:
  workflow_call:
    outputs:
      env_tag:
        description: 'The new version of the application'
        value: ${{ jobs.get_version.outputs.new_version }}
      current_tag:
        description: 'The current version of the application'
        value: ${{ jobs.get_version.outputs.current_version }}
      sha:
        description: 'The current sha of the code'
        value: ${{ jobs.get_version.outputs.sha }}
      sha_short:
        description: 'The current sha short of the code'
        value: ${{ jobs.get_version.outputs.sha_short }}


# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  get_version:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Semantic Custom Version Bumping
        uses: novuhq/semver-tag-action@latest
        id: determine_bump
        with:
          current_version: v1.0.0
          list_labels_file_patch: /tmp/label_list

```
## Behavior of Tagging Process

We have to discuss this point but at the moment it works as follows:

The versioning process usually tries to pick up and to bump the latest git tag. It means if we have no attached labels to the Pull Request then a workflow process will get the latest git tag and will increase a build number.

```bash
when no attached labels:
v1.0.0-alpha0 --> v1.0.0-alpha1
v1.0.0-beta12 --> v1.0.0-beta13
v1.0.0-demo4 --> v1.0.0-demo5
```

If the latest tag doesn't have any build numbers then a workflow process will get the latest git tag and will create pre-release type alpha with build number 0.

```bash
when no attached labels:
v1.0.0 --> v1.0.1-alpha
v1.0.1-alpha --> v1.0.1-alpha1
v1.2.3 --> v1.2.4-alpha
```

If we want to start a new version with another prerelease type we will have to use labels attached to the PR. For example, the different labels will call the following changes:

```bash
label pre:beta
v0.22.1 --> v0.22.2-beta
v0.22.1-beta0 --> v0.22.1-beta1 (the same behavior when no labels)

label pre:demo
v0.22.1 --> v0.22.2-demo
v0.22.1-demo --> v0.22.1-demo1 (the same behavior when no labels)
```

If we want to move from some pre-release version to the version without pre-release suffix we have to use label `bump:release`

```bash
label bump:release
v0.22.1-beta0 --> v0.22.1
v0.22.1-demo2 --> v0.22.1
v0.22.1-demo --> v0.22.1-demo1 (the same behavior when no labels)

label [bump:release, bump:patch]
v0.22.1-demo2 --> v0.22.2 (because bump:patch|minor|major tags have higher priority)
```

To avoid future problems if someone adds a few labels to the PR the following priority has been implemented:

```bash
**pre:alpha < pre:beta < pre:demo < bump:release < bump:patch < bump:minor < bump:major**
```

More examples you can generate if you run ```./determine_bump.sh v.1.1.0 path_to_file_with_labels```
