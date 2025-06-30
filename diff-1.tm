# Copyright © 2025 Mark Summerfield. All rights reserved.

package require struct::list 1

namespace eval diff {}

proc diff::diff {old_lines new_lines} {
    lassign [esc_codes] action reset add del same
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

# bold: "\033\[1m"
# italic: "\033\[3m"
# underline: "\033\[4m"
proc esc_codes {} {
    if {[dict exists [chan configure stdout] -mode]} { ;# tty
        set action "\033\[37m" ;# light gray
        set reset "\033\[0m"
        set add "${action}+${reset} \033\[34m" ;# blue
        set del "${action}-${reset} \033\[31m" ;# red
        set same "${action}=${reset} \033\[32m" ;# green
    } else { ;# redirected
        set action ""
        set reset ""
        set add "+ "
        set del "- "
        set same "= "
    }
    return [list $action $reset $add $del $same]
}

# txt must be a tk text widget
proc diff::diff_text {old_lines new_lines txt} {
    $txt delete 1.0 end
    $txt tag configure added -foreground blue
    $txt tag configure deleted -foreground red
    $txt tag configure unchanged -foreground green
    set lcs [::struct::list longestCommonSubsequence $old_lines $new_lines]
    foreach d [::struct::list lcsInvertMerge $lcs [llength $old_lines] \
                                                  [llength $new_lines]] {
        lassign $d action left right
        switch $action {
            added {
                foreach line [lrange $new_lines {*}$right] {
                    $txt insert end "⁁ $line\n" added
                }
            }
            deleted {
                foreach line [lrange $old_lines {*}$left] {
                    $txt insert end "⌫ $line\n" deleted
                }
            }
            changed {
                foreach line [lrange $old_lines {*}$left] {
                    $txt insert end "⌫ $line\n" deleted
                }
                foreach line [lrange $new_lines {*}$right] {
                    $txt insert end "⁁ $line\n" added
                }
            }
            unchanged {
                foreach line [lrange $old_lines {*}$left] {
                    $txt insert end "≡ $line\n" unchanged
                }
            }
        }
    }                                              
    $txt see 1.0
}
