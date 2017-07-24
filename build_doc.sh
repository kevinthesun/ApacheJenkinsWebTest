#!/bin/bash

web_url="https://github.com/kevinthesun/ApacheJenkinsWebTest"
mxnet_url="https://github.com/dmlc/mxnet.git"
web_folder="VersionedWeb"
mxnet_folder="mxnet"
local_build="latest"
web_branch="static_web"
git clone $web_url $web_folder
git clone $mxnet_url --recursive $mxnet_folder
cd $web_folder
git checkout -b $web_branch "origin/$web_branch"
cd ..
mkdir "$local_build"
mkdir "$local_build/versions"

latest_tag=''
if [ -f "$web_folder/tag.txt" ]
then 
    latest_tag=$(<"$web_folder/tag.txt")
fi

input="tag_list.txt"
tag_list=()
while read -r line 
do
    tag_list+=("$line")
done < "$input"

mkdir master
cd "$mxnet_folder/docs"
make html USE_OPENMP=0 USE_OPENCV=0 || exit 1
cd ../..
python AddVersion.py --file_path "$mxnet_folder/docs/_build/html/"
cp -a "$mxnet_folder/docs/_build/html/." master

total=${#tag_list[*]}
cd "$mxnet_folder/docs"
for (( i=0; i<=$(( $total -1 )); i++ ))
do
    git checkout -- ..
    git clean -d -f ..
    git checkout "tags/${tag_list[$i]}"
    if [[ ${tag_list[$i]} == v0.10.0* ]]
    then
        cd ..
        rm -rf cub
        git clone https://github.com/NVlabs/cub.git
        cd docs
    fi
    git submodule update
    if [ $i == 0 ]
    then
        if [ "${tag_list[0]}" != "$latest_tag" ]
        then
            make html USE_OPENMP=0 USE_OPENCV=0 || exit 1
            cd ../..
            python AddVersion.py --file_path "$mxnet_folder/docs/_build/html/" --current_version "${tag_list[$i]}"
            cd "$mxnet_folder/docs"
            mkdir _build/html/versions
            cp -a _build/html/. "../../$local_build"
            echo "${tag_list[$i]}" > "../../$local_build/tag.txt"
        fi
    else
        if [ "$latest_tag" == '' ]
        then
            make html USE_OPENMP=0 USE_OPENCV=0 || exit 1
            cd ../..
            python AddVersion.py --file_path "$mxnet_folder/docs/_build/html/" --current_version "${tag_list[$i]}"
            cd "$mxnet_folder/docs"
            mkdir "../../$local_build/versions/${tag_list[$i]}"
            cp -a _build/html/. "../../$local_build/versions/${tag_list[$i]}"
        fi
        if [ "${tag_list[0]}" != "$latest_tag" ]
        then
            if [ $i == 1 ]
            then
                cp -a "../../$web_folder/." "../../$local_build/versions/${tag_list[$i]}"
                rm -rf "../../$local_build/versions/${tag_list[$i]}/versions"
            else
                cp -R "../../$web_folder/versions/${tag_list[$i]}" "../../$local_build/versions/${tag_list[$i]}"
            fi
        fi
    fi
done

cd ../..
mkdir "$local_build/versions/master"
if [ "${tag_list[0]}" != "$latest_tag" ]
then
    rm -rf "$web_folder/*"
    cp -a "$local_build/." "$web_folder"
fi
rm -rf "$web_folder/versions/master"
cp -R master "$web_folder/versions/master"

