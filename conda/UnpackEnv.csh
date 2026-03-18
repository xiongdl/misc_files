# Copy this line to .cshrc, so conda command is valid when sourcing this file
# source $FHOME/.myeda/miniforge3-24.1.2-0/etc/profile.d/conda.csh

set mypip = $FHOME/.mypip
set myconda = $FHOME/.myconda

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
if (`ls -A . | wc -l` == 0) then
  echo "Empty pip/pkgs!"
else
  echo "Copy  pip/pkgs!"
  cp -n * $mypip
  dir2pi $mypip
  echo "Done  pip/pkgs!"
endif
cd ../../../

set mych = (`sed -n '/^channels:/,/^dependencies:/p' $1-dep/$1.yaml\
  | grep '^\s*-' \
  | sed 's/^\s*-\s*//'`)
echo $mych
cd $1-dep/conda/pkgs
foreach src ($mych)
  if ($src == 'defaults') then
    # default channels: only consider pkgs/main
    set dst = pkgs/main
    set tmp = main
  else
    # custom channels
    set dst = cloud/$src
    set tmp = $src
  endif
  echo "Channel: $src -> $dst"
  if (! -d $myconda/$dst/linux-64) then
    mkdir -p $myconda/$dst/linux-64
  endif
  if (! -d $myconda/$dst/noarch) then
    mkdir -p $myconda/$dst/noarch
  endif
  awk -v v="/$tmp/(linux-64|noarch)/" '$0 ~ v' ../req.txt > run1.sh
  if (-z run1.sh) then
    echo "Done: Empty"
  else
    sed -i 's#^\(.*\)/\('$tmp'\)/linux-64/\(.*\)$#\\cp -n \3 \$1/'$dst'/linux-64/\3#g' run1.sh
    sed -i 's#^\(.*\)/\('$tmp'\)/noarch/\(.*\)$#\\cp -n \3 \$1/'$dst'/noarch/\3#g' run1.sh
    bash run1.sh $myconda

    grep "url.*$tmp" ../repo/*.info.json > run2.sh
    sed -i 's/info.json:.*http/json http/g' run2.sh
    sed -i 's#http.*/'$tmp'/#\$1/'$dst'/#g' run2.sh
    sed -i 's/^/\\cp /g' run2.sh
    sed -i 's#",$#/repodata.json#g' run2.sh
    bash run2.sh $myconda
    echo "Done: Update"
  endif
end
cd ../../../

# clean old index
conda clean --index-cache --yes

# create venv
#cd $1-dep
#conda env create -f $1.yaml -n $2 

conda deactivate
