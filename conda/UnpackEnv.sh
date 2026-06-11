#!/bin/sh
# xxx-dep.tar.gz
case "$1" in
    *-dep.tar.gz) ;;
    *)
        echo "Error: $1 must end with *-dep.tar.gz"
        exit 1
        ;;
esac
abs_path=$(readlink -f "$1" | sed 's/\.tar\.gz$//')

echo "$abs_path"
env_name=$(basename "$abs_path" | sed 's/-dep//g')
env_path=$(dirname "$CONDA_PYTHON_EXE")/../envs
if [ "$2" = "base" ]; then
    echo "Error: $2 can not set to base!"
    exit 1
elif [ -d "$env_path/$2" ]; then
    echo "Error: $2 exist, please remove first!"
    exit 1
fi

rm -rf "$abs_path"
tar -xzvf "$1"

(
    export CONDA_CHANNEL_ALIAS="file://$abs_path/conda/pkgs"
    export PIP_INDEX_URL="file://$abs_path/pip/pkgs/simple"
    conda env create -n "$2" -f "$abs_path/$env_name.yaml"
)
