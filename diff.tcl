#!/usr/bin/env tclsh9
# Copyright © 2025 Mark Summerfield. All rights reserved.

tcl::tm::path add [file normalize [file dirname [info script]]]

package require diff

proc main {} {
    const OLD [list the quick brown fox jumped over the lazy dogs]
    const NEW [list the quick red fox hopped over the dogs today]
    cli $OLD $NEW
    context
    gui $OLD $NEW
}

proc cli {old new} {
    set delta [diff::diff $old $new]
    puts [join $delta "\n"]
}

proc context {} {
    set old [split [readFile tdata/f0-old] \n]
    set new [split [readFile tdata/f0-new] \n]
    set delta [diff::diff $old $new false]
    set fh [open tdata/f0-diff0]
    set expected [split [read -nonewline $fh] \n]
    close $fh
    if {$delta ne $expected} {
        writeFile /tmp/act0 [join $delta "\n"]
        writeFile /tmp/exp0 [join $expected "\n"]
        puts "FAIL f0 0 context diff; diff /tmp/act0 /tmp/exp0"
    } else {
        puts "OK f0 0 context diff"
    }
    set delta [diff::contextualize [diff::diff $old $new false]]
    set fh [open tdata/f0-diff3]
    set expected [split [read -nonewline $fh] \n]
    close $fh
    if {$delta ne $expected} {
        writeFile /tmp/act3 [join $delta "\n"]
        writeFile /tmp/exp3 [join $expected "\n"]
        puts "FAIL f0 3 context diff; diff /tmp/act3 /tmp/exp3"
    } else {
        puts "OK f0 3 context diff"
    }
}

proc gui {old new} {
    package require tk
    wishinit
    tk appname "Diff Test"
    # ignore if no icon found
    catch { wm iconphoto . -default [image create photo -file \
                /usr/share/icons/hicolor/scalable/apps/diffpdf.svg]}
    tk::text .txt -width 32 -height 16 -wrap none \
        -yscrollcommand ".yscrollbar set" -xscrollcommand ".xscrollbar set"
    ttk::scrollbar .yscrollbar -orient vertical -command ".txt yview"
    ttk::scrollbar .xscrollbar -orient horizontal -command ".txt xview"
    set delta [diff::diff $old $new false]
    diff::diff_text $delta .txt
    grid .txt -column 0 -row 0 -sticky news
    grid .xscrollbar -column 0 -row 1 -sticky we
    grid .yscrollbar -column 1 -row 0 -sticky ns
    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1
    bind . <Escape> exit
    bind . <q> exit
}

proc wishinit {} {
    catch {
        set fh [open [file join [file home] .wishinit.tcl]]
        set raw [read $fh]
        close $fh
        eval $raw
    }
    const LINEHEIGHT [expr {[font metrics font -linespace] * 1.0125}]
    ttk::style configure Treeview -rowheight $LINEHEIGHT
    ttk::style configure TCheckbutton -indicatorsize \
        [expr {$LINEHEIGHT * 0.75}]
    set ::ICON_SIZE [expr {max(24, round(14 * [tk scaling]))}]
}

main
