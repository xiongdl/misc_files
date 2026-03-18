# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source ~/.myeda/miniforge3-2024.1.2-0/etc/profile.d/conda.csh 
conda activate $1

rm -rf $1-dep
mkdir -p $1-dep/pip/pkgs $1-dep/conda/pkgs $1-dep/conda/repo

cd $1-dep
conda env export > $1.yaml

# pip
cd pip
pip list --format freeze > req.txt
echo "Done: pip list"
cd pkgs
pip download -r ../req.txt --quiet
echo "Done: pip pkgs"
cd ../..

# conda
cd conda
conda list --explicit > tmp.yaml
awk '/^http/' tmp.yaml > req.txt
rm -rf tmp.yaml
echo "Done: conda list"
cd pkgs
wget --quiet --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/118.0" -i ../req.txt
echo "Done: conda pkgs"
cd ..
cd repo
conda clean --index-cache
conda update python --dry-run --quiet
cp $CONDA_PREFIX/../../pkgs/cache/*.json .
echo "Done: conda repo"
cd ../..

# tar
cd ..
tar -czf $1-dep.tar.gz $1-dep

conda deactivate
