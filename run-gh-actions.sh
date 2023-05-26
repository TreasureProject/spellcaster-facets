if command -v docker &> /dev/null && command -v act &> /dev/null
then true
elif ! command -v docker &> /dev/null && ! command -v act &> /dev/null
then
    echo "The programs 'docker' and 'act' could not be found.\nInstall docker here: https://docs.docker.com/engine/install/\nInstall act here: https://github.com/nektos/act#installation"
    exit
elif ! command -v docker &> /dev/null
then
    echo "The program 'docker' could not be found. Install it here: https://docs.docker.com/engine/install/"
    exit
elif ! command -v act &> /dev/null
then
    echo "The program 'act' could not be found. Install it here:https://github.com/nektos/act#installation "
    exit
fi
ARCH=$(uname -m)
if [ "$ARCH" = x86_64 ]; then ARCH=x64; fi
if [ "$ARCH" = aarch64 ]; then ARCH=arm64; fi
# Build our local image to use as a runner. This is necessary because there are no hub images anywhere that use Node+Rust+Yarn like the GitHub Actions runner does.
if ! docker build --build-arg ARCH=$ARCH . -t local/runner:latest
then exit
fi

params=''
if [[ $(uname -m) == 'arm64' && $(uname -s) == 'Darwin' ]]; then
  # For macOS on M1, we may want to use linux/amd64 if there are issues running ci as arm64. However, those
  #  Docker instances are slower so it's not as ideal
  # params='--container-architecture linux/amd64'
  params=''
fi
# --reuse allows for utilizing the rust/yarn cache to speed up compilations
# --rm removes the container if the job fails
# -p=false disables pulling the container from dockerhub because we are using our local Dockerfile image
act workflow_dispatch -p=false -P ubuntu-latest=local/runner:latest --reuse --rm $params "$@"