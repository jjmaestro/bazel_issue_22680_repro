# Test repo to repro a (potential?) Bazel bug

See [Bazel issue #22680](https://github.com/bazelbuild/bazel/issues/22680)

## Repro

To repro the bug:

* clone the repo:
```
git clone https://github.com/jjmaestro/bazel_issue_22680_repro
```

* run `make`
```
cd bazel_issue_22680_repro
make
```

The `make` command will run `repro.sh` inside a Docker image with Bazel v7.2.1 (see `.bazelversion`) and will test:
* running `bazel build` without any options (i.e. cache in the default `$HOME/.cache/bazel` which is *inside* the Docker image)
```sh
bazel build //testimage:tarball
```
* running `bazel build` with `output_base` pointing to a directory in a mounted Docker volume (`/tmp/out`) which always fails
```sh
bazel --output_base /tmp/out/bazel build //testimage:tarball
```
* running the same `bazel build` that fails but with `--experimental_worker_for_repo_fetching=off` which was reported to mitigate / avoid the issue, but it still always fails in this repro.
```sh
bazel --output_base /tmp/out/bazel build --experimental_worker_for_repo_fetching=off //testimage:tarball
```

The error I always get is:
```sh
Extracting Bazel installation...
INFO: Repository rules_python~~python~python_3_11_aarch64-unknown-linux-gnu instantiated at:
  <builtin>: in <toplevel>
Repository rule python_repository defined at:
  /tmp/out/bazel/external/rules_python~/python/repositories.bzl:443:36: in <toplevel>
ERROR: An error occurred during the fetch of repository 'rules_python~~python~python_3_11_aarch64-unknown-linux-gnu':
   Traceback (most recent call last):
        File "/tmp/out/bazel/external/rules_python~/python/repositories.bzl", line 255, column 28, in _python_repository_impl
                rctx.delete("share/terminfo")
Error in delete: java.io.IOException: unlinkat (/tmp/out/bazel/external/rules_python~~python~python_3_11_aarch64-unknown-linux-gnu/share/terminfo/X) (Directory not empty)
ERROR: no such package '@@rules_python~~python~python_3_11_aarch64-unknown-linux-gnu//': java.io.IOException: unlinkat (/tmp/out/bazel/external/rules_python~~python~python_3_11_aarch64-unknown-linux-gnu/share/terminfo/X) (Directory not empty)
ERROR: /tmp/out/bazel/external/rules_foreign_cc~/toolchains/private/BUILD.bazel:112:11: @@rules_foreign_cc~//toolchains/private:meson_tool depends on @@rules_python~~python~python_3_11_aarch64-unknown-linux-gnu//:python_runtimes in repository @@rules_python~~python~python_3_11_aarch64-unknown-linux-gnu which failed to fetch. no such package '@@rules_python~~python~python_3_11_aarch64-unknown-linux-gnu//': java.io.IOException: unlinkat (/tmp/out/bazel/external/rules_python~~python~python_3_11_aarch64-unknown-linux-gnu/share/terminfo/X) (Directory not empty)
ERROR: Analysis of target '//testimage:tarball' failed; build aborted: Analysis failed
INFO: Elapsed time: 51.117s, Critical Path: 0.02s
INFO: 1 process: 1 internal.
ERROR: Build did NOT complete successfully
FAILED: 
    Fetching repository @@rules_foreign_cc~~tools~cmake-3.23.2-linux-aarch64; starting 41s
    Fetching /tmp/out/bazel/external/rules_foreign_cc~~tools~cmake-3.23.2-linux-aarch64; Extracting cmake-3.23.2-linux-aarch64.tar.gz
```
