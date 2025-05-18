sudo apt update
sudo apt install -y curl gnupg

# Download bazelisk and place it in /usr/local/bin as 'bazel'
sudo curl -L https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 \
    -o /usr/local/bin/bazel

# Make it executable
sudo chmod +x /usr/local/bin/bazel

# Verify bazel is installed correctly
bazel --version
