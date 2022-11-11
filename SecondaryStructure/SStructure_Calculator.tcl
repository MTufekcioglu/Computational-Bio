set a_outfile [open ./A_percent_ss.dat w]
puts $a_outfile "Frame\thelix_percent\tsheet_percent"

set h_lookup {H G I}
set s_lookup {E B}

set sel_name "chain A and name CA"

set frame_num [molinfo top get numframes]
set a_full [atomselect top $sel_name]
set a_len [llength [$a_full get resid]]

$a_full delete

for {set i 0} {$i < $frame_num} {incr i} {

    animate goto $i
    
    set a_sel [atomselect top $sel_name]
    
    mol ssrecalc top
    
    set a_struc_string [$a_sel get structure]
    set a_helix 0
    set a_sheet 0
    
    foreach letter $h_lookup {
        set temp [expr {[llength [split $a_struc_string $letter]] - 1}]
        incr a_helix $temp
    }
    
    foreach letter $s_lookup {
        set temp [expr {[llength [split $a_struc_string $letter]] - 1}]
        incr a_sheet $temp
    }
    
    set a_h_percent [expr {double($a_helix) / double($a_len) * 100}]
    set a_s_percent [expr {double($a_sheet) / double($a_len) * 100}]
    
    puts $a_outfile "$i\t$a_h_percent\t$a_s_percent"
    
    $a_sel delete

}

close $a_outfile

