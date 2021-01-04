#!/usr/bin/env bash

export L="$(cd $(dirname $0); pwd)"

TEMPLATE_DIR="${L}/../templates"


COMMAND="$1"
shift 1

case $COMMAND in
    django|load-nodejs-project-path)
        bash $TEMPLATE_DIR/$COMMAND/make.sh $*
             ;;
    *) echo 'nothing'
       ;;
esac

