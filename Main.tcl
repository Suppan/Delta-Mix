#========================================================================================================
#========================================================================================================
#
#
#
#                                         Delta-Mix
#
#                                   Wolfgang Suppan (©2021)
#
#
#                         graphic editor for algorithmic soundfile mixing
#
#
#
#========================================================================================================
#========================================================================================================

package require Tk

#========================================================================================================
#
#
#
#                                         Global Vars
#
#
#
#========================================================================================================

set app_Dir0 [ file dirname [ file normalize [ info script ] ] ]
set app_Dir "$app_Dir0/"
set curr_Dir {}
set default_Dir [file join $app_Dir "sounds/A"]
set dirtail {}
set no_close_write 0
set compi [info hostname]
#if {$compi == "mac-mini"} {}
set seed {}
set temp_seed {}
set colorList {}
set dxList {}
set min_Mul 0.2
set curr_SF {}
set curr_SF_pos {}
set sf_List {}
set sf_List_len 0
set sf_mul_List {}
set sf_transp_List {}
set sf_dur0_List {}
set sf_dur_List {}
set sf_chan_List {}
set graph_w 630
set graph_h 300
set graph_rand 20
set graph_rect_size 8
set pixeladdy 0
set id_data [dict create]

#========================================================================================================
#
#
#
#                                             Proc
#
#
#
#========================================================================================================

proc write_curr_Dir {dir} {
  global app_Dir
  set path [file join $app_Dir ".temp_dir"]
  set f [open $path w]
  puts -nonewline $f $dir
  close $f
}

proc get_curr_Dir {} {
  global app_Dir
  global curr_Dir
  global default_Dir
  set path [file join $app_Dir ".temp_dir"]
  set test [file exist $path]
  if {$test == 1} {   set fp [open $path r]
            set curr_Dirx [read $fp]
            close $fp }
  set test2 [file exist $curr_Dirx]          
  if {$test2 == 0} { set curr_Dirx [file join $app_Dir "sounds/A"] 
            write_curr_Dir $curr_Dirx 
            }
  return $curr_Dirx 
}

proc TestEntry_onlyZahl {Zeichen} {
    return [string is digit $Zeichen]
    }

proc round_scaleval {val round} {   
    if {$round == 0} {expr round($val)} else {
            set roundx [expr 10 ** $round * 1.0] 
            expr {round($roundx*$val)/$roundx}} 
}

proc write_file {str path} {
  set f [open $path w]
  puts $f $str
  close $f
}

proc ladd {l} {
  set total 0.0 
  foreach nxt $l {set total [expr {$total + $nxt}]}
  return $total
}

proc get_graph_len {} {
  global colorList
  global dxList
  set res1 [llength $colorList]
  set res2 [expr [llength $dxList] + 1]
  if {$res1 < $res2 } {set res $res1} else {set res $res2}
  return $res
}

proc mk_onsetList {} {
  global dxList
  set res {0}
  set len [expr [get_graph_len] - 1]
  set x 0
  for {set posx 0} {$posx < $len} {incr posx} {
  set xx [lindex $dxList $posx]
  set x [expr $x + $xx]
  lappend res $x
  }
return $res
}


proc get_List_max {list} {
  set x {}
  foreach xx $list {
    if {$x == ""} {set x $xx} else {
      if {$xx > $x} {set x $xx}
    }}  
  return $x
}

proc get_List_min {list} {
  set x {}
  foreach xx $list {
    if {$x == ""} {set x $xx} else {
      if {$xx < $x} {set x $xx}
    }}  
  return $x
}

proc update_sf_dur_List {} {
  global colorList
  global sf_dur0_List
  global sf_dur_List
  global sf_transp_List

  set sf_dur_List {}
  set len [llength $colorList]

  for {set x 0} {$x < $len} {incr x} {
    set y [lindex $colorList $x]
    set durx [lindex $sf_dur0_List $y]
    set trx [lindex $sf_transp_List $x]
    set speedx [expr pow(2.0,($trx / 12.0))]
    set durx2 [expr $durx / $speedx ]
    set durx3 [round_scaleval $durx2 6]
    lappend sf_dur_List $durx3
    }
}

proc update_tempox {val} { 
  global tempo
  global puls_sum
  global graph_w
  global graph_h
  global slider_pos

    .lb_durx configure -text [format "%s' %s\"" [expr round(floor($val / 60))] [expr round($val) % 60]]
  place .lb_durx -x [expr 25 + ($slider_pos * 6)] -y 20
  updateCanvas $graph_w $graph_h
     }

proc ClearCanvas {w} {
    $w delete "all"
}

proc get_y {h rand max_y y} {
  set resx [expr (($h - 2 * $rand) / $max_y) * ($max_y - $y) + $rand]
  return $resx
}

proc get_x {w rand len x} {
  global pixeladdx
  set fact [expr (($w - (3.0 * $rand) - (2.0 * $pixeladdx)) * 1.0) / ($len  * 1.0)] 
  set resx [expr ($fact * $x) + $rand + $pixeladdx]
  return $resx
}

proc read_m_data_file {} {
    global curr_Dir
    global default_Dir
  set curr_Dir [get_curr_Dir]
    set Path [file join $curr_Dir ".m_data"]
  set path_test [file exist $Path]
  if {$path_test == 0} {  reset_m_data_default } ;#???
    set fp [open $Path r]
    set dict [read $fp]
    close $fp
    return $dict
}

proc write_m_data_file {str} {
    global curr_Dir
    set Path [file join $curr_Dir ".m_data"]
    set f [open $Path w]
    puts -nonewline $f $str 
    close $f
}

proc write_pref_data_file {str} {
    global app_Dir
    set Path [file join $app_Dir ".prefs_data"]
    set f [open $Path w]
    puts -nonewline $f $str 
    close $f
}

proc read_pref_data_file {} {
    global app_Dir
    set Path [file join $app_Dir ".prefs_data"]
    set fp [open $Path r]
    set dict [read $fp]
    close $fp
    return $dict
}

proc write_pref_data {csound_terminal_path default_Dir} {
  set data_pairs [list "csound_terminal_path" $csound_terminal_path "default_Dir" $default_Dir]
  write_pref_data_file $data_pairs
}

proc  write_m_data {} {
  global colorList
  global dxList
  global sf_List
  global sf_List_len
  global sf_mul_List
  global sf_transp_List
  global sf_dur0_List
  global sf_dur_List
  global sf_chan_List
  global outpath
  global out_format
  global len_list
  global seed
  global temp_seed
  global list_reps
  global dur_sec
  global slider_pos
  global slider_sum
  global open_sf
  global select_sf_addx

  set data_pairs [list "sf_List" $sf_List "sf_List_len" $sf_List_len "sf_mul_List" $sf_mul_List "sf_transp_List" $sf_transp_List "sf_dur_List" $sf_dur_List\
  "sf_dur0_List" $sf_dur0_List "sf_chan_List" $sf_chan_List "colorList" $colorList "dxList" $dxList "outpath" $outpath "out_format" $out_format "len_list" $len_list\
  "seed" $seed "temp_seed" $temp_seed  "dur_sec" $dur_sec "slider_pos" $slider_pos "slider_sum" $slider_sum "list_reps" $list_reps "open_sf" $open_sf "select_sf_addx" $select_sf_addx]
  write_m_data_file $data_pairs
}

proc reset_m_data_default {} {
  global graph_w
  global graph_h
  global curr_Dir
  global app_Dir
  global sf_List
  global sf_List_len
  global colorList
  global dxList
  global sf_mul_List
  global sf_transp_List
  global sf_dur0_List
  global sf_chan_List
  global outpath
  global out_format
  global len_list
  global seed
  global temp_seed
  global list_reps
  global dur_sec
  global slider_pos
  global slider_sum
  global open_sf
  global select_sf_addx
  global n_colorList
  global puls_sum
  global slider_sum
  global rexxt1
  global all_lines
  global all_elem
  global selected
  global all_values

  #set curr_Dir [file join $app_Dir "sounds/A"]
  set sf_List [lsort -dictionary -increasing -nocase [glob -directory $curr_Dir -type f *{.wav,.WAV,.aif,.aiff,.AIF,.AIFF}*]] ;#*.wav]]
  set sf_List_len [llength $sf_List] 
  set colorList {}
  set dxList {}
  set sf_mul_List {}
  set sf_transp_List {}
  set sf_dur0_List {}
  set sf_chan_List {}
  set outpath "mix_out"
  set out_format "wav"
  set len_list $sf_List_len
  set seed {}
  set temp_seed {}
  set list_reps 0
  set dur_sec 60
  set slider_sum 10
  set slider_pos 50
  set open_sf 1
  #set select_sf_addx "dB0"
  set select_sf_addx "trx"
  set n_colorList [llength $colorList]
  set puls_sum [ladd $dxList]


  .c delete "all"
  .c2 delete "all"

  set rexxt1 [.c create rectangle 4 4 [expr $graph_w + 2] [expr $graph_h + 2] -outline #1c79d9 -width 4 ]
  set all_lines {}
  set all_elem {}
  set selected {}
  set all_values {}


  for {set x 0} {$x < $sf_List_len} {incr x} {
      set pathx [lindex $sf_List $x]
      lappend colorList $x
      if {$x < [expr $sf_List_len - 1]} {lappend dxList 1}
      lappend sf_mul_List 0
      lappend sf_transp_List 0
      set durx [exec mdls -name kMDItemDurationSeconds -raw $pathx]
      lappend sf_dur0_List $durx
      lappend sf_dur_List $durx
      set chanx [exec mdls -name kMDItemAudioChannelCount -raw $pathx] 
      lappend sf_chan_List $chanx
      }

  set data_pairs [list "sf_List" $sf_List "sf_List_len" $sf_List_len "sf_mul_List" $sf_mul_List "sf_transp_List" $sf_transp_List\
  "sf_dur_List" $sf_dur_List "sf_dur0_List" $sf_dur0_List "sf_chan_List" $sf_chan_List "colorList" $colorList "dxList" $dxList "outpath" $outpath "out_format" $out_format "len_list" $len_list\
  "seed" $seed "temp_seed" $temp_seed  "dur_sec" $dur_sec "slider_pos" $slider_pos "slider_sum" $slider_sum "list_reps" $list_reps "open_sf" $open_sf "select_sf_addx" $select_sf_addx]
  write_m_data_file $data_pairs


  CreateCanvas
  updateCanvas $graph_w $graph_h
  update_sf_dur_List    
  CreateCanvas2
  updateCanvas2 $graph_w
}

#---------------------------
#set random order
#---------------------------

# shuffle color_List (= pos list)
proc shuffle {data} {
    set length [llength $data]
    for {} {$length > 1} {incr length -1} {
        set idx_1 [expr {$length - 1}]
        set idx_2 [expr {int($length * rand())}]
        set temp [lindex $data $idx_1]
        lset data $idx_1 [lindex $data $idx_2]
        lset data $idx_2 $temp
    }
    return $data
}

# mk list for shuffle
proc mk_colorList0 {} {
  global sf_List_len
  set bag {}
  for {set i 0} {$i < $sf_List_len} {incr i} {
  lappend bag $i}
  return $bag
}

# or create rnd list:
proc random_int { upper_limit } {
    global myrand
    set myrand [expr int(rand() * $upper_limit)]
    return $myrand
}

# rnd list  without reps
proc random_dx { upper_limit len} {
    set bag {}
    # safty test: $i < 4000 if the list is not growing...
    for {set i 0} {$i < 4000 && [llength $bag] < $len} {incr i} {
            set rx [random_int $upper_limit]
            set rx_before [lindex $bag end]
            # append if no reps:
            if {$rx != $rx_before} {lappend bag $rx}
        }
    return $bag
}

proc get_dx_list {liste} {
    set todo $liste
    set bag {}
    set len [expr [llength $liste] - 1]
    for {set x 0} {$x < $len} {incr x} {
      set b [lindex $todo end]
      set a [lindex $todo end-1]
      set res [expr abs($b - $a)]
      set todo [lreplace $todo end end]
      lappend bag $res
    }
    return [lreverse $bag]
}

#---------------------------
# Menu functions
#---------------------------

proc delete_out_files {} {
    global curr_Dir

      set answer [tk_messageBox -message "delete \"~/out\" folder?" \
        -icon question -type yesno \
        -detail "press Evaluate to create a new ~/out folder"]
      if {$answer == yes} {
    set the_path "$curr_Dir/out/"
    file delete -force $the_path
    }
}

#proc cleanup_dir {} {
#  global app_Dir
#  set answer [tk_messageBox -message "delete curr_Dir and Close?" \
#    -icon warning -type yesno \
#    -detail "...start again"]
#    if {$answer == yes} {
#  set dirfile_path [file join $app_Dir ".temp_dir"]
#  exec rm -f $dirfile_path
#  exit
#  }
#}

proc lock_random {} {
  global temp_seed
  global seed
   set seed $temp_seed
}

proc unlock_random {} {
  global temp_seed
  global seed
   set seed {}
}

proc update_list_reps_state {} {
  global list_reps
   if {$list_reps == 0} {.enText_len configure -state disabled} else {
  .enText_len configure -state active    
   }
}

proc open_csound_console {} {
  global temp_console_out
  global out_file
   set out_file [file exist  $temp_console_out]
  if {$out_file == 1} {exec open $temp_console_out} else {bell}
}

proc open_sound_folder {} {
  global curr_Dir
  exec open $curr_Dir
}

proc open_csound_csd {} {
  global curr_Dir
   exec open "$curr_Dir/temp_csound.csd"
}

proc open_csound_sf {} {
  global outpath
  global out_format
  global temp_sf_path
  global curr_Dir

  set temp_sf_path [file join "$curr_Dir/out" "$outpath.$out_format"]  
  set out_file [file exist $temp_sf_path]
  if {$out_file == 1} {exec open $temp_sf_path} else {bell}
}

proc open_new_dir {} {
    global curr_Dir
  set upfile [file join ".." $curr_Dir]
    set dir [tk_chooseDirectory -title "New Soundfile Directory" -initialdir $upfile]  
  if {$dir != ""} {
  set all_new_sf [glob -directory $dir -type f *{.wav,.WAV,.aif,.aiff,.AIF,.AIFF}*]
  set all_new_sf_len [llength $all_new_sf]
  if {$all_new_sf_len < 2} {tk_messageBox -message "Error: only $all_new_sf_len soundfiles!!!" -icon warning -type ok } else { 
          set short_foldername [file tail $dir]
          set answer [tk_messageBox -message "open new dir with $all_new_sf_len soundfiles?" \
                      -icon question -type yesno \
                      -detail "new dir: ~/$short_foldername/"]
                  if {$answer == yes} {   set curr_Dir $dir
                            write_curr_Dir $dir
                            wm title . [format "sf Dir: ~/$short_foldername/"]
                            #reset_m_data_default 
                            upload_m_data
                            reset_Main
                            } else { open_new_dir }
    }
  } 
}

proc start_delta_mix {} {
  global app_Dir
  global curr_Dir
  global graph_w
  global graph_h
  global csound_terminal_path
  global default_Dir
  global compi
  set curr_Dir [get_curr_Dir]

  set prefs_data [read_pref_data_file]
  set csound_terminal_path [dict get $prefs_data csound_terminal_path]
  set default_Dir [dict get $prefs_data default_Dir]
  upload_m_data
}

proc upload_m_data {} {
  global curr_Dir
  global colorList
  global m_data
  global dxList
  global sf_List
  global sf_List_len
  global sf_mul_List
  global sf_transp_List
  global sf_dur0_List
  global sf_dur_List
  global sf_chan_List
  global outpath
  global out_format
  global dirtail
  global temp_console_out

  set m_data_path [file join $curr_Dir ".m_data"]
  set m_data_exists [file exist $m_data_path]

  if {$m_data_exists == 0} { reset_m_data_default }
  set m_data [read_m_data_file]   

  set colorList [dict get $m_data colorList]
  set dxList [dict get $m_data dxList]
  set sf_List  [dict get $m_data sf_List]
  set sf_List_len [dict get $m_data sf_List_len]
  set sf_mul_List [dict get $m_data sf_mul_List]
  set sf_transp_List [dict get $m_data sf_transp_List]
  set sf_dur0_List [dict get $m_data sf_dur0_List]
  set sf_dur_List [dict get $m_data sf_dur_List]
  set sf_chan_List [dict get $m_data sf_chan_List]
  set outpath [dict get $m_data outpath]
  set out_format [dict get $m_data out_format]

  set dirtail [file tail $curr_Dir]
  wm title . [format "soundfile Dir: ~/$dirtail/"]
  set temp_console_out [file join "$curr_Dir/out" "console.txt"]
}

proc reset_Main {} {
  global rexxt1
  global all_lines
  global all_elem
  global selected
  global all_values
  global graph_w
  global graph_h
  global sf_List_len
  global sf_mul_List
  global sf_dur_List
  global sf_dur0_List
  global colorList

  .c delete "all"
  set rexxt1 [.c create rectangle 4 4 [expr $graph_w + 2] [expr $graph_h + 2] -outline #1c79d9 -width 4 ]
  set all_lines {}
  set all_elem {}
  set selected {}
  set all_values {}
  CreateCanvas
  updateCanvas $graph_w $graph_h
  .c2 delete "all"
  set sf_List_len [llength $colorList] 
  set sf_mul_List [lrepeat [llength $colorList] 0]
  set sf_transp_List [lrepeat [llength $colorList] 0]
  set sf_dur_List {}
  foreach y $colorList {set durx [lindex $sf_dur0_List $y]; lappend sf_dur_List $durx}  
  #update_sf_dur_List    
  CreateCanvas2
  updateCanvas2 $graph_w
}

set counter 0
set prefs_data [read_pref_data_file]
set csound_terminal_path_x [dict get $prefs_data csound_terminal_path]
set default_Dir_x [dict get $prefs_data default_Dir]

proc mk_Pref_Win {} {
    # Make a unique widget name
    global counter
    global csound_terminal_path_x
    global default_Dir_x
    set w .gui[incr counter]

  set prefs_data [read_pref_data_file]
  set csound_terminal_path_x [dict get $prefs_data csound_terminal_path]
  set default_Dir_x [dict get $prefs_data default_Dir]

    # Make the toplevel
    toplevel $w
    wm title $w "DeltaMix Preferences"
  wm geometry $w "700x200+250+50"
  wm resizable $w 0 0
    # Put a GUI in it
  place [label $w.text1 -text "csound Path:"] -x 20 -y 35 
  ttk::entry $w.pref_outpath -textvariable csound_terminal_path_x -width 60
  place $w.pref_outpath -x 120 -y 35 

  place [label $w.text3 -text "default sf Dir:"] -x 20 -y 85 
  ttk::entry $w.pref_default_Dir -textvariable default_Dir_x -width 60
  place $w.pref_default_Dir -x 120 -y 85

  #write_pref_data
    place [button $w.set -text UPDATE -command {
    write_pref_data $csound_terminal_path_x $default_Dir_x
    }
    ] -x 120 -y 150
    place [button $w.ok -text CLOSE -command [list destroy $w]] -x 580 -y 150
}


set counter2 0

set help_text "

in progress...


"

proc mk_Help_Win {} {
    # Make a unique widget name
  global help_text
    set w .gui[incr counter2]
    # Make the toplevel
    toplevel $w
    wm title $w "Help"
  wm geometry $w "500x700+250+50"
  wm resizable $w 0 0
    # Put a GUI in it
  place [label $w.text1 -text $help_text] -x 20 -y 35 
    place [button $w.ok -text OK -command [list destroy $w]] -x 420 -y 650

}

#========================================================================================================
#
#
#
#                                         Main Window
#
#
#
#========================================================================================================

set geometry_start "800x720+250+50"
set geometry_expand "1200x720+250+50"

wm title . [format "soundfile Dir: ~/$dirtail/"]
wm resizable . 1 1
wm geometry . $geometry_start
wm minsize . 800 520
wm maxsize . 3400 1300

option add *Menu.tearOff 0
. configure -menu .mbar

start_delta_mix

#============================================================================
# menu 0

menu .mbar
.mbar add cascade -label "File" -menu .mbar.file
.mbar add cascade -label "Edit" -menu .mbar.edit
.mbar add cascade -label "Exec" -menu .mbar.exec
.mbar add cascade -label "Parameter" -menu .mbar.param
.mbar add cascade -label "Window" -menu .mbar.window

#============================================================================
# menu1 File

menu .mbar.file
.mbar.file add command -label "New soundfile Dir" -accelerator Command-N -command { open_new_dir }
.mbar.file add separator
.mbar.file add command -label "Preferences" -accelerator "Command-‚" -command { mk_Pref_Win }
 


bind . <Command-n> { open_new_dir }
bind . <Command-,> { mk_Pref_Win }

#============================================================================
# menu2 Edit

menu .mbar.edit
.mbar.edit add command -label "Open Soundfile Folder" -accelerator Command-O -command {open_sound_folder }
.mbar.edit add command -label "Delete out Folder" -accelerator Command-Delete -command { delete_out_files }
#.mbar.edit add command -label "rm curr_Dir and Close" -accelerator Command-Shift-Delete -command { cleanup_dir }

bind . <Command-Key-BackSpace> {delete_out_files}
#bind . <Command-Shift-Key-BackSpace> {cleanup_dir}
bind . <Command-o> { open_sound_folder }

#============================================================================
# menu3 Csound

menu .mbar.exec
.mbar.exec add command -label "Evaluate Csound" -accelerator Command-E -command {eval_Csound }
.mbar.exec add command -label "Open SoundFile Mix" -accelerator Command-Shift-O -command { open_csound_sf}
.mbar.exec add separator
.mbar.exec add command -label "Open console" -accelerator Command-C -command { open_csound_console }
.mbar.exec add command -label "Open Csound score" -accelerator Command-D -command { open_csound_csd }
.mbar.exec add separator
.mbar.exec add command -label "lock Random" -accelerator Command-L -command { lock_random }
.mbar.exec add command -label "unlock Random" -accelerator Command-Shift-L -command { unlock_random }
.mbar.exec add separator
.mbar.exec add command -label "Reset Order and dx" -accelerator Command-Option-0 -command { reset_m_data_default }

bind . <Command-e> { eval_Csound }
bind . <Command-O> { open_csound_sf }
bind . <Command-c> { open_csound_console }
bind . <Command-d> { open_csound_csd }
bind . <Command-l> { lock_random }
bind . <Command-L> { unlock_random }
bind . <Command-Option-0> { reset_m_data_default }

#============================================================================
# menu4 Param

set param_stat1 1
set param_stat2 0
set param_stat3 0

proc update_param_stat {} {
  global param_stat1 
  global param_stat2
  global param_stat3
  global all_elem
  global all_elem2
  global all_elem3
  global all_elem4
  global select_sf_addx
  global selected
  global selected1
  global selected2
  global selected3

  global dxList
  global sf_mul_List
  global sf_transp_List

  switch $select_sf_addx {
        "dx" {  set param_stat1 1
        set param_stat2 0
        set param_stat3 0
        update_draw_dx $dxList
        }
        "dB0" {  set param_stat1 0
        set param_stat2 1
        set param_stat3 0
        update_draw_db $sf_mul_List
        }

        "trx" {  set param_stat1 0
        set param_stat2 0
        set param_stat3 1
        update_draw_tr $sf_transp_List 
        }
    } 
}

menu .mbar.param
.mbar.param add checkbutton -label "sf onsets (dx)" -variable param_stat1 -accelerator Command-1 -command {
                                                set select_sf_addx "dx"
                                                update_param_stat
                                                refresCanvas2                                                
                                                }
.mbar.param add checkbutton -label "gain (dB)" -variable param_stat2 -accelerator Command-2 -command {
                                                set select_sf_addx "dB0"
                                                update_param_stat
                                                refresCanvas2
                                                }
.mbar.param add checkbutton -label "transp (midi)" -variable param_stat3 -accelerator Command-3 -command {
                                                set select_sf_addx "trx"
                                                update_param_stat
                                                refresCanvas2  
                                                }

bind . <Command-KeyPress-1> { 
  set select_sf_addx "dx"
  update_param_stat
  refresCanvas2
}

bind . <Command-KeyPress-2> { 
  set select_sf_addx "dB0"
  update_param_stat
  refresCanvas2
}

bind . <Command-KeyPress-3> { 
  set select_sf_addx "trx"
  update_param_stat
  refresCanvas2
}

#============================================================================
# menu5 Window

menu .mbar.window
.mbar.window add command -label "Open DeltaMix Help"  -accelerator h -command { mk_Help_Win }

bind . <KeyPress-h> { mk_Help_Win }

#========================================================================================================
#
#
#
#                                         Labels,Buttons,Sliders
#
#
#
#========================================================================================================

ttk::label .lb_appname -text "DeltaMix v0.22"  -font "menlo 24" 
place .lb_appname -x 550 -y 5

ttk::label .lb_info_txt_dur -text "sum dx = entire dur - dur of last soundfile"  -font "menlo 11" -foreground #1c79d9
ttk::label .lb_info_key1 -text "up-arrow and down-arrow (shift) -> edit value of selected points"  -font "menlo 11" -foreground #1c79d9
ttk::label .lb_info_key2 -text "left-arrow and right-arrow -> move selection"  -font "menlo 11" -foreground #1c79d9
ttk::label .lb_info_key3 -text "click on point (shift) -> select (extend selection)"  -font "menlo 11" -foreground #1c79d9
ttk::label .lb_info_key4 -text "press 0 -> set default (0)"  -font "menlo 11" -foreground #1c79d9
ttk::label .lb_info_key5 -text "press o -> opens selected sf (with changed param dB and tr)"  -font "menlo 11" -foreground #1c79d9

set n_colorList [llength $colorList]
ttk::label .lb_colorList_len -text "\[len = $n_colorList\]"
place .lb_colorList_len -x 30 -y 143

set len_list [dict get $m_data len_list];#14
ttk::entry .enText_len  -textvariable len_list -width 3 -validate key -validatecommand {TestEntry_onlyZahl %S}
place .enText_len -x 680 -y 210

set seed [dict get $m_data seed];#{}
set temp_seed [dict get $m_data temp_seed];#{}
ttk::entry .enText_seed  -textvariable seed -width 12 -validate key -validatecommand {TestEntry_onlyZahl %S}
place .enText_seed -x 510 -y 80

set list_reps [dict get $m_data list_reps];#0
ttk::checkbutton .check_list_reps  -text "set_len?" -variable list_reps -command update_list_reps_state
place .check_list_reps -x 3 -y 180

proc update_slider_pos {val} {
  global slider_sum
  global slider_pos
  global dur_sec

  set dur_sec [expr ($slider_pos * $slider_sum * 60) / 100.0]
  update_tempox  $dur_sec
}

proc update_slider_sum {} {
  global slider_sum
  global slider_pos
  global dur_sec
  set dur_sec [expr ($slider_pos * $slider_sum * 60) / 100.0]
  update_tempox  $dur_sec
}

set slider_sum [dict get $m_data slider_sum];#10
ttk::menubutton .mb_slider_sum -textvariable slider_sum
menu .mb_slider_sum.menu -tearoff 0
.mb_slider_sum configure -menu .mb_slider_sum.menu
foreach x {1 2 3 4 5 8 10 15 20} { .mb_slider_sum.menu add radiobutton -value $x -variable slider_sum -label $x  -command {update_slider_sum}}
place .mb_slider_sum -x 650 -y 37 

update_list_reps_state
set dur_sec [dict get $m_data dur_sec];#60
set slider_pos [dict get $m_data slider_pos];#50
ttk::scale .slider_dur_sec -orient horizontal -from 1 -to 100 -length 600  -variable slider_pos -command update_slider_pos

ttk::label .lb_dur -text "\[min\]"

set puls_sum [ladd $dxList]

ttk::label .lb_durx -text [format "%s' %s\"" [expr round(floor($dur_sec / 60))] [expr round($dur_sec) % 60]]

ttk::label .lb__outpath -text "/out/*.wav"
place .lb__outpath -x 20 -y 670

ttk::entry .enText_outpath  -textvariable outpath -width 14
place .enText_outpath -x 100 -y 668 

ttk::menubutton .mb_format -textvariable out_format
menu .mb_format.menu -tearoff 0
.mb_format configure -menu .mb_format.menu
set out_format_List {"aiff" "wav"}
foreach x $out_format_List { .mb_format.menu add radiobutton -value $x -variable out_format -label $x }
place .mb_format -x 260 -y 669 

set open_sf [dict get $m_data open_sf];#1
ttk::checkbutton .check_open_sf  -text "open sf?" -variable open_sf
place .check_open_sf -x 660 -y 675

place .slider_dur_sec -x 30 -y 42
place .lb_durx -x [expr 25 + ($slider_pos * 6)] -y 20  
place .lb_dur -x 720 -y 40 
place .lb_info_txt_dur  -x 20 -y 4

place .lb_info_key1  -x 24 -y 590
place .lb_info_key2  -x 24 -y 610
place .lb_info_key3  -x 24 -y 630
place .lb_info_key4  -x 24 -y 650
place .lb_info_key5  -x 150 -y 85



proc refresCanvas {} {
  ClearCanvas .c
  CreateCanvas 
}

set select_sf_addx [dict get $m_data select_sf_addx];#"dB0"

if {$select_sf_addx == "dx"} {
  place .slider_dur_sec -x 30 -y 42
  place .lb_durx -x [expr 25 + ($slider_pos * 6)] -y 20
  place .lb_dur -x 720 -y 40 
  place .lb_info_txt_dur  -x 20 -y 4
  }

ttk::radiobutton .rb1_x -text "Dx" -value "dx" -variable select_sf_addx -command {  set select_sf_addx "dx"
                                          update_param_stat
                                          refresCanvas2 
                                          } -takefocus 0
ttk::radiobutton .rb2_x -text "dB" -value "dB0" -variable select_sf_addx -command { set select_sf_addx "dB0"
                                          update_param_stat
                                          refresCanvas2 
                                          } -takefocus 0
ttk::radiobutton .rb3_x -text "Tr" -value "trx" -variable select_sf_addx -command { set select_sf_addx "trx"
                                          update_param_stat
                                          refresCanvas2 
                                          } -takefocus 0

place .rb1_x -x 690 -y 540
place .rb2_x -x 690 -y 480
place .rb3_x -x 690 -y 510

# write m_data when exit...
bind . <Destroy> {
    # Test if we are a toplevel window
    if {"%W" == [winfo toplevel %W]} {
      if {$no_close_write == 0} { write_m_data } 
    }
}

#========================================================================================================
#
#
#
#                                         Canvas (soundfiles)
#
#
#
#========================================================================================================

canvas .c -width $graph_w -height $graph_h -background white
place .c -x 20 -y 120 
set rexxt1 [.c create rectangle 0 4 [expr $graph_w + 2] [expr $graph_h + 2] -outline #1c79d9 -width 2 ]
set all_lines {}
set all_lines_txt {}
set all_lines_txt_path {}
set all_elem {}
set selected {}
set all_values {}

proc updateCanvas {w addy} {
  global graph_w
  global graph_h
  global pixeladdy
  global graph_rand
  global graph_rect_size
  global rexxt1
  global all_lines
  global all_lines_txt
  global all_lines_txt_path
  global all_elem
  global all_values
  global colorList
  global dxList
  global sf_List
  global dur_sec

  set testy [.c coords $rexxt1]
  set diff [expr $w - 630]

  .c coords $rexxt1 [list 4 4 [expr $w + 2] [expr 302 + $pixeladdy]]
  set graph_max_y [llength $sf_List]
  
  for {set y 0} {$y < $graph_max_y} {incr y} {
    set idx [lindex $all_lines $y]
    set idx_txt [lindex $all_lines_txt $y]
    set idx_txt_path [lindex $all_lines_txt_path $y]
    set testx [.c coords $idx]
    set x0 [lindex $testx 0]
    set new_h [expr 300 + $pixeladdy + 0]
    set y1 [expr [get_y $new_h $graph_rand $graph_max_y $y] + 4]
    .c coords $idx [list $x0 $y1 $w $y1]
    .c coords $idx_txt [list  24 [expr $y1 - 23]]
    .c coords $idx_txt_path [list  24 [expr $y1 - 10]]
  }

  
  set countx 0
  foreach idz $all_elem {
    set pointy [lindex $colorList $countx]
    incr countx
    set x1 [get_x $graph_w $graph_rand [llength $all_elem] $countx]
    set y1 [get_y $graph_h $graph_rand $graph_max_y $pointy]
    .c coords $idz [list [expr $x1 + $graph_rand]  [expr $y1 + 0] [expr $x1 + $graph_rect_size + $graph_rand] [expr $y1 + $graph_rect_size]]
    }

  set countx 0
  set puls_sum [ladd $dxList]
  set dur_fact [expr $dur_sec * 1.0 / $puls_sum]

  foreach idzz $all_values {
    set pointy [lindex $colorList $countx]
    set valx [lindex $dxList $countx]
    if {$valx != ""} {  set dxx_sec [expr $dur_fact * $valx] 
              set dxx_sec1 [round_scaleval $dxx_sec 2]
              set dxx_sec2 " $dxx_sec1\""
              } else { set dxx_sec2 ""}

    incr countx
    set x1 [get_x $graph_w $graph_rand [llength $all_elem] $countx]
    set y1 [get_y $graph_h $graph_rand $graph_max_y $pointy]

    .c itemconfigure $idzz -text $dxx_sec2
    .c coords $idzz [list [expr $x1 + 4 + $graph_rand] [expr $y1 - 5]]
    }
  .c configure -width $w
}

# dict set id_data $idx $pointy
proc CreateCanvas {} {
  global curr_Dir
  global all_elem
  global all_values
  global rect_store
  global all_lines
  global all_lines_txt
  global all_lines_txt_path
  global graph_rand
  global graph_w
  global graph_h
  global graph_rect_size
  global colorList
  global sf_dur0_List
  global sf_List
  global sf_List_len
  global dxList
  global select_sf_addx
  global sf_mul_List
  global sf_transp_List
  global id_data
  global dur_sec

  set graph_len [get_graph_len]
  set graph_max_y [llength $sf_List]
  set all_lines {}
  set all_lines_txt {}
  set all_lines_txt_path {}

  # 1. create b lines und short sf name 
  for {set y 0} {$y < $graph_max_y} {incr y} {
          set pathx [lindex $sf_List $y]
          set pathnamex [file rootname [file tail $pathx]]
          set y1 [expr [get_y $graph_h $graph_rand $graph_max_y $y] + $graph_rect_size / 2]
          set y2 [.c create line 25 $y1 $graph_w $y1 -width 1 -fill lightgray ];#-dash {2 4}
          lappend all_lines $y2

          set txt_path [.c create text 24 [expr $y1 - 10] -text $pathnamex -fill gray -tags name -anchor nw -font {-family menlo -size 9}]
          lappend all_lines_txt_path $txt_path

          set durx [lindex $sf_dur0_List $y]
          set durx1 [round_scaleval $durx 2]
          set durx2 "$durx1\""
          set txt [.c create text 24 [expr $y1 - 23] -text $durx2 -fill lightgray -tags sfdur -anchor nw -font {-family menlo -size 9}]
          lappend all_lines_txt $txt
  }

  set puls_sum [ladd $dxList]
  set dur_fact [expr $dur_sec * 1.0 / $puls_sum]
  
  #2. create sf_rectangles and dur_text [sec]
  for {set x 0} {$x < $graph_len} {incr x} {
    ;# x1 y1 x2 y2
    set pointy [lindex $colorList $x]  
    set x1 [get_x $graph_w $graph_rand $graph_len $x]
    set y1 [get_y $graph_h $graph_rand $graph_max_y $pointy]
    set x2 [expr $x1 + $graph_rect_size]
    set y2 [expr $y1 + $graph_rect_size]

    #dur_text
    if { $x < [expr $graph_len - 1]} {
    set dxx [lindex $dxList $x]
    set dxx_sec [expr $dur_fact * $dxx] 
    set dxx_sec1 [round_scaleval $dxx_sec 2]
    set dxx_sec2 "$dxx_sec1\""
      set idxv [.c create text [expr $x2 + 49] [expr $y1 - 7] -text $dxx_sec2 -fill gray -tags vals -font {-family menlo -size 9}]
      lappend all_values $idxv
    }

    # rectangles
    set idx [.c create rectangle [expr $x1 + 53] $y1 [expr $x2 + 53] $y2 -fill #1c79d9 -outline #1c79d9 -tags sf]
    #puts $idx
    lappend all_elem $idx
    # set id_data: id -> nth soundfile
    dict set id_data $idx $pointy
    }
  }

set dB_0x [lindex $sf_mul_List 0]
set transp_addx [lindex $sf_transp_List 0]

#========================================================================================================
#
#
#
#                                         Canvas2 (edit soundfiles)
#
#
#
#========================================================================================================

set graph2_w 630
set graph2_h 150
set graph2_rand 20
set graph2_rect_size 8

#set selected {}
set selected1 {}
set selected2 {}
set selected3 {}

canvas .c2 -width $graph2_w -height $graph2_h -background white ;#-border black
place .c2 -x 20 -y 430 

#set all_elem {}
set all_elem2 {}
set all_elem3 {}
set all_elem4 {}

#set all_values {}
set all_values2 {}
set all_values3 {}
set all_values4 {}

proc updateCanvas2 {w} {

  global select_sf_addx
  global dxList
  global sf_mul_List
  global sf_transp_List

  switch $select_sf_addx {
    "dx"  {update_draw_dx  $dxList }
        "dB0" { update_draw_db $sf_mul_List}
      "trx" {update_draw_tr $sf_transp_List}
    }
  .c2 configure -width $w
}

proc CreateCanvas2 {} {
  global all_elem
  global selected2
  global graph2_rand
  global graph2_w
  global graph2_h
  global graph2_rect_size
  global colorList
  global sf_List
  global sf_List_len
  global dxList
  global select_sf_addx
  global sf_mul_List
  global sf_transp_List
  global sel2_rect_id
  
  set graph_len [get_graph_len]
  set graph_max_y [get_List_max $colorList]
  
  set sel2_rect_id [.c2 create rectangle 0 0 0 0 -fill "white smoke" -outline lightgray]

  draw_dx $dxList
  draw_db $sf_mul_List
  draw_tr $sf_transp_List 
  
  refresCanvas2
}

set all_elem2 {}

proc update_draw_dx  {liste} {
  global dxList
  global graph2_rand
  global graph2_w
  global graph2_len
  global graph2_h
  global graph2_rect_size
  global all_elem2
  global all_values2
  global select_sf_addx

  set graph2_len [llength $liste]
  set graph2_max_y [get_List_max $liste]

  if {$select_sf_addx == "dx"} {
  for {set x 0} {$x < $graph2_len} {incr x} {
    set pointy [lindex $liste $x]
    set idzz [lindex $all_values2 $x]
    set idyy [lindex $all_elem2 $x]
    set x1 [get_x $graph2_w $graph2_rand [expr $graph2_len + 1] [expr $x + 1]]
    set y1 [expr ((($graph2_h - $graph2_rand * 1.2) * 1.0 / $graph2_max_y) * ($graph2_max_y - $pointy)) +  $graph2_rand]
    .c2 itemconfigure $idzz -text $pointy
    .c2 coords $idzz [list [expr $x1 + 4 + $graph2_rand] [expr $y1 - 5]]
    .c2 coords $idyy [list [expr $x1 + $graph2_rand] [expr $y1 + 0] [expr $x1 + $graph2_rect_size + $graph2_rand] [expr $graph2_h + 2]]
    }
  }
}

proc draw_dx {liste} {
  global graph2_rand
  global graph2_w
  global graph2_h
  global graph2_rect_size
  global all_elem2
  global all_values2

  set graph2_len [llength $liste]
  set graph2_max_y [get_List_max $liste]

  set all_elem2 {}
  set all_values2 {}

  for {set x 0} {$x < $graph2_len} {incr x} {
    ;# x1 y1 x2 y2
    set pointy [lindex $liste $x]
    set x1 [get_x $graph2_w $graph2_rand [expr $graph2_len + 1] $x]
    set y1 [expr ((($graph2_h - $graph2_rand * 1.2) * 1.0 / $graph2_max_y) * ($graph2_max_y - $pointy)) +  $graph2_rand]
    set x2 [expr $x1 + $graph2_rect_size]
    set y2 $graph2_h
    set dxx [lindex $liste $x]
    if {$dxx == ""} {} else {
    set idx [.c2 create rectangle [expr $x1 + 53] [expr $y1 + 10] [expr $x2 + 53] $y2 -fill gray -outline gray -tags dx -state hidden]
    lappend all_elem2 $idx
    set idxv [.c2 create text [expr $x2 + 50] [expr $y1 + 2] -text $dxx -fill gray -font {-family menlo -size 9} -state hidden]
    lappend all_values2 $idxv
    }
    }
}

set all_elem3 {}

proc update_draw_db {liste} {
  global graph2_rand
  global graph2_w
  global graph2_len
  global graph2_h
  global graph2_rect_size
  global all_elem3
  global all_values3
  global 0_dby_id
  global 0_dby_id2
  global 0_dby
  global 0_dby2
  global select_sf_addx 

  set graph2_len [llength $liste]
  set graph2_max_y [get_List_max $liste]

  if {$select_sf_addx == "dB0"} {

  .c2 coords $0_dby_id [list 25 $0_dby $graph2_w $0_dby]
  .c2 coords $0_dby_id2 [list 25 $0_dby2 $graph2_w $0_dby2]

  for {set x 0} {$x < $graph2_len} {incr x} {
    set dbx_val [lindex $liste $x]
    set idzz [lindex $all_values3 $x]
    set idyy [lindex $all_elem3 $x]
    set x1 [get_x $graph2_w $graph2_rand $graph2_len  [expr $x + 1]]
    set y1 [expr 1 + (log(abs($dbx_val - 1)) * 27)]
    .c2 itemconfigure $idzz -text $dbx_val
    .c2 coords $idzz [list [expr $x1 + 4 + $graph2_rand] [expr $0_dby + $y1 - 14]]
    .c2 coords $idyy [list [expr $x1 + $graph2_rand] [expr $0_dby + $y1 + 8] [expr $x1 + $graph2_rect_size + $graph2_rand] [expr $0_dby + $y1 - 8]]
    }
  } 
}

proc draw_db {liste} {
  global graph2_rand
  global graph2_w
  global graph2_h
  global graph2_rect_size
  global all_elem3
  global all_values3
  global 0_dby_id
  global 0_dby_id2
  global dbx_elem1
  global dbx_elem2
  global 0_dby
  global 0_dby2

  set graph2_len [llength $liste]
  set graph2_max_y [get_List_max $liste]

  set all_elem3 {}
  set all_values3 {}

  set 0_dby 20
  set 0_dby_id [.c2 create line 25 $0_dby $graph2_w $0_dby -width 1 -fill #1c79d9 -state hidden] ;# -dash {4 4}]
  set dbx_elem1 [.c2 create text 35 [expr $0_dby - 7] -text "0 dB" -fill #1c79d9 -font {-family menlo -size 9} -state hidden]

  set 0_dby2 140
  set 0_dby_id2 [.c2 create line 25 $0_dby2 $graph2_w $0_dby2 -width 1 -fill #1c79d9 -state hidden] ;# -dash {4 4}]
  set dbx_elem2 [.c2 create text 35 [expr $0_dby2 - 7] -text "-80 dB" -fill #1c79d9 -font {-family menlo -size 9} -state hidden]

  for {set x 0} {$x < $graph2_len} {incr x} {
    ;# x1 y1 x2 y2
    set pointy [lindex $liste $x]
    set x1 [get_x $graph2_w $graph2_rand $graph2_len $x]
    set y2 $0_dby
    set x2 [expr $x1 + $graph2_rect_size]
    set y1 $graph2_h
    set dxx [lindex $liste $x]
    if {$dxx == ""} {} else {
    set idx [.c2 create rectangle [expr $x1 + 53] [expr $y1 + 10] [expr $x2 + 53] $y2 -fill lightgray -outline #1c79d9 -tags dbx -state hidden ]
    lappend all_elem3 $idx
    set idxv [.c2 create text [expr $x2 + 49] [expr $y2 + 20] -text $dxx -fill gray -font {-family menlo -size 9} -state hidden]
    lappend all_values3 $idxv
    }
    }
}

set all_elem4 {}

proc update_draw_tr {liste} {
  global graph2_rand
  global graph2_w
  global graph2_len
  global graph2_h
  global graph2_rect_size
  global all_elem4
  global all_values4
  global sf_dur_List
  global select_sf_addx

  set graph2_len [llength $liste]
  set graph2_max_y [get_List_max $liste]

  if {$select_sf_addx == "trx"} {

  for {set x 0} {$x < $graph2_len} {incr x} {
    set trx_val [lindex $liste $x]
    set idzz [lindex $all_elem4 $x]  
    set idyy [lindex $all_values4 $x]  
    set x1 [get_x $graph2_w $graph2_rand $graph2_len  [expr $x + 1]]
    .c2 itemconfigure $idzz -text $trx_val

    set durx [lindex $sf_dur_List $x]
    set durx1 [round_scaleval $durx 2]
    .c2 itemconfigure $idyy -text $durx1
    .c2 coords $idzz [list [expr $x1 + 4 + $graph2_rand] 80]
    .c2 coords $idyy [list [expr $x1 + 4 + $graph2_rand] 20]
  }
  }
}

proc draw_tr {liste} {
  global graph2_rand
  global graph2_w
  global graph2_h
  global graph2_rect_size
  global all_elem4
  global all_values4
  global sf_dur_List
  global trx_elem1
  global trx_elem2

  set graph2_len [llength $liste]
  set graph2_max_y [get_List_max $liste]

  set all_elem4 {}
  set all_values4 {}

  set trx_elem1 [.c2 create text 30 20 -text "dur:" -fill gray -font {-family menlo -size 9} -state hidden]
  set trx_elem2 [.c2 create text 33 80 -text "tr:" -fill gray -font {-family menlo -size 9} -state hidden]
  for {set x 0} {$x < $graph2_len} {incr x} {
    ;# x1 y1 x2 y2
    set pointy [lindex $liste $x]
    set x1 [get_x $graph2_w $graph2_rand $graph2_len $x]
    set y2 80
    set x2 [expr $x1 + $graph2_rect_size]
    set y1 80
    set trx [lindex $liste $x]
    if {$trx == ""} {} else {
    set idxv [.c2 create text [expr $x2 + 49] [expr $y2 + 20] -tags trx -text $trx -fill gray -font {-family menlo -size 13} -state hidden]
    lappend all_elem4 $idxv
    
    # display dur of sf after transp
    set durx [lindex $sf_dur_List $x]
    set durx1 [round_scaleval $durx 2]
    set idxy [.c2 create text [expr $x2 + 57] 20 -text $durx1 -fill gray -font {-family menlo -size 9} -state hidden]
    lappend all_values4 $idxy
    }}
}

proc refresCanvas2 {} {
  global select_sf_addx
  global all_elem2
  global all_elem3
  global all_elem4
  global all_values2
  global all_values3
  global all_values4
  global 0_dby_id
  global 0_dby_id2
  global dbx_elem1
  global dbx_elem2
  global trx_elem1
  global trx_elem2

  switch $select_sf_addx {
        "dx" {   
          foreach idx $all_elem2 { .c2 itemconfigure $idx -state normal}
          foreach idx $all_elem3 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_elem4 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_values2 { .c2 itemconfigure $idx -state normal}
          foreach idx $all_values3 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_values4 { .c2 itemconfigure $idx -state hidden}
          .c2 itemconfigure $0_dby_id -state hidden 
          .c2 itemconfigure $0_dby_id2 -state hidden

          .c2 itemconfigure $dbx_elem1 -state hidden
          .c2 itemconfigure $dbx_elem2 -state hidden

          .c2 itemconfigure $trx_elem1 -state hidden
          .c2 itemconfigure $trx_elem2 -state hidden
        }
        "dB0" {   
          foreach idx $all_elem2 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_elem3 { .c2 itemconfigure $idx -state normal}
          foreach idx $all_elem4 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_values2 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_values3 { .c2 itemconfigure $idx -state normal}
          foreach idx $all_values4 { .c2 itemconfigure $idx -state hidden}

          .c2 itemconfigure $0_dby_id -state normal 
          .c2 itemconfigure $0_dby_id2 -state normal

          .c2 itemconfigure $dbx_elem1 -state normal
          .c2 itemconfigure $dbx_elem2 -state normal

          .c2 itemconfigure $trx_elem1 -state hidden
          .c2 itemconfigure $trx_elem2 -state hidden

        }
        "trx" {   
          foreach idx $all_elem2 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_elem3 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_elem4 { .c2 itemconfigure $idx -state normal}
          foreach idx $all_values2 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_values3 { .c2 itemconfigure $idx -state hidden}
          foreach idx $all_values4 { .c2 itemconfigure $idx -state normal}
          .c2 itemconfigure $0_dby_id -state hidden 
          .c2 itemconfigure $0_dby_id2 -state hidden

          .c2 itemconfigure $dbx_elem1 -state hidden
          .c2 itemconfigure $dbx_elem2 -state hidden

          .c2 itemconfigure $trx_elem1 -state normal
          .c2 itemconfigure $trx_elem2 -state normal
        }
    }
}

#===========================================================================================
#
#
#                                      bind for .c
#
#
#===========================================================================================

proc test_id {id} {
  global selected
  set test [lsearch -inline $selected $id]
  return $test
 }

set pixeladdx 0

bind . <Configure> {
    if {"%W" eq [winfo toplevel %W]} {
        #puts "reconfigured %W: (%x,%y) %wx%h"
    set new_width [expr %w - 800 + 630]
    set new_hight [expr %h - 720 + 0]
    set pixeladdy [expr %h - 720 + 0]
    set pixeladdx [expr (%w - 800) / 20]
    set graph_w $new_width
  
    set graph2_w $new_width
    set graph_h [expr 300 + $pixeladdy ]
    .c configure -height [expr 300 + $pixeladdy ]
    #puts [expr 300 + $pixeladdy ]
    updateCanvas $new_width $pixeladdy
    updateCanvas2 $new_width
  
    place .c2 -x 20 -y [expr 430 + $pixeladdy] 
    place .rb1_x -x [expr 690 +  %w - 800] -y [expr 480 +  %h - 720];#480
    place .rb2_x -x [expr 690 +  %w - 800] -y [expr 510 +  %h - 720];#510
    place .rb3_x -x [expr 690 +  %w - 800] -y [expr 540 +  %h - 720];#540

    place .b_set_Color_List -x [expr 680 +  %w - 800] -y 240
    place .check_list_reps -x [expr 683 +  %w - 800] -y 180
    set addwidth [expr round((%w - 800) / 10)]
    place .enText_len -x [expr 680 +  %w - 800]  -y 210
    place .b_update_ut -x [expr 590 +  %w - 800] -y 77
    place .enText_seed -x [expr 660 +  %w - 800] -y 80
    place .lb_colorList_len -x [expr 680 +  %w - 800] -y 143
    place .check_open_sf -x [expr 660 +  %w - 800] -y [expr 675 +  %h - 720];#675
    place .b_evaluate -x [expr 450 +  %w - 800] -y [expr 668 +  %h - 720];#668
    place .b_empty_out -x [expr 640 +  %w - 800] -y [expr 628 +  %h - 720]
    place .b_open_sf -x [expr 560 +  %w - 800] -y [expr 668 +  %h - 720];#668
    place .b_open_script -x [expr 545 +  %w - 800] -y [expr 628 +  %h - 720];#628 
    place .b_open_console_txt -x [expr 440 +  %w - 800] -y [expr 628 +  %h - 720];#628 
    place .enText_outpath -x 100 -y [expr 668 +  %h - 720];#668 
    place .lb__outpath -x 20 -y [expr 670 +  %h - 720];#670
    place .mb_format -x 260 -y [expr 669 +  %h - 720];#669   
    place .lb_appname -x [expr 580 +  %w - 800] -y 5

    place .lb_info_key1  -x 24 -y [expr 590 +  %h - 720]
    place .lb_info_key2  -x 24 -y [expr 610 +  %h - 720]
    place .lb_info_key3  -x 24 -y [expr 630 +  %h - 720] 
    place .lb_info_key4  -x 24 -y [expr 650 +  %h - 720]

    }
}

.c bind name <Enter> {
    set id [.c find withtag current]
  .c itemconfigure $id -fill systemSelectedTextBackgroundColor 
}

.c bind name <Leave> {
    set id [.c find withtag current]
  .c itemconfigure $id -fill gray 
}

.c bind name <Double-1> {
   set id [.c find withtag current]
  set posx [find_all_elemX_pos $id $all_lines_txt_path]
  set pathx [lindex $sf_List $posx]
  exec open $pathx
}

.c bind sf <Enter> {
     set id [.c find withtag current]
   if {[lsearch $selected $id] < 0} {.c itemconfigure $id -fill systemSelectedTextBackgroundColor 

  set posx2 [find_all_elemX_pos $id $all_elem]
  switch $select_sf_addx {
    "dx"  {.c2 itemconfigure [lindex $all_elem2 $posx2] -fill systemSelectedTextBackgroundColor}
        "dB0" {.c2 itemconfigure [lindex $all_elem3 $posx2] -fill systemSelectedTextBackgroundColor}  
      "trx" {.c2 itemconfigure [lindex $all_elem4 $posx2] -fill systemSelectedTextBackgroundColor}
    }}
}

.c bind sf <Leave> {
     set id [.c find withtag current]
     if {[lsearch $selected $id] < 0} {.c itemconfigure $id -fill #1c79d9 -outline #1c79d9

  set posx2 [find_all_elemX_pos $id $all_elem]
  switch $select_sf_addx {
    "dx"  {.c2 itemconfigure [lindex $all_elem2 $posx2] -fill gray}
        "dB0" {.c2 itemconfigure [lindex $all_elem3 $posx2] -fill lightgray -outline #1c79d9}  
      "trx" {.c2 itemconfigure [lindex $all_elem4 $posx2] -fill gray}
    }
   }
}

.c bind sf <ButtonPress-1> {
  foreach idx $all_elem2 {.c2 itemconfigure $idx -fill gray -outline gray}
     set id [.c find withtag current]
     set selected $id
   set posx [dict get $id_data $id]
   if {[string is double -strict $posx] == 1} {
     set pathx [lindex $sf_List $posx]
     }

     foreach idx $all_elem {
     if {$selected == $idx } {.c itemconfigure $idx -fill red -outline red; set x2 180} else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
     }

  set posx2 [find_all_elemX_pos $id $all_elem]

  set selected1 [lindex $all_elem2 $posx2]
  foreach idx2 $all_elem2 {
           if {$selected1 == $idx2 } {.c2 itemconfigure $idx2 -fill red -outline red} else {.c2 itemconfigure $idx2 -fill gray -outline gray}
           }    
  set selected2 [lindex $all_elem3 $posx2]
  foreach idx3 $all_elem3 {
           if {$selected2 == $idx3 } {.c2 itemconfigure $idx3 -fill red -outline red} else {.c2 itemconfigure $idx3 -fill lightgray -outline #1c79d9}
           }
        
  set selected3 [lindex $all_elem4 $posx2]
  foreach idx4 $all_elem4 {
           if {$selected3 == $idx4 } {.c2 itemconfigure $idx4 -fill red} else {.c2 itemconfigure $idx4 -fill gray}
           }
}

.c bind sf <Shift-ButtonPress-1> {
    set id [.c find withtag current]
    if {[lsearch $selected $id] < 0} {lappend selected $id}
  foreach idx $all_elem {
        if {[lsearch $selected $idx] > -1} {.c itemconfigure $idx -fill red -outline red} else {
                  .c itemconfigure $idx -fill #1c79d9 -outline #1c79d9
                  }
  }

  switch $select_sf_addx {
        "dx" {  
      set selected1 {}
      foreach idx $selected {
      set posxx [find_all_elemX_pos $idx $all_elem]
      set idx1 [lindex $all_elem2 $posxx]
      lappend selected1 $idx1
         .c2 itemconfigure $idx1 -fill red -outline red

      set idx2 [lindex $all_elem3 $posxx]
      lappend selected2 $idx2
        .c2 itemconfigure $idx2 -fill red -outline red

      set idx3 [lindex $all_elem4 $posxx]
      lappend selected3 $idx3
        .c2 itemconfigure $idx3 -fill red

      }
    }

        "dB0" {  
      set selected2 {}
      foreach idx $selected {
      set posxx [find_all_elemX_pos $idx $all_elem]
      set idx2 [lindex $all_elem3 $posxx]
      lappend selected2 $idx2
         .c2 itemconfigure $idx2 -fill red -outline red

      set idx1 [lindex $all_elem2 $posxx]
      lappend selected1 $idx1
        .c2 itemconfigure $idx1 -fill red -outline red

      set idx3 [lindex $all_elem4 $posxx]
      lappend selected3 $idx3
        .c2 itemconfigure $idx3 -fill red

      }

    }
        "trx" {  
      set selected3 {}
      foreach idx $selected {
      set posxx [find_all_elemX_pos $idx $all_elem]
      set idx3 [lindex $all_elem4 $posxx]
      lappend selected3 $idx3
         .c2 itemconfigure $idx3 -fill red

      set idx1 [lindex $all_elem2 $posxx]
      lappend selected1 $idx1
        .c2 itemconfigure $idx1 -fill red -outline red

      set idx2 [lindex $all_elem3 $posxx]
      lappend selected2 $idx2
        .c2 itemconfigure $idx2 -fill red -outline red
      }
    }
  }
}

bind . <KeyPress-o> {
  if { $selected != ""} {
    if {[llength $selected] > 1} {
            set selected [lindex $selected 0]
            foreach idx $all_elem {
               if {$idx == $selected} {.c itemconfigure $idx -fill red -outline red} else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9 }
            }
         }
    set posx [dict get $id_data $selected]
    if {[string is double -strict $posx] == 1} {
        set pathx [lindex $sf_List $posx]
        set posxx [find_all_elemX_pos $selected $all_elem]
        set trx [lindex $sf_transp_List $posxx]
        set speedx [expr pow(2.0,($trx / 12.0))]
        set mulx [lindex $sf_mul_List $posxx]
        set durx [lindex $sf_dur_List $posxx]
        set pathnamex [file rootname [file tail $pathx]]
        set formatx [file extension $pathx]
        set speedx2 [round_scaleval $speedx 2]
        set addstr "_speed=$speedx2"
        set addstr1 "_gain$mulx"
        set outpathx [file join "$curr_Dir/out" "$pathnamex$addstr$addstr1$formatx"]
        set csdpathx [file join "$curr_Dir/out" "$pathnamex$addstr$addstr1.csd"]
        eval_single_Csound $pathx $durx $trx $mulx $outpathx $csdpathx
        }
  }  else {bell}
}

# click in space...
set sel_rectx 0
set sel_recty 0
set sel_rectx2 0
set sel_recty2 0

# create 1 window once!
set sel_rect_id [.c create rectangle 0 0 0 0 -fill "white smoke" -outline lightgray]

bind .c <ButtonPress-1> {
  set sel_rectx %x
  set sel_recty %y
  set sel_rectx2 %x
  set sel_recty2 %y  

set id [.c find withtag current]
if {$id == ""} { 
  foreach idx  $all_elem {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
  set selected {}
  set selected1 {}
  set selected2 {}
  set selected3 {}
  foreach idx2  $all_elem2 {.c2 itemconfigure $idx2 -fill gray -outline gray}
  foreach idx3  $all_elem3 {.c2 itemconfigure $idx3 -fill lightgray -outline #1c79d9}
  foreach idx4  $all_elem4 {.c2 itemconfigure $idx4 -fill gray}
  }
}

bind .c <B1-Motion> { set sel_rectx2 %x
            set sel_recty2 %y  
          .c coords $sel_rect_id [list $sel_rectx $sel_recty %x %y]  
}

bind .c <ButtonRelease> {
  if {[llength $selected] == 0} {
  set selected {}
  set pos_selected {}
  set liste_x [lsort -integer [list $sel_rectx $sel_rectx2]]
  set liste_y [lsort -integer [list $sel_recty $sel_recty2]]

  foreach idx $all_elem { 
    set coordsx [.c coords $idx]
    set x [expr  [lindex $coordsx 0] + ($graph_rect_size / 2)] 
    set y [expr  [lindex $coordsx 1] + ($graph_rect_size / 2)]  
    
    if { $x >= [lindex $liste_x 0] &&  $x <= [lindex $liste_x 1] && $y >= [lindex $liste_y 0] && $y <= [lindex $liste_y 1]} {
      lappend selected $idx
      lappend pos_selected [find_all_elemX_pos $idx $all_elem]
      .c itemconfigure $idx -fill red -outline red
        } else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
  }
  
  set sel_rectx %x
  set sel_recty %y
  .c coords $sel_rect_id [list 0 0 0 0]

  if {$selected != ""} {  
              set selected1 {}
              foreach idx $all_elem2 {
              set posx [find_all_elemX_pos $idx $all_elem2]
              if {[lsearch $pos_selected $posx] > -1} {
                  lappend selected1 $idx
                  .c2 itemconfigure $idx -fill red -outline red} else {
                  .c2 itemconfigure $idx -fill gray -outline gray
                  } 
              }
              set selected2 {}
              foreach idx $all_elem3 {
              set posx [find_all_elemX_pos $idx $all_elem3]
              if {[lsearch $pos_selected $posx] > -1} {
                  lappend selected2 $idx
                  .c2 itemconfigure $idx -fill red -outline red} else {
                  .c2 itemconfigure $idx -fill lightgray -outline #1c79d9
                  } 
              }
              set selected3 {}
              foreach idx $all_elem4 {
              set posx [find_all_elemX_pos $idx $all_elem4]
              if {[lsearch $pos_selected $posx] > -1} {
                  lappend selected3 $idx
                  .c2 itemconfigure $idx -fill red} else {
                  .c2 itemconfigure $idx -fill gray
                  } 
                }
              }
            }
}

#===========================================================================================
#
#
#                                      bind for .c2
#
#
#===========================================================================================

proc find_all_elemX_pos {id elem_liste} {
  set x 0
  set res {}
  foreach idx $elem_liste {
  if {$idx == $id} {set res $x}
  incr x
  }
  return $res
}

# click in space...
set sel2_rectx 0
set sel2_recty 0
set sel2_rectx2 0
set sel2_recty2 0

bind .c2 <ButtonPress-1> {  
  set sel2_rectx %x
  set sel2_recty %y
  set sel2_rectx2 %x
  set sel2_recty2 %y  

  set id [.c2 find withtag current]

  if {$id == ""} {
        foreach idx  $all_elem2 {.c2 itemconfigure $idx -fill gray -outline gray}
        foreach idx  $all_elem3 {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
        foreach idx  $all_elem4 {.c2 itemconfigure $idx -fill gray}

        set selected1 {}
        set selected2 {}
        set selected3 {}
        foreach idx  $all_elem {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
        } else {   
            # select when id = t
            switch $select_sf_addx {
                "dx" { 
                    set selected1 $id
                  foreach idx $all_elem2 { 
                   if {$selected1 == $idx } {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}
                   }

                  set posx [find_all_elemX_pos $id $all_elem2]

                  set selected2 [lindex $all_elem3 $posx]
                  foreach idx $all_elem3 { 
                   if {$selected2 == $idx } {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
                   }

                  set selected3 [lindex $all_elem4 $posx]
                  foreach idx $all_elem4 { 
                   if {$selected3 == $idx } {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}
                   }

                  }
                    "dB0" { 
                    set selected2 $id
                  foreach idx $all_elem3 { 
                   if {$selected2 == $idx } {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
                   }
                  set posx [find_all_elemX_pos $id $all_elem3]

                  set selected1 [lindex $all_elem2 $posx]
                  foreach idx $all_elem2 { 
                   if {$selected1 == $idx } {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}
                   }

                  set selected3 [lindex $all_elem4 $posx]
                  foreach idx $all_elem4 { 
                   if {$selected3 == $idx } {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}
                   }
                  }

                  "trx" { 
                    set selected3 $id
                  foreach idx $all_elem4 { 
                   if {$selected3 == $idx } {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}
                   }
                  set posx [find_all_elemX_pos $id $all_elem4]

                    set selected1 [lindex $all_elem2 $posx]
                  foreach idx $all_elem2 { 
                   if {$selected1 == $idx } {.c2 itemconfigure $idx -fill red -outline red} else {.c2 itemconfigure $idx -fill gray -outline gray}
                   }

                  set selected2 [lindex $all_elem3 $posx]
                  foreach idx $all_elem3 { 
                   if {$selected2 == $idx } {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
                   }
                  }
                }

                set selected [lindex $all_elem $posx]
                   foreach idx $all_elem { 
                if {$selected == $idx } {.c itemconfigure $idx -fill red -outline red} else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
                 }

              }
}

bind .c2 <Shift-ButtonPress-1> {  
  set sel2_rectx %x
  set sel2_recty %y
  set sel2_rectx2 %x
  set sel2_recty2 %y  
  set id [.c2 find withtag current]
  # no selection:
  if {$id == ""} {
        foreach idx  $all_elem2 {.c2 itemconfigure $idx -fill gray -outline gray}
        foreach idx  $all_elem3 {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
        foreach idx  $all_elem4 {.c2 itemconfigure $idx -fill gray}
        set selected1 {}
        set selected2 {}
        set selected3 {}
        foreach idx $all_elem {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
        } else {
  # selection:          
  switch $select_sf_addx {
        "dx" {   
            lappend selected1 $id
            .c2 itemconfigure $id -fill red -outline red
            set posxx [find_all_elemX_pos $id $all_elem2]
            set idx2 [lindex $all_elem3 $posxx]
            lappend selected2 $idx2
            .c2 itemconfigure $idx2 -fill red -outline red
            set idx3 [lindex $all_elem4 $posxx]
            lappend selected3 $idx3
            .c2 itemconfigure $idx3 -fill red
        }
        "dB0" {
            lappend selected2 $id
            .c2 itemconfigure $id -fill red -outline red
            set posxx [find_all_elemX_pos $id $all_elem3]
            set idx1 [lindex $all_elem2 $posxx]
            lappend selected1 $idx1
            .c2 itemconfigure $idx1 -fill red -outline red
            set idx3 [lindex $all_elem4 $posxx]
            lappend selected3 $idx3
            .c2 itemconfigure $idx3 -fill red

        }
        "trx" {       
            lappend selected3 $id
            .c2 itemconfigure $id -fill red
            set posxx [find_all_elemX_pos $id $all_elem4]
            set idx1 [lindex $all_elem2 $posxx]
            lappend selected1 $idx1
            .c2 itemconfigure $idx1 -fill red -outline red
            set idx2 [lindex $all_elem3 $posxx]
            lappend selected2 $idx2
            .c2 itemconfigure $idx2 -fill red -outline red
        }
      }
            set idxx [lindex $all_elem $posxx]
            lappend selected $idxx
            .c itemconfigure $idxx -fill red -outline red          
        }          
}

bind .c2 <B1-Motion> { set sel2_rectx2 %x
            set sel2_recty2 %y  
          .c2 coords $sel2_rect_id [list $sel2_rectx $sel2_recty %x %y]            
}

bind .c2 <ButtonRelease> {
  if { [.c2 coords $sel2_rect_id] != {0.0 0.0 0.0 0.0} } {
  set selected1 {}
  set selected2 {}
  set selected3 {}
  set pos2_selected {}
  set liste_x [lsort -integer [list $sel2_rectx $sel2_rectx2]]
  set liste_y [lsort -integer [list $sel2_recty $sel2_recty2]]

  switch $select_sf_addx {
        "dx" {   
            foreach idx $all_elem2 { 
              set coordsx [.c2 coords $idx]
              set x [lindex $coordsx 0] 
              set y [lindex $coordsx 1]
              if { $x >= [lindex $liste_x 0] &&  $x <= [lindex $liste_x 1]} {
                lappend selected1 $idx
                lappend pos2_selected [find_all_elemX_pos $idx $all_elem2]
                .c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}
            }
            foreach idx $all_elem3 {   set posx [find_all_elemX_pos $idx $all_elem3]
                          if {[lsearch $pos2_selected $posx] > -1} {lappend selected2 $idx
                          .c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
                          }
            foreach idx $all_elem4 {   set posx [find_all_elemX_pos $idx $all_elem4]
                          if {[lsearch $pos2_selected $posx] > -1} {lappend selected3 $idx
                          .c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}
                          }
          }
    
        "dB0" { 
            foreach idx $all_elem3 { 
              set coordsx [.c2 coords $idx]
              set x [lindex $coordsx 0] 
              set y [lindex $coordsx 1]
              if { $x >= [lindex $liste_x 0] &&  $x <= [lindex $liste_x 1] && $y >= [lindex $liste_y 0] && $y <= [lindex $liste_y 1]} {
                lappend selected2 $idx
                lappend pos2_selected [find_all_elemX_pos $idx $all_elem3]
                .c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
                }
            foreach idx $all_elem2 {   set posx [find_all_elemX_pos $idx $all_elem2]
                          if {[lsearch $pos2_selected $posx] > -1} {lappend selected1 $idx
                          .c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}
                          }
            foreach idx $all_elem4 {   set posx [find_all_elemX_pos $idx $all_elem4]
                          if {[lsearch $pos2_selected $posx] > -1} {lappend selected3 $idx
                          .c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}
                          }
          }
        "trx" { 
            foreach idx $all_elem4 { 
              set coordsx [.c2 coords $idx]
              set x [lindex $coordsx 0] 
              set y [lindex $coordsx 1]
              if { $x >= [lindex $liste_x 0] &&  $x <= [lindex $liste_x 1] && $y >= [lindex $liste_y 0] && $y <= [lindex $liste_y 1]} {
                lappend selected3 $idx
                lappend pos2_selected [find_all_elemX_pos $idx $all_elem4]
                .c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}
              }

            foreach idx $all_elem2 {   set posx [find_all_elemX_pos $idx $all_elem2]
                          if {[lsearch $pos2_selected $posx] > -1} {lappend selected1 $idx
                          .c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}
                          }
            foreach idx $all_elem3 {   set posx [find_all_elemX_pos $idx $all_elem3]
                          if {[lsearch $pos2_selected $posx] > -1} {lappend selected2 $idx
                          .c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}
                          }
            }
      }

  set sel2_rectx %x
  set sel2_recty %y
  .c2 coords $sel2_rect_id [list 0 0 0 0] 

  # select also elem in win c
  set selected {}
  foreach idx $all_elem {
  set posx [find_all_elemX_pos $idx $all_elem]
  if {[lsearch $pos2_selected $posx] > -1} {
  lappend selected $idx
  .c itemconfigure $idx -fill red -outline red} else {
  .c itemconfigure $idx -fill #1c79d9 -outline #1c79d9
  } 
  }
  }
}

#-------------
# dx tag binds:
#-------------

.c2 bind dx <Enter> {
    if {$select_sf_addx == "dx"} {
    set id [.c2 find withtag current]
  if {[lsearch $selected1 $id] < 0} {
    .c2 itemconfigure $id -fill systemSelectedTextBackgroundColor
    set posx [find_all_elemX_pos $id $all_elem2]
    .c itemconfigure [lindex $all_elem $posx] -fill systemSelectedTextBackgroundColor
  }}
}

.c2 bind dx <Leave> {
  if {$select_sf_addx == "dx"} {
    set id [.c2 find withtag current]
    if {[lsearch $selected1 $id] < 0} {
    .c2 itemconfigure $id -fill gray -outline gray
    set posx [find_all_elemX_pos $id $all_elem2]
    .c itemconfigure [lindex $all_elem $posx] -fill #1c79d9 -outline #1c79d9  
  }}
}

#-------------
# dbx tag binds:
#-------------

.c2 bind dbx <Enter> {
  if {$select_sf_addx == "dB0"} {
    set id [.c2 find withtag current]
  if {[lsearch $selected2 $id] < 0} {
    .c2 itemconfigure $id -fill systemSelectedTextBackgroundColor
    set posx [find_all_elemX_pos $id $all_elem3]
    .c itemconfigure [lindex $all_elem $posx] -fill systemSelectedTextBackgroundColor
  }}
}

.c2 bind dbx <Leave> {
  if {$select_sf_addx == "dB0"} {
    set id [.c2 find withtag current]
    if {[lsearch $selected2 $id] < 0} {
    .c2 itemconfigure $id -fill lightgray -outline #1c79d9
    set posx [find_all_elemX_pos $id $all_elem3]
    .c itemconfigure [lindex $all_elem $posx] -fill #1c79d9 -outline #1c79d9  
  }}
}

#-------------
# trx tag binds:
#-------------

.c2 bind trx <Enter> {
  if {$select_sf_addx == "trx"} {
    set id [.c2 find withtag current]
  if {[lsearch $selected3 $id] < 0} {
    .c2 itemconfigure $id -fill systemSelectedTextBackgroundColor
    set posx [find_all_elemX_pos $id $all_elem4]
    .c itemconfigure [lindex $all_elem $posx] -fill systemSelectedTextBackgroundColor
  }}
}

.c2 bind trx <Leave> {
  if {$select_sf_addx == "trx"} {
    set id [.c2 find withtag current]
    if {[lsearch $selected3 $id] < 0} {
    .c2 itemconfigure $id -fill gray
    set posx [find_all_elemX_pos $id $all_elem4]
    .c itemconfigure [lindex $all_elem $posx] -fill #1c79d9 -outline #1c79d9  
  }}
}

#===========================================================================================
#
#
#                                      bind for .
#
#
#===========================================================================================

bind . <Command-a> {
  set selected $all_elem
  foreach idx $all_elem {
     .c itemconfigure $idx -fill red -outline red
     }
  set selected1 $all_elem2
  foreach idx  $all_elem2 {.c2 itemconfigure $idx -fill red -outline red} 
  set selected2 $all_elem3
  foreach idx  $all_elem3 {.c2 itemconfigure $idx -fill red -outline red}
  set selected3 $all_elem4
  foreach idx  $all_elem4 {.c2 itemconfigure $idx -fill red}     
}

bind . <Escape> {
  set selected {}
  set selected1 {}
  set selected2 {}
  set selected3 {}
  foreach idx $all_elem {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}
  switch $select_sf_addx {
                "dB0" {  foreach idx  $all_elem3 {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}}
              "trx" { foreach idx  $all_elem4 {.c2 itemconfigure $idx -fill gray}}
              "dx"  {foreach idx  $all_elem2 {.c2 itemconfigure $idx -fill gray -outline gray}}
  }
}

bind . <KeyPress-0> {
  if {$select_sf_addx == "dx" && $selected1 != ""} {  
                  foreach idx $all_elem2 {
                  if {[lsearch $selected1 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem2]
                  set dxList [lreplace $dxList $posx $posx 1]
                  }}
                  update_draw_dx  $dxList
                  }
  if {$select_sf_addx == "dB0" && $selected2 != ""} {  
                  foreach idx $all_elem3 {
                  if {[lsearch $selected2 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem3]
                  set sf_mul_List [lreplace $sf_mul_List $posx $posx 0]
                  }}
                  update_draw_db $sf_mul_List
                  }
  if {$select_sf_addx == "trx" && $selected3 != ""} {  
                  foreach idx $all_elem4 {
                  if {[lsearch $selected3 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem4]
                  set sf_transp_List [lreplace $sf_transp_List $posx $posx 0]
                  }}
                  update_sf_dur_List
                  update_draw_tr $sf_transp_List
                  }  
}

bind . <KeyPress-KP_0> {
  if {$select_sf_addx == "dx" && $selected1 != ""} {  
                  foreach idx $all_elem2 {
                  if {[lsearch $selected1 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem2]
                  set dxList [lreplace $dxList $posx $posx 1]
                  }}
                  update_draw_dx  $dxList
                  }
  if {$select_sf_addx == "dB0" && $selected2 != ""} {  
                  foreach idx $all_elem3 {
                  if {[lsearch $selected2 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem3]
                  set sf_mul_List [lreplace $sf_mul_List $posx $posx 0]
                  }}
                  update_draw_db $sf_mul_List
                  }
  if {$select_sf_addx == "trx" && $selected3 != ""} {  
                  foreach idx $all_elem4 {
                  if {[lsearch $selected3 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem4]
                  set sf_transp_List [lreplace $sf_transp_List $posx $posx 0]
                  }}
                  update_sf_dur_List
                  update_draw_tr $sf_transp_List
                  }  
}

bind . <KeyPress-Left> {
  if {$selected != "" } {
      set pos2_selected {}
      set pos_minimum [llength $all_elem] 
      foreach idx $selected { set posx [find_all_elemX_pos $idx $all_elem]
                  if {$posx < $pos_minimum} {set pos_minimum $posx}
                  lappend pos2_selected [find_all_elemX_pos $idx $all_elem]
                  }
      if   {$pos_minimum > 0} {
                  set selected {}
                  set selected1 {}
                  set selected2 {}
                  set selected3 {}
                  foreach posxx $pos2_selected {
                    set posxx2 [expr $posxx - 1]
                    lappend selected [lindex $all_elem $posxx2]
                    lappend selected1 [lindex $all_elem2 $posxx2]
                    lappend selected2 [lindex $all_elem3 $posxx2]
                    lappend selected3 [lindex $all_elem4 $posxx2]
                  }
                  foreach idx $all_elem  { if {[lsearch $selected $idx] > -1}  {.c itemconfigure $idx -fill red -outline red } else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}}
                  foreach idx $all_elem2 { if {[lsearch $selected1 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}}
                  foreach idx $all_elem3 { if {[lsearch $selected2 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}}
                  foreach idx $all_elem4 { if {[lsearch $selected3 $idx] > -1} {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}}
                  set pos2_selected {}     
      } else {bell}
  }
}

bind . <KeyPress-Right> {
  if {$selected != "" } {
      set pos2_selected {}
      set pos_maximum 0 

      foreach idx $selected { set posx [find_all_elemX_pos $idx $all_elem]
                  if {$posx > $pos_maximum} {set pos_maximum $posx}
                  lappend pos2_selected [find_all_elemX_pos $idx $all_elem]
                  }
      if {$select_sf_addx == "dx"} { set border_rmx_val 2} else { set border_rmx_val 1}
      set border_val [expr [llength $all_elem] - $border_rmx_val]
      if   {$pos_maximum < $border_val} {
                  set selected {}
                  set selected1 {}
                  set selected2 {}
                  set selected3 {}
                  foreach posxx $pos2_selected {
                    set posxx2 [expr $posxx + 1]
                    lappend selected [lindex $all_elem $posxx2]
                    set dx_elem [lindex $all_elem2 $posxx2]
                    if {$dx_elem != ""} {lappend selected1 $dx_elem}
                    lappend selected2 [lindex $all_elem3 $posxx2]
                    lappend selected3 [lindex $all_elem4 $posxx2]
                  }
                  foreach idx $all_elem  { if {[lsearch $selected $idx] > -1}  {.c itemconfigure $idx -fill red -outline red } else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}}
                  foreach idx $all_elem2 { if {[lsearch $selected1 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}}
                  foreach idx $all_elem3 { if {[lsearch $selected2 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}}
                  foreach idx $all_elem4 { if {[lsearch $selected3 $idx] > -1} {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}}
                  set pos2_selected {}     
      } else {bell}
  }
}

bind . <Shift-Key-Left> {
  if {$selected != "" } {
      set pos2_selected {}
      set pos_minimum [llength $all_elem] 
      foreach idx $selected { set posx [find_all_elemX_pos $idx $all_elem]
                  if {$posx < $pos_minimum} {set pos_minimum $posx}
                  lappend pos2_selected [find_all_elemX_pos $idx $all_elem]
                  }
      if   {$pos_minimum > 0} {

                  foreach posxx $pos2_selected {
                    set posxx2 [expr $posxx - 1]
                    lappend selected  [lindex $all_elem $posxx2 ]
                    lappend selected1 [lindex $all_elem2 $posxx2]
                    lappend selected2 [lindex $all_elem3 $posxx2]
                    lappend selected3 [lindex $all_elem4 $posxx2]
                  }
                  set selected  [lsort -unique -integer $selected ]
                  set selected1 [lsort -unique -integer $selected1]
                  set selected2 [lsort -unique -integer $selected2]
                  set selected3 [lsort -unique -integer $selected3]
                  foreach idx $all_elem  { if {[lsearch $selected $idx] > -1}  {.c itemconfigure $idx -fill red -outline red } else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}}
                  foreach idx $all_elem2 { if {[lsearch $selected1 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}}
                  foreach idx $all_elem3 { if {[lsearch $selected2 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}}
                  foreach idx $all_elem4 { if {[lsearch $selected3 $idx] > -1} {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}}
                  set pos2_selected {}     
      } else {bell}
  }
}

bind . <Shift-Key-Right> {
  if {$selected != "" } {
      set pos2_selected {}
      set pos_maximum 0 
      foreach idx $selected { set posx [find_all_elemX_pos $idx $all_elem]
                  if {$posx > $pos_maximum} {set pos_maximum $posx}
                  lappend pos2_selected [find_all_elemX_pos $idx $all_elem]
                  }
      if {$select_sf_addx == "dx"} { set border_rmx_val 2} else { set border_rmx_val 1}
      set border_val [expr [llength $all_elem] - $border_rmx_val]
      if   {$pos_maximum < $border_val} {
                  foreach posxx $pos2_selected {
                    set posxx2 [expr $posxx + 1]
                    lappend selected [lindex $all_elem $posxx2]
                    set dx_elem [lindex $all_elem2 $posxx2]
                    if {$dx_elem != ""} {lappend selected1 $dx_elem}
                    lappend selected2 [lindex $all_elem3 $posxx2]
                    lappend selected3 [lindex $all_elem4 $posxx2]
                  }
                  set selected  [lsort -unique -integer $selected ]
                  set selected1 [lsort -unique -integer $selected1]
                  set selected2 [lsort -unique -integer $selected2]
                  set selected3 [lsort -unique -integer $selected3]
                  foreach idx $all_elem  { if {[lsearch $selected $idx] > -1}  {.c itemconfigure $idx -fill red -outline red } else {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}}
                  foreach idx $all_elem2 { if {[lsearch $selected1 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill gray -outline gray}}
                  foreach idx $all_elem3 { if {[lsearch $selected2 $idx] > -1} {.c2 itemconfigure $idx -fill red -outline red } else {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}}
                  foreach idx $all_elem4 { if {[lsearch $selected3 $idx] > -1} {.c2 itemconfigure $idx -fill red } else {.c2 itemconfigure $idx -fill gray}}
                  set pos2_selected {}     
      } else {bell}
  }
}

bind . <Key-Up> {
  if {$select_sf_addx == "dx" && $selected1 != ""} {  
                  foreach idx $all_elem2 {
                  if {[lsearch $selected1 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem2]
                  set newval [lindex $dxList $posx]
                  set dxList [lreplace $dxList $posx $posx [expr $newval + 1]]
                  }
                  }
                  update_draw_dx $dxList
                  update_tempox $dur_sec
                  }  
  if {$select_sf_addx == "dB0" && $selected2 != ""} {  
                  foreach idx $all_elem3 {
                  if {[lsearch $selected2 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem3]
                  set newval [lindex $sf_mul_List $posx]
                  if {$newval < 0} {set sf_mul_List [lreplace $sf_mul_List $posx $posx [expr $newval + 1]] } 
                  }
                  }
                  update_draw_db $sf_mul_List
                  }    
  if {$select_sf_addx == "trx" && $selected3 != ""} {  
                  foreach idx $all_elem4 {
                  if {[lsearch $selected3 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem4]
                  set newval [lindex $sf_transp_List $posx]
                  set sf_transp_List [lreplace $sf_transp_List $posx $posx [expr $newval + 1]]
                  }
                  }
                  update_sf_dur_List
                  update_draw_tr $sf_transp_List
                  }            
}

bind . <Key-Down> {
  if {$select_sf_addx == "dx" && $selected1 != ""} {  
                  foreach idx $all_elem2 {
                  if {[lsearch $selected1 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem2]
                  set newval [lindex $dxList $posx]
                  if {$newval > 1} {set dxList [lreplace $dxList $posx $posx [expr $newval - 1]] } 
                  }
                  }
                  update_draw_dx $dxList
                  update_tempox $dur_sec
                  }  
  if {$select_sf_addx == "dB0" && $selected2 != ""} {  
                  
                  foreach idx $all_elem3 {
                  if {[lsearch $selected2 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem3]
                  set newval [lindex $sf_mul_List $posx]
                  if {$newval > -80} {set sf_mul_List [lreplace $sf_mul_List $posx $posx [expr $newval - 1]] } 
                  }
                  }
                  update_draw_db $sf_mul_List
                  }
  if {$select_sf_addx == "trx" && $selected3 != ""} {  
                  foreach idx $all_elem4 {
                  if {[lsearch $selected3 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem4]
                  set newval [lindex $sf_transp_List $posx]
                  set sf_transp_List [lreplace $sf_transp_List $posx $posx [expr $newval - 1]]
                  }
                  }
                  update_sf_dur_List
                  update_draw_tr $sf_transp_List
                  }
}

bind . <Shift-Key-Up> {
  if {$select_sf_addx == "dx" && $selected1 != ""} {  
                  foreach idx $all_elem2 {
                  if {[lsearch $selected1 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem2]
                  set newval [lindex $dxList $posx]
                  set dxList [lreplace $dxList $posx $posx [expr $newval + 10]]
                  }
                  }
                  update_draw_dx $dxList
                  update_tempox $dur_sec
                  }  
  if {$select_sf_addx == "dB0" && $selected2 != ""} {  
                  foreach idx $all_elem3 {
                  if {[lsearch $selected2 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem3]
                  set newval [lindex $sf_mul_List $posx]
                  if {$newval < -9} {set sf_mul_List [lreplace $sf_mul_List $posx $posx [expr $newval + 10]] } else {set sf_mul_List [lreplace $sf_mul_List $posx $posx 0]}
                  }
                  }
                  update_draw_db $sf_mul_List
                  }    
  if {$select_sf_addx == "trx" && $selected3 != ""} {  
                  foreach idx $all_elem4 {
                  if {[lsearch $selected3 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem4]
                  set newval [lindex $sf_transp_List $posx]
                  set sf_transp_List [lreplace $sf_transp_List $posx $posx [expr $newval + 12]]
                  }
                  }
                  update_sf_dur_List
                  update_draw_tr $sf_transp_List
                  }    

}

bind . <Shift-Key-Down> {
  if {$select_sf_addx == "dx" && $selected1 != ""} {  
                  foreach idx $all_elem2 {
                  if {[lsearch $selected1 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem2]
                  set newval [lindex $dxList $posx]
                  if {$newval > 10} {set dxList [lreplace $dxList $posx $posx [expr $newval - 10]] } else {set dxList [lreplace $dxList $posx $posx 1]}
                  }
                  }
                  update_draw_dx $dxList
                  update_tempox $dur_sec
                  }  
  if {$select_sf_addx == "dB0" && $selected2 != ""} {  
                  
                  foreach idx $all_elem3 {
                  if {[lsearch $selected2 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem3]
                  set newval [lindex $sf_mul_List $posx]
                  if {$newval > -71} {set sf_mul_List [lreplace $sf_mul_List $posx $posx [expr $newval - 10]] } else {set sf_mul_List [lreplace $sf_mul_List $posx $posx -80]}
                  }
                  }
                  update_draw_db $sf_mul_List
                  }
  if {$select_sf_addx == "trx" && $selected3 != ""} {  
                  foreach idx $all_elem4 {
                  if {[lsearch $selected3 $idx] > -1} {
                  set posx [find_all_elemX_pos $idx $all_elem4]
                  set newval [lindex $sf_transp_List $posx]
                  set sf_transp_List [lreplace $sf_transp_List $posx $posx [expr $newval - 12]]
                  }
                  }
                  update_sf_dur_List
                  update_draw_tr $sf_transp_List
                  }
}

#========================================================================================================
#
#
#
#                                                    Csound
#
#
#
#========================================================================================================

proc make_single_csound_score {the_sf_Path durx transpx mulx outpathx} {
  set str_coll [format "i1 %8.3f %10s %3.0f %5.1f \"%10s\"\n" 0 $durx $transpx $mulx $the_sf_Path]
  set str_res [format "
<CsoundSynthesizer>
<CsOptions>
-o %s
</CsOptions>
<CsInstruments>

sr   =   44100
ksmps   =   32
nchnls   =   2  

0dbfs = 1

instr 1

itransp = p4
imul = ampdbfs(p5)
Sfilepath = p6

ichn filenchnls Sfilepath
ispeed = powoftwo(itransp / 12)

if ichn == 2 then
aL, aR diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul ,aR*imul
else
aL diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul, aL*imul
endif
  endin
</CsInstruments>

<CsScore>
%s
e
</CsScore>
</CsoundSynthesizer>" "\"$outpathx\"" $str_coll]

return $str_res
}

proc eval_single_Csound {the_sf_Path durx transpx mulx outpathx csdpathx} {
    global csound_terminal_path
    global temp_console_out
    global curr_Dir

    set test [file exist "$curr_Dir/out/"]
    if {$test == 0} { 
                      set mkdir_path "$curr_Dir/out/"
                      exec mkdir -p $mkdir_path
                    }
    set temp_csound_str [make_single_csound_score $the_sf_Path $durx $transpx $mulx $outpathx]
    write_file $temp_csound_str $csdpathx
    puts "$csound_terminal_path $csdpathx"
    set test_catch [catch [exec $csound_terminal_path --logfile=$temp_console_out $csdpathx]]
    if {$test_catch == 0} {exec open $outpathx }
}

proc make_csound_score {} {
  global dur_sec
  global dxList
  global sf_List
  global colorList
  global curr_Dir
  global outpath
  global out_format
  global sf_dur_List
  global sf_mul_List
  global sf_transp_List

  set the_sf_Path [file join "$curr_Dir/out" "$outpath.$out_format"]
  set graph_len [get_graph_len]
  set puls_sum [ladd $dxList]

  set dur_fact [expr $dur_sec * 1.0 / $puls_sum]
  set len_SF [llength $sf_List]
  set str_coll {}
  set txList [mk_onsetList]

  for {set x 0} {$x < $graph_len} {incr x} {
  set y_val [lindex $colorList $x]
  set pathx [lindex $sf_List $y_val] 

  if {$y_val < $len_SF} {
      set tx0 [lindex $txList $x]
      set tx1 [expr $dur_fact * $tx0]
      set tx [round_scaleval $tx1 3]
      set durx [lindex $sf_dur_List $x]
      set mulx [lindex $sf_mul_List $x]
      set transpx [lindex $sf_transp_List $x]
      ;#append str_coll "i1 $tx $durx $mulx  $transp_midi \"$pathx\"\n"
      append str_coll [format "i1 %8.3f %10s %3.0f %5.1f \"%10s\"\n" $tx $durx $transpx $mulx $pathx]
    }}

  set str_res [format "
<CsoundSynthesizer>
<CsOptions>
-o %s
</CsOptions>
<CsInstruments>

sr   =   44100
ksmps   =   32
nchnls   =   2  

0dbfs = 1

instr 1

itransp = p4
imul = ampdbfs(p5)
Sfilepath = p6

ichn filenchnls Sfilepath
ispeed = powoftwo(itransp / 12)

if ichn == 2 then
aL, aR diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul ,aR*imul
else
aL diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul, aL*imul
endif
  endin
</CsInstruments>

<CsScore>
%s
e
</CsScore>
</CsoundSynthesizer>" "\"$the_sf_Path\"" $str_coll]

return $str_res
}

proc eval_Csound {} {
  global app_Dir
  global curr_Dir
  global outpath
  global out_format
  global open_sf
  global temp_console_out
  global csound_terminal_path

  set temp_sf_path [file join "$curr_Dir/out" "$outpath.$out_format"]
  set temp_csd_path [file join "$curr_Dir" "temp_csound.csd"]  
  set temp_csound_str [make_csound_score]
  
  write_file $temp_csound_str $temp_csd_path
  set mkdir_path "$curr_Dir/out/"
  exec mkdir -p $mkdir_path
  #-ignorestderr
  set test_catch [catch [exec $csound_terminal_path  --logfile=$temp_console_out $temp_csd_path]]
  if {$open_sf == 1 && $test_catch == 0} {exec open $temp_sf_path }
}

#========================================================================================================
#
#
#
#                                         Buttons
#
#
#
#========================================================================================================

button  .b_open_folder -text "open sf Dir" -command { open_sound_folder }
place .b_open_folder -x 20 -y 77 

button  .b_open_script -text "temp.csd" -command { exec open "$curr_Dir/temp_csound.csd"}
place .b_open_script -x 450 -y 628 

#temp_console_out 
button  .b_open_console_txt -text "console.txt" -command { open_csound_console }
place .b_open_console_txt -x 400 -y 668 

button  .b_evaluate -text "Evaluate" -command { eval_Csound }
place .b_evaluate -x 555 -y 668

button  .b_open_sf -text "Open" -command {     set temp_sf_path [file join "$curr_Dir/out" "$outpath.$out_format"]  
    set out_file [file exist $temp_sf_path]
    if {$out_file == 1} {exec open $temp_sf_path} else {bell}
   }
place .b_open_sf -x 485 -y 668

button  .b_empty_out -text "remove out" -command {delete_out_files}
place .b_empty_out -x 640 -y 628

button  .b_update_ut -text "ut->" -command { set seed $temp_seed
puts $temp_seed }
place .b_update_ut -x 450 -y 77

button  .b_set_Color_List -text "set rnd dx" -command { 
  #set random state:
  if {$seed == ""} {set temp_seed [clock seconds]} else {set temp_seed $seed}  
  expr srand($temp_seed)

  if {$list_reps == 1} {set colorList [random_dx [llength $sf_List] $len_list]} else { 
    set colorList [shuffle [mk_colorList0]] }

  set dxList [get_dx_list $colorList]

  .lb_colorList_len configure -text "\[len = [llength $colorList]\]"  

  .lb_durx configure -text [format "%s' %s\"" [expr round(floor($dur_sec / 60))] [expr round($dur_sec) % 60]]

  if {[llength $colorList] == [llength $all_elem] } {

    set selected {}
    foreach idx $all_elem {.c itemconfigure $idx -fill #1c79d9 -outline #1c79d9}

    set selected1 {}
    foreach idx $all_elem2 {.c2 itemconfigure $idx -fill gray -outline gray}

    set selected2 {}
    foreach idx $all_elem3 {.c2 itemconfigure $idx -fill lightgray -outline #1c79d9}

    set selected3 {}
    foreach idx $all_elem4 {.c2 itemconfigure $idx -fill gray}


    set id_data [dict create]
    set len [llength $colorList]

    for {set x 0} {$x < $len} {incr x} {
      set colorx [lindex $colorList $x]
      set idx [lindex $all_elem $x]
      dict set id_data $idx $colorx
      }
    update_sf_dur_List
    updateCanvas $graph_w $graph_h
    updateCanvas2 $graph_w
  } else {
    .c delete "all"
    set rexxt1 [.c create rectangle 4 4 [expr $graph_w + 2] [expr $graph_h + 2] -outline #1c79d9 -width 4 ]
    set all_lines {}
    set all_elem {}
    set selected {}
    set all_values {}

    CreateCanvas
    updateCanvas $graph_w $graph_h
    .c2 delete "all"
    set sf_mul_List [lrepeat [llength $colorList] 0]
    set sf_transp_List [lrepeat [llength $colorList] 0]
    #set sf_dur_List {}
    #foreach y $colorList {set durx [lindex $sf_dur0_List $y]; lappend sf_dur_List $durx}  
    update_sf_dur_List    
    CreateCanvas2
    updateCanvas2 $graph_w
  }
}

place .b_set_Color_List -x 660 -y 160

#========================================================================================================
#
#
#
#                                           create Graphics 
#
#
#
#========================================================================================================

if {$sf_List_len > 0} {  CreateCanvas
                         CreateCanvas2
                       } else { open_new_dir }

#=====
# EOF
#=====