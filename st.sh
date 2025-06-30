#!/bin/bash
nagelfar.sh \
    | grep -v Unknown.command..app::main
clc -s -l tcl
git st
