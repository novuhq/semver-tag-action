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