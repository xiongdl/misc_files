# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source ~/.myeda/miniforge3-2024.1.2-0/etc/profile.d/conda.csh 

set mypip = ~/.mypip
set myconda = ~/.myconda
set mych = ("conda-forge" "anaconda" "nvidia/label/cuda-12.2.0")

# =========================================================
# $1-dep.tar.gz: original env name
# $2: new env name
# Warning: packages for base venv
#   pip install pip2pi
#   conda install conda-build
# =========================================================
conda activate base
rm -rf $1-dep
tar -xzvf $1-dep.tar.gz

cd $1-dep/pip/pkgs
if (! -d $mypip) then
  mkdir -p $mypip
endif
\cp * $mypip -rf
dir2pi $mypip
cd ../../../

cd $1-dep/conda/pkgs
foreach ch ($mych)
  echo "Channel ###$ch###"
  if (! -d $myconda/$ch/linux-64) then
    mkdir -p $myconda/$ch/linux-64
  endif
  if (! -d $myconda/$ch/noarch) then
    mkdir -p $myconda/$ch/noarch
  endif
  awk -v v="/$ch/(linux-64|noarch)/" '$0 ~ v' ../req.txt > run.sh
  if (-z run.sh) then
    echo "Done: Empty"
  else
    sed -i 's#^\(.*\)/\('$ch'/linux-64/\)\(.*\)$#\\cp -rf \3 \$1/\2\3#g' run.sh
    sed -i 's#^\(.*\)/\('$ch'/noarch/\)\(.*\)$#\\cp -rf \3 \$1/\2\3#g' run.sh
    bash run.sh $myconda
    conda index $myconda/$ch
    echo "Done: Update"
  endif
end
cd ../../../

# create venv
cd $1-dep
conda env create -f $1.yaml -n $2 

conda deactivate
