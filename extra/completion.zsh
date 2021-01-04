#!/usr/bin/env zsh

_devtemplates.sh(){
    root_path="$(dirname $(dirname $(which devtemplates.sh)))"
    _values 'template target' $(ls "${root_path}/templates/" | tr '\t' '\n')
}


compdef _devtemplates.sh devtemplates.sh
