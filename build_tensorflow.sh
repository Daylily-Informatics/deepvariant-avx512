#!/bin/bash

# Install necessary dependencies
sudo apt-get update
sudo apt-get install -y python3-dev python3-pip git bazel build-essential clang-14 libc++-14-dev libc++abi-14-dev libstdc++-12-dev

# Update pip and essential Python packages
python3 -m pip install --upgrade pip numpy wheel packaging setuptools

# Clone TensorFlow source at version 2.15.0
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout v2.15.0  # DeepVariant 1.9.0 compatible TF version

# Configure TensorFlow build environment explicitly
export TF_NEED_CUDA=0
export TF_NEED_ROCM=0
export TF_NEED_MPI=0
export CC_OPT_FLAGS="-march=native -mavx512f -mavx512vl -mavx512bw -mavx512dq \
  -mavx512vnni -mavx512bf16 -mavx512vbmi -mavx512ifma -mavx512vpopcntdq \
  -mamx-int8 -mamx-tile -mamx-bf16 -O3 -mfma"

# Explicitly set Clang as your compiler
export CC=/usr/bin/clang-14
export CXX=/usr/bin/clang++-14

# Add include paths for standard libraries explicitly
export CPLUS_INCLUDE_PATH="/usr/include/c++/12:/usr/include/x86_64-linux-gnu/c++/12:/usr/lib/llvm-14/include/c++/v1"

# Set Python version explicitly if needed
export TF_PYTHON_VERSION=3.10

# Run TensorFlow configuration (use defaults, no special needs)
yes "" | ./configure


# Build the optimized wheel
if bazel --output_user_root=/dev/shm/bzl  build \
  --config=opt \
  --action_env=BAZEL_CXXOPTS="-std=c++17 -stdlib=libstdc++" \
  --cxxopt="-std=c++17" \
  --host_cxxopt="-std=c++17" \
  --cxxopt="-isystem/usr/include/c++/12" \
  --cxxopt="-isystem/usr/include/x86_64-linux-gnu/c++/12" \
  --cxxopt="-isystem/usr/lib/llvm-14/include/c++/v1" \
  //tensorflow/tools/pip_package:build_pip_package; then
    echo "Bazel build succeeded."
else
    echo "Bazel build failed." >&2
    exit 1
fi

# Generate wheel only if build succeeded
./bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg

echo "Optimized TensorFlow wheel is now available in ../tensorflow_pkg/"
