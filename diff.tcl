#!/usr/bin/env wish9
# Copyright © 2025 Mark Summerfield. All rights reserved.

tcl::tm::path add [file normalize [file dirname [info script]]]

package require diff

proc main {} {
    const OLD [list the quick brown fox jumped over the lazy dogs]
    const NEW [list the quick red fox hopped over the dogs today]
    cli $OLD $NEW
    gui $OLD $NEW

}

proc cli {old new} {
    set delta [diff::diff $old $new]
    puts -nonewline $delta
}

proc gui {old new} {
    tk scaling 1.67
    option add *tearOff 0
    option add *insertOffTime 0
    ttk::style configure . -insertofftime 0
    ttk::style theme use clam

    tk appname "Diff Test"
    # ignore if no icon found
    catch { wm iconphoto . -default [image create photo -file \
                /usr/share/icons/hicolor/scalable/apps/diffpdf.svg]}
    tk::text .txt -width 32 -height 16 -wrap none \
        -yscrollcommand ".yscrollbar set" -xscrollcommand ".xscrollbar set"
    ttk::scrollbar .yscrollbar -orient vertical -command ".txt yview"
    ttk::scrollbar .xscrollbar -orient horizontal -command ".txt xview"
    set delta [diff::diff_text $old $new .txt]
    grid .txt -column 0 -row 0 -sticky news
    grid .xscrollbar -column 0 -row 1 -sticky we
    grid .yscrollbar -column 1 -row 0 -sticky ns
    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1
    bind . <Escape> exit
    bind . <q> exit
}

main
