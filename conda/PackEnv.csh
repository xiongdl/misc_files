# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source ~/.myeda/miniforge3-2024.1.2-0/etc/profile.d/conda.csh 
conda activate $1

rm -rf $1-dep
mkdir -p $1-dep/pip/pkgs $1-dep/conda/pkgs

cd $1-dep
conda env export > $1.yaml

# pip
cd pip
pip list --format freeze > req.txt
echo "Done: pip list"
cd pkgs
pip download -r ../req.txt --quiet
echo "Done: pip pkgs"
ls * > ../list.txt
cd ..
conda activate base
dumb-pypi --package-list list.txt --packages-url ../../ --output-dir ./index
cp index/simple pkgs/ -rf
rm index -rf
conda deactivate
cd ..

# conda
cd conda
sed '/- pip:/,$d' ../$1.yaml > conda.yaml
conda env create -n base_conda -f conda.yaml
conda activate base_conda
conda list --explicit > tmp.yaml
conda deactivate
conda remove -n base_conda -y
echo "Done: conda venv"
awk '/^http/' tmp.yaml > req.txt
rm -rf tmp.yaml
echo "Done: conda list"
conda clean --index-cache --yes
conda update python --dry-run --quiet
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

# tar
cd ..
tar -czf $1-dep.tar.gz $1-dep

conda deactivate
