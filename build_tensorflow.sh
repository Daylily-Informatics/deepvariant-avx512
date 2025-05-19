#!/bin/bash

# Install OS-level dependencies
sudo apt-get update
sudo apt-get install -y python3-dev python3-pip git bazel build-essential \
    clang-14 gcc-12 g++-12 libstdc++-12-dev

# Create clean Python virtual environment
python3 -m pip install --upgrade pip virtualenv
python3 -m virtualenv tf-build-env
source tf-build-env/bin/activate

# Install correct Python dependencies
pip install --upgrade pip setuptools wheel packaging
pip install numpy==1.24.3 cython==0.29.36

# Clone and checkout TensorFlow v2.15.0
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout v2.15.0

# Configure explicitly
export TF_NEED_CUDA=0
export TF_NEED_ROCM=0
export TF_NEED_MPI=0

# Compiler environment
export CC=/usr/bin/clang-14
export CXX=/usr/bin/clang++-14
export CPLUS_INCLUDE_PATH="/usr/include/c++/12:/usr/include/x86_64-linux-gnu/c++/12"

# Python version
export TF_PYTHON_VERSION=3.10

# Optimized AVX-512 (safe)
export CC_OPT_FLAGS="-march=icelake-server -O3 -mfma \
  -mavx512f -mavx512bw -mavx512dq -mavx512vl -mavx512vnni \
  -mavx512vbmi -mavx512vbmi2 -mavx512ifma -mavx512bitalg \
  -mavx512vpopcntdq -mavx512bf16 \
  -DEIGEN_MAX_ALIGN_BYTES=64 -DEIGEN_DONT_VECTORIZE_AVX512"

# Configure TensorFlow
yes "" | ./configure

# Clean previous Bazel caches
bazel clean --expunge
rm -rf $PWD/tmppl3/*

# Build TensorFlow wheel
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

# After successful build, generate wheel:
./bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg

echo "✅ Optimized TensorFlow wheel is now available in ../tensorflow_pkg/"
