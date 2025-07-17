#!/usr/bin/env tclsh9
# Copyright © 2025 Mark Summerfield. All rights reserved.

tcl::tm::path add [file normalize [file dirname [info script]]]

package require diff
package require textutil

proc main {} {
    if {$::argc != 3} { usage }
    set command [lindex $::argv 0]
    set old_file [lindex $::argv 1]
    set new_file [lindex $::argv 2]
    switch $command {
        d - diff { do_diff $old_file $new_file } 
        e - edits { do_edits $old_file $new_file } 
        p - patch { do_patch $old_file $new_file } 
        default { usage }
    }
}

proc usage {} {
    set width [term_width]
    set width2 [incr width -2]
    puts [unmark "~usage: %^diff.tcl% <COMMAND> <OLD_FILE>\
        <NEW_FILE|PATCH_FILE>\n"]
    puts [unmark [textutil::adjust \
        "Produces diffs and patch edits, or patches to restore originals." \
        -strictlength true -length $width]]
    puts [unmark "\n^d% ~or% ^diff%"]
    puts [unmark [textutil::indent [textutil::adjust \
        "Diffs file ~OLD_FILE% with file ~NEW_FILE% and outputs the
         contextualized differences." \
        -strictlength true -length $width2] "  "]]
    puts [unmark "^e% ~or% ^edits%"]
    puts [unmark [textutil::indent [textutil::adjust \
        "Diffs file ~OLD_FILE% with file ~NEW_FILE% and outputs the patch
        edits from ~OLD_FILE% to ~NEW_FILE%." \
        -strictlength true -length $width2] "  "]]
    puts [unmark "^p% ~or% ^patch%"]
    puts [unmark [textutil::indent [textutil::adjust \
        "Patches file ~OLD_FILE% against patch edits file ~PATCH_FILE% to
        reproduce the original ~NEW_FILE%." \
        -strictlength true -length $width2] "  "]]
    exit 2
}

proc unmark s {
    subst -nobackslashes -nocommands \
        [string map {"^" ${::BOLD} "~" ${::ITALIC} "%" ${::RESET}} $s]
}

proc term_width {{defwidth 72}} {
    if {[dict exists [chan configure stdout] -mode]} { ;# tty
        return [lindex [chan configure stdout -winsize] 0]
    }
    return $defwidth ;# redirected
}


# See: https://en.wikipedia.org/wiki/ANSI_escape_code
if {[dict exists [chan configure stdout] -mode]} { ;# tty
    set RESET "\033\[0m"
    set BOLD "\x1B\[1m"
    set ITALIC "\x1B\[3m"
    set RED "\x1B\[31m"
    set GREEN "\x1B\[32m"
    set BLUE "\x1B\[34m"
    set MAGENTA "\x1B\[35m"
} else { ;# redirected
    set RESET ""
    set BOLD ""
    set ITALIC ""
    set RED ""
    set GREEN ""
    set BLUE ""
    set MAGENTA ""
}

proc do_diff {old_file new_file} {
    set old_lines [split [readFile $old_file text] "\n"]
    set new_lines [split [readFile $new_file text] "\n"]
    set delta [diff::colorize [diff::contextualize [diff::diff $old_lines \
                                                               $new_lines]]]
    puts [join $delta "\n"]
}

proc do_edits {old_file new_file} {
    set old_lines [split [readFile $old_file text] "\n"]
    set new_lines [split [readFile $new_file text] "\n"]
    set edits [diff::edits $old_lines $new_lines]
    puts [join $edits "\n"]
}

proc do_patch {old_file patch_file} {
    set old_lines [split [readFile $old_file text] "\n"]
    set edits [split [readFile $patch_file text] "\n"]
    set new_lines [diff::patch $old_lines $edits]
    puts [join $new_lines "\n"]
}

main
