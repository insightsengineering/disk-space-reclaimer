# Disk Space Reclaimer

💡 This is a fork of <https://github.com/jlumbroso/free-disk-space>, only difference is that it's maintained actively.

A customizable GitHub Action to free disk space on Ubuntu GitHub Action runners.

On a typical Ubuntu runner, with all options turned on (or not turned off rather), this can clear up to 34 GB of disk space in 4-5 minutes (the longest period is calling `apt` to uninstall packages). This is useful when you need a lot of disk space to run computations.

## Example

```yaml
name: Free Disk Space (Ubuntu)
on: push

jobs:
  free-disk-space:
    runs-on: ubuntu-latest
    steps:

    - name: Free Disk Space (Ubuntu)
      uses: insightsengineering/free-disk-space@v1
      with:
        # this might remove tools that are actually needed,
        # if set to "true" but frees about 6 GB
        tools-cache: false

        # all of these default to true, but feel free to set to
        # "false" if necessary for your workflow
        android: true
        dotnet: true
        haskell: true
        large-packages: true
        swap-storage: true
        docker-images: true
        tools-cache: true
```

## Options

Most of the options are self-explanatory.

The option `tools-cache` removes all the pre-cached tools (Node, Go, Python, Ruby, ...) that are loaded in a runner's environment, [installed in the path specified by the `AGENT_TOOLSDIRECTORY` environment variable](https://github.com/actions/virtual-environments/blob/5a2cb18a48bce5da183486b95f5494e4fd0c0640/images/linux/scripts/installers/configure-environment.sh#L25-L29) (the same environment variable is used across Windows/macOS/Linux runners, see an example of its use on [the `setup-python` GitHub Action](https://github.com/actions/setup-python)). This option was [suggested](https://github.com/actions/virtual-environments/issues/2875#issuecomment-1163392159) by [@miketimofeev](https://github.com/miketimofeev).

## Acknowledgement

This GitHub Actions came around because I kept rewriting the same few lines of `rm -rf` code.

Here are a few sources of inspiration:
- <https://github.community/t/bigger-github-hosted-runners-disk-space/17267/11>
- <https://github.com/apache/flink/blob/master/tools/azure-pipelines/free_disk_space.sh>
- <https://github.com/ShubhamTatvamasi/free-disk-space-action>
- <https://github.com/actions/virtual-environments/issues/2875#issuecomment-1163392159>
- <https://github.com/easimon/maximize-build-space/>

## Typical Output

The amount of space storage saved by each option on an `ubuntu-22.04` runner is summarized here:

```bash
=> Android library: Saved 12GiB
=> .NET runtime: Saved 1.7GiB
=> Haskell runtime: Saved 0B
=> Large misc. packages: Saved 4.6GiB
=> Docker images: Saved 3.6GiB
=> Tool cache: Saved 8.4GiB
=> Swap storage: Saved 4.0GiB
=> Saved 30GiB

=> Total 34GiB
```
