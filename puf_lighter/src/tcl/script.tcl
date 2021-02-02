set cell_path_0 {inst_arbiter_puf/inst_delay_line/inst_mux_pair}
set cell_path_1 {inst_mux_as_muxf7.inst_muxf7}

set start_pos_x 0
set start_pos_y 100

set current_pos_x 0
set current_pos_y 0

for {set i 1} {$i <= 24} {incr i} {
    
    
    set current_pos_x [expr $start_pos_x + $i]
    set current_pos_y [expr $start_pos_y + 0]
    
    startgroup
    place_cell "$cell_path_0[$i].inst_mux_1/$cell_path_1" SLICE_X${current_pos_x}Y${current_pos_y}/F7BMUX
    endgroup

    startgroup
    place_cell "$cell_path_0[$i].inst_mux_2/$cell_path_1" SLICE_X${current_pos_x}Y${current_pos_y}/F7AMUX
    endgroup

}

startgroup
place_cell inst_arbiter_puf/inst_dff/dff_macro.inst_fdre SLICE_X32Y100/B5FF
endgroup
