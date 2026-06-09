# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source $FHOME/.myeda/miniforge3-24.1.2-0/etc/profile.d/conda.csh

# xxx-dep.tar.gz
set abs_path = `readlink -f $1 | sed 's/.tar.gz$//g'`
rm -rf $abs_path
tar -xzvf $1

echo $abs_path
set env_name = `basename $abs_path | sed 's/-dep//g'`

( \
  setenv CONDA_CHANNEL_ALIAS file://$abs_path/conda/pkgs; \
  setenv PIP_INDEX_URL file://$abs_path/pip/pkgs/simple; \
  conda env create -n $2 -f $abs_path/$env_name.yaml --offline \
)
