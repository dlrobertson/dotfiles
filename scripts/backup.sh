#!/usr/bin/env bash

DIR="\/\.snapshots"
LIMIT="1 year ago"

main () {
    snap-tool backup
    clean_snapshots $(get_range $(date +"%Y-%m-%d %H:%M:%S" -d "$LIMIT"))
}

get_range () {
    today=$(date +"%Y-%m-%d %H:%M:%S")
    limit="$1 $2"
    delrange=$today
    inc="1"
    num_limit=$(date_to_num $limit)
    num_del=$(date_to_num $delrange)
    while [ $num_del -gt $num_limit ]; do
        delrange=$(date +"%Y-%m-%d %H:%M:%S" -d "$inc hours ago")
        inc=$[$inc+$inc]
        echo $num_del
        num_del=$(date_to_num $delrange)
    done
}

date_to_num () {
    echo $(echo $(date +"%Y-%m-%d %H:%M:%S" -d "$1 $2") | sed -e "s/[-: ]//g")
}

remove_basedir () {
    echo $(echo $1 | sed -e "s/$DIR\///")
}

clean_range () {
    if [ -z "$2" ]; then
        echo "Error: clean_range expected input"
        exit 1
    fi
}

clean_snapshots () {
    i="0"
    files=($DIR/*)
    arr=($@)
    files_len=${#files[@]}
    j=$[$files_len-1]
    while [ $j -gt "0" ] && [ $i -lt $# ]; do
        file=$(remove_basedir ${files[$j]})
        if [ $file -lt ${arr[$i]} ]; then
            echo ${arr[$1]}
            while [ $file -lt ${arr[$i]} ]; do
                i=$[i+1]
            done
        else
            snap-tool clean $file
        fi
        j=$[j-1]
    done
}

main
