sudo apt update
sudo apt install -y curl gnupg

# Download bazelisk and place it in /usr/local/bin as 'bazel'
sudo curl -L https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 \
    -o /usr/local/bin/bazel

# Make it executable
sudo chmod +x /usr/local/bin/bazel

# Verify bazel is installed correctly
bazel --version

sudo apt update
sudo apt install -y clang llvm

sudo apt-get update
sudo apt-get install -y build-essential clang-14 libc++-14-dev libc++abi-14-dev libstdc++-12-dev


sudo apt-get update
sudo apt-get install -y gcc-12 g++-12 libstdc++-12-dev build-essential
