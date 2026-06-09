# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source ~/.myeda/miniforge3-2024.1.2-0/etc/profile.d/conda.csh 

set abs_path = `readlink -f $1`
if ( $abs_path !~ *.yaml ) then
  echo "Error: File Must End with .yaml"
  exit 1
endif
set env_name = `basename $abs_path | sed 's/.yaml//g'`

rm -rf $env_name-dep
mkdir -p $env_name-dep/pip/pkgs $env_name-dep/conda/pkgs

# Extract conda & pip Requirements
cd $env_name-dep
sed '/- pip:/,$d' $abs_path > conda/conda.yaml
awk '/^[[:space:]]*- pip:/{f=1; next} f==1 && /^[^[:space:]]/{f=0} f==1{sub(/^[[:space:]]+- /, ""); print}' $abs_path > pip/req.txt

# Check whether env_name exist or not
set env_path = `dirname $CONDA_PYTHON_EXE`/../envs
if ( -d $env_path/$env_name ) then
  echo "Error: $env_name Exist, Please Remove First!"
endif

# conda
cd conda
conda clean --index-cache --yes
conda env create -n $env_name -f conda.yaml
conda activate $env_name
conda list --explicit > conda.list
echo "Done: conda venv"
awk '/^http/' conda.list > req.txt
rm -rf conda.list conda.yaml
echo "Done: conda list"
foreach file ( $CONDA_PREFIX/../../pkgs/cache/*.info.json )
  set repo = `grep url $file | awk -F '/' '{print $(NF-1)"/"$NF}' | sed 's/",$//'`
  grep $repo req.txt > tmp.txt
  mkdir -p pkgs/$repo
  wget --quiet --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0" -i tmp.txt -P pkgs/$repo
  set json = `echo $file | sed 's/info\.json/json/g'`
  cp $json pkgs/$repo/repodata.json -rf
  cp $file pkgs/$repo/repodata.info.json -rf
  rm tmp.txt -rf
  echo "Done: conda $repo"
end
cd ..

# pip
cd pip/pkgs
pip install -r ../req.txt --quiet
pip download -r ../req.txt --quiet
echo "Done: pip pkgs"
ls * > ../list.txt
cd ..
conda activate base
dumb-pypi --package-list list.txt --packages-url ../../ --output-dir ./index
cp index/simple pkgs/ -rf
rm index list.txt -rf
conda deactivate
cd ..

conda env export > $env_name.yaml
# tar
cd ..
tar -czf $env_name-dep.tar.gz $env_name-dep

conda deactivate
