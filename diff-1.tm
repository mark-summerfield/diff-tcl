# Copyright © 2025 Mark Summerfield. All rights reserved.

package require struct::list 1

namespace eval diff {}

# Returns list of lines
proc diff::diff {old_lines new_lines} {
    set delta [list]
    set lcs [::struct::list longestCommonSubsequence $old_lines $new_lines]
    foreach d [::struct::list lcsInvertMerge $lcs [llength $old_lines] \
                                                  [llength $new_lines]] {
        lassign $d action left right
        switch $action {
            added {
                foreach line [lrange $new_lines {*}$right] {
                    lappend delta "+ $line"
                }
            }
            deleted {
                foreach line [lrange $old_lines {*}$left] {
                    lappend delta "- $line"
                }
            }
            changed {
                foreach line [lrange $old_lines {*}$left] {
                    lappend delta "- $line"
                }
                foreach line [lrange $new_lines {*}$right] {
                    lappend delta "+ $line"
                }
            }
            unchanged {
                foreach line [lrange $old_lines {*}$left] {
                    lappend delta "  $line"
                }
            }
        }
    }                                              
    return $delta
}

# % only occurs if contextualize-d
proc diff::colorize delta {
    lassign [esc_codes] reset add del same ellipsis
    set color_delta [list]
    foreach line $delta {
        set action [string index $line 0]
        set line [string range $line 2 end]
        switch $action {
            "+" { lappend color_delta "${add}${line}${reset}" }
            "-" { lappend color_delta "${del}${line}${reset}" }
            " " { lappend color_delta "${same}${line}${reset}" }
            "%" { lappend color_delta \
                    "${ellipsis}≣ [string repeat ┈ 60]${reset}"
                }
        }
    }
    return $color_delta
}

# See: https://en.wikipedia.org/wiki/ANSI_escape_code
# bold: "\x1B\[1m"
# italic: "\x1B\[3m"
# underline: "\x1B\[4m"
proc diff::esc_codes {} {
    if {[dict exists [chan configure stdout] -mode]} { ;# tty
        set reset "\033\[0m"
        set add "\x1B\[34m+ " ;# blue
        set del "\x1B\[38;5;88m- \x1B\[9m" ;# dull red with overstrike
        set same "\x1B\[38;5;245m  " ;# gray
        set ellipsis "\x1B\[36m" ;# teal
    } else { ;# redirected
        set reset ""
        set add "+ "
        set del "- "
        set same "  "
        set ellipsis ""
    }
    return [list $reset $add $del $same $ellipsis]
}

# txt must be a tk text widget
# See https://en.wikipedia.org/wiki/X11_color_names
# % only occurs if contextualize-d
proc diff::diff_text {delta txt} {
    $txt delete 1.0 end
    $txt tag configure added -foreground blue
    $txt tag configure del -foreground brown
    $txt tag configure deleted -foreground brown -overstrike true
    $txt tag configure unchanged -foreground gray67
    $txt tag configure ellipsis -background teal
    foreach line $delta {
        set action [string index $line 0]
        switch $action {
            "+" { $txt insert end $line\n added }
            "-" {
                $txt insert end "- " del
                $txt insert end [string range $line 2 end]\n deleted
                }
            " " { $txt insert end $line\n unchanged }
            "%" { $txt insert "≣ [string repeat ┈ 40]" ellipsis }
        }
    }
    $txt see 1.0
}

# Returns list of lines
proc diff::contextualize delta {
    set result [list]
    set i 0
    while {$i < [llength $delta]} {
        set line [lindex $delta $i]
        set action [string index $line 0]
        switch $action {
            "-" -
            "+" { lappend result $line }
            " " {
                    set first $i
                    set last [incr i]
                    while {$last < [llength $delta]} {
                        set line [lindex $delta $last]
                        set action [string index $line 0]
                        if {$action ne " "} {
                            incr last -1
                            break
                        }
                        incr last
                    }
                    set d [expr {$last - $first}]
                    if {$d > 4} {
                        set j [expr {$first + 2}]
                        lappend result {*}[lrange $delta $first $j]
                        set j [expr {$last - 2}]
                        lappend result %%%%%
                        lappend result {*}[lrange $delta $j $last]
                    } else {
                        lappend result {*}[lrange $delta $first $last]
                    }
                    set i $last
                }
        }
        incr i
    }
    return $result
}
