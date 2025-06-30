#!/usr/bin/env tclsh9
# Copyright © 2025 Mark Summerfield. All rights reserved.

const APPPATH [file normalize [file dirname [info script]]]
tcl::tm::path add $APPPATH

package require diff

proc main {} {
    set bold "\033\[1m"
    set reset "\033\[0m"
    const OLD [list the quick brown fox jumped over the lazy dogs]
    const NEW [list the quick red fox hopped over the dogs today]
    set delta [diff::diff $OLD $NEW]
    puts "${bold}Mono${reset}"
    puts -nonewline $delta
    puts "${bold}Color${reset}"
    set delta [diff::diff $OLD $NEW true]
    puts -nonewline $delta
}

main
