# Copyright © 2025 Mark Summerfield. All rights reserved.

package require struct::list 1

namespace eval diff {}

proc diff::diff {old_lines new_lines} {
    lassign [esc_codes] reset add del same
    set delta ""
    set lcs [::struct::list longestCommonSubsequence $old_lines $new_lines]
    foreach d [::struct::list lcsInvertMerge $lcs [llength $old_lines] \
                                                  [llength $new_lines]] {
        lassign $d action left right
        switch $action {
            added {
                foreach line [lrange $new_lines {*}$right] {
                    set delta [string cat $delta "${add}${line}${reset}\n"]
                }
            }
            deleted {
                foreach line [lrange $old_lines {*}$left] {
                    set delta [string cat $delta "${del}${line}${reset}\n"]
                }
            }
            changed {
                foreach line [lrange $old_lines {*}$left] {
                    set delta [string cat $delta "${del}${line}${reset}\n"]
                }
                foreach line [lrange $new_lines {*}$right] {
                    set delta [string cat $delta "${add}${line}${reset}\n"]
                }
            }
            unchanged {
                foreach line [lrange $old_lines {*}$left] {
                    set delta [string cat $delta "${same}${line}${reset}\n"]
                }
            }
        }
    }                                              
    return $delta
}

# See: https://en.wikipedia.org/wiki/ANSI_escape_code
# bold: "\x1B\[1m"
# italic: "\x1B\[3m"
# underline: "\x1B\[4m"
proc esc_codes {} {
    if {[dict exists [chan configure stdout] -mode]} { ;# tty
        set reset "\033\[0m"
        set add "\x1B\[34m+ " ;# blue
        set del "\x1B\[38;5;88m- \x1B\[9m" ;# dull red with overstrike
        set same "\x1B\[38;5;245m  " ;# gray
    } else { ;# redirected
        set reset ""
        set add "+ "
        set del "- "
        set same "  "
    }
    return [list $reset $add $del $same]
}

# txt must be a tk text widget
# See https://en.wikipedia.org/wiki/X11_color_names
proc diff::diff_text {old_lines new_lines txt} {
    $txt delete 1.0 end
    $txt tag configure added -foreground blue
    $txt tag configure del -foreground brown
    $txt tag configure deleted -foreground brown -overstrike true
    $txt tag configure unchanged -foreground gray67
    set lcs [::struct::list longestCommonSubsequence $old_lines $new_lines]
    foreach d [::struct::list lcsInvertMerge $lcs [llength $old_lines] \
                                                  [llength $new_lines]] {
        lassign $d action left right
        switch $action {
            added {
                foreach line [lrange $new_lines {*}$right] {
                    $txt insert end "+ $line\n" added
                }
            }
            deleted {
                foreach line [lrange $old_lines {*}$left] {
                    $txt insert end "- " del
                    $txt insert end "$line\n" deleted
                }
            }
            changed {
                foreach line [lrange $old_lines {*}$left] {
                    $txt insert end "- " del
                    $txt insert end "$line\n" deleted
                }
                foreach line [lrange $new_lines {*}$right] {
                    $txt insert end "+ $line\n" added
                }
            }
            unchanged {
                foreach line [lrange $old_lines {*}$left] {
                    $txt insert end "  $line\n" unchanged
                }
            }
        }
    }                                              
    $txt see 1.0
}
