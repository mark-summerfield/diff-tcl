# Copyright © 2025 Mark Summerfield. All rights reserved.

package require struct::list 1

namespace eval diff {}

# bold: "\033\[1m"
# italic: "\033\[3m"
# underline: "\033\[4m"

proc diff::diff {old_lines new_lines {termcolors false}} {
    if {$termcolors} {
        set action "\033\[37m" ;# light gray
        set reset "\033\[0m"
        set add "${action}+${reset} \033\[34m" ;# blue
        set del "${action}-${reset} \033\[31m" ;# red
        set same "${action}=${reset} \033\[32m" ;# green
    } else {
        set add "+ "
        set del "- "
        set same "= "
        set reset ""
    }
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

# TODO
# txt must be a tk text widget
proc diff::diff_text {old_lines new_lines txt} {
    set lcs [::struct::list longestCommonSubsequence $old_lines $new_lines]
    foreach d [::struct::list lcsInvertMerge $lcs [llength $old_lines] \
                                                  [llength $new_lines]] {
        lassign $d action left right
        switch $action {
            added {
                foreach line [lrange $new_lines {*}$right] {
                    set delta [string cat $delta "+ $line\n"]
                }
            }
            deleted {
                foreach line [lrange $old_lines {*}$left] {
                    set delta [string cat $delta "- $line\n"]
                }
            }
            changed {
                foreach line [lrange $old_lines {*}$left] {
                    set delta [string cat $delta "- $line\n"]
                }
                foreach line [lrange $new_lines {*}$right] {
                    set delta [string cat $delta "+ $line\n"]
                }
            }
            unchanged {
                foreach line [lrange $old_lines {*}$left] {
                    set delta [string cat $delta "= $line\n"]
                }
            }
        }
    }                                              
    return $delta
}
