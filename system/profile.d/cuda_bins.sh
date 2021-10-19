# Taken from: 
# <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions>

# Check for existence of paths before appending to the variable.
# See <https://wiki.bash-hackers.org/syntax/pe#from_the_beginning> and
# <https://devhints.io/bash#parameter-expansions>

cuda_bin_path="/usr/local/cuda/bin"
if [[ ! "$PATH" =~ "$cuda_bin_path" ]]; then
    export PATH=${cuda_bin_path}${PATH:+:${PATH} }
fi

cuda_lib_path="/usr/local/cuda/lib64"
if [[ ! "$LD_LIBRARY_PATH" =~ "$cuda_lib_path" ]]; then
    export LD_LIBRARY_PATH=$cuda_lib_path\
        ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH} }
fi

