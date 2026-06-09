# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source $FHOME/.myeda/miniforge3-24.1.2-0/etc/profile.d/conda.csh

# xxx-dep.tar.gz
if ( $1 !~ *-dep.tar.gz ) then
  echo "Error: $1 must end with *-dep.tar.gz"
  exit 1
endif
set abs_path = `readlink -f $1 | sed 's/.tar.gz$//g'`

echo $abs_path
set env_name = `basename $abs_path | sed 's/-dep//g'`
set env_path = `dirname $CONDA_PYTHON_EXE`/../envs
if ( $2 == base ) then
  echo "Error: $2 can not set to base!"
  exit 1
else if ( -d $env_path/$2 ) then
  echo "Error: $2 exist, please remove first!"
  exit 1
endif

rm -rf $abs_path
tar -xzvf $1

( \
  setenv CONDA_CHANNEL_ALIAS file://$abs_path/conda/pkgs; \
  setenv PIP_INDEX_URL file://$abs_path/pip/pkgs/simple; \
  conda env create -n $2 -f $abs_path/$env_name.yaml \
)
