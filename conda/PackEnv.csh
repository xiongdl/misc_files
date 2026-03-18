# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source ~/.myeda/miniforge3-2024.1.2-0/etc/profile.d/conda.csh 
conda activate $1

rm -rf $1-dep
mkdir -p $1-dep/pip/pkgs $1-dep/conda/pkgs

cd $1-dep
conda env export > $1.yaml

# pip
cd pip
awk '/==/' ../$1.yaml > req.txt
sed -i 's/.* - //g' req.txt
cd pkgs
pip download -r ../req.txt
cd ../..

# conda
cd conda
conda list --explicit > tmp.yaml
awk '/^http/' tmp.yaml > req.txt
rm -rf tmp.yaml
cd pkgs
wget --user-agent="Mozilla" -i ../req.txt
cd ../..

# tar
cd ..
tar -czvf $1-dep.tar.gz $1-dep

conda deactivate
