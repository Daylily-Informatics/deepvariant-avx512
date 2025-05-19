#!/bin/bash

# Install necessary dependencies
sudo apt-get update
sudo apt-get install -y python3-dev python3-pip git bazel build-essential \
    clang-14 gcc-12 g++-12 libstdc++-12-dev

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

# Safe, optimized AVX512 flags + Eigen fix
export CC_OPT_FLAGS="-march=icelake-server -O3 -mfma \
  -mavx512f -mavx512bw -mavx512dq -mavx512vl -mavx512vnni \
  -mavx512vbmi -mavx512vbmi2 -mavx512ifma -mavx512bitalg \
  -mavx512vpopcntdq -mavx512bf16 \
  -DEIGEN_MAX_ALIGN_BYTES=64 -DEIGEN_DONT_VECTORIZE_AVX512"



# Explicitly set Clang as your compiler
export CC=/usr/bin/clang-14
export CXX=/usr/bin/clang++-14

# Add include paths for GCC libstdc++ explicitly
export CPLUS_INCLUDE_PATH="/usr/include/c++/12:/usr/include/x86_64-linux-gnu/c++/12"

# Set Python version explicitly
export TF_PYTHON_VERSION=3.10

# Run TensorFlow configuration (use defaults)
yes "" | ./configure

# Clean bazel workspace before building (very important)
bazel clean --expunge
rm -rf $PWD/tmppl3/*

# Explicitly use GCC’s libstdc++ headers only
bazel --output_user_root=$PWD/tmppl3 build \
  --config=opt \
  --action_env=BAZEL_CXXOPTS="-std=c++17 -stdlib=libstdc++" \
  --cxxopt="-std=c++17" \
  --host_cxxopt="-std=c++17" \
  --cxxopt="-isystem/usr/include/c++/12" \
  --cxxopt="-isystem/usr/include/x86_64-linux-gnu/c++/12" \
  --host_cxxopt="-isystem/usr/include/c++/12" \
  --host_cxxopt="-isystem/usr/include/x86_64-linux-gnu/c++/12" \
  //tensorflow/tools/pip_package:build_pip_package

# After successful build:
./bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg

echo "✅ Optimized TensorFlow wheel is now available in ../tensorflow_pkg/"
