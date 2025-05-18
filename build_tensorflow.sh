# Install necessary dependencies
sudo apt-get update
sudo apt-get install -y python3-dev python3-pip git bazel build-essential

# Ensure pip is updated
python3 -m pip install --upgrade pip numpy wheel packaging setuptools

# Clone TensorFlow source
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout v2.15.0  # Match DeepVariant 1.9.0's TensorFlow version explicitly

# Configure build options for CPU optimizations
export TF_NEED_CUDA=0
export TF_NEED_ROCM=0
export TF_NEED_MPI=0
export CC_OPT_FLAGS="-march=native -mavx512f -mavx512vl -mavx512bw -mavx512dq \
  -mavx512vnni -mavx512bf16 -mavx512vbmi -mavx512ifma -mavx512vpopcntdq \
  -mamx-int8 -mamx-tile -mamx-bf16 -O3 -mfma"
./configure  # Answer prompts according to your system (use defaults mostly)

# Build the optimized wheel (this step will take time)
bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package

# Generate the wheel
./bazel-bin/tensorflow/tools/pip_package/build_pip_package ../tensorflow_pkg

# Your optimized wheel file is now in ../tensorflow_pkg/
