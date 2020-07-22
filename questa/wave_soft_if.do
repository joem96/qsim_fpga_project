onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 30 important
add wave -noupdate /soft_if_tb/clk
add wave -noupdate /soft_if_tb/reset
add wave -noupdate -color Cyan -itemcolor Cyan /soft_if_tb/uut_soft_if/comp_result
add wave -noupdate -color Cyan -itemcolor Cyan /soft_if_tb/uut_soft_if/mat_ctrl_out
add wave -noupdate /soft_if_tb/soft_start_mult
add wave -noupdate /soft_if_tb/soft_set_vec
add wave -noupdate -color {Sky Blue} -itemcolor {Sky Blue} /soft_if_tb/uut_soft_if/u_mat_ctrl/vec_result
add wave -noupdate -color Turquoise -itemcolor Turquoise /soft_if_tb/uut_soft_if/u_mat_ctrl/vec
add wave -noupdate /soft_if_tb/uut_soft_if/mat_ctrl_out_debug
add wave -noupdate -divider -height 30 {setting vec}
add wave -noupdate /soft_if_tb/soft_vec_data_av
add wave -noupdate /soft_if_tb/soft_vec_init
add wave -noupdate -divider -height 30 {setting brams}
add wave -noupdate /soft_if_tb/soft_bram_data_av
add wave -noupdate /soft_if_tb/soft_bram_data
add wave -noupdate /soft_if_tb/soft_set_rows
add wave -noupdate -color {Pale Green} -itemcolor {Pale Green} /soft_if_tb/uut_soft_if/soft_cnt_pop_ele
add wave -noupdate -color {Pale Green} -itemcolor {Pale Green} /soft_if_tb/uut_soft_if/soft_cnt_pop_ram_row
add wave -noupdate -color {Pale Green} -itemcolor {Pale Green} /soft_if_tb/uut_soft_if/soft_cnt_pop_mat_row
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /soft_if_tb/uut_soft_if/bram_data
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /soft_if_tb/uut_soft_if/bram_addr
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /soft_if_tb/uut_soft_if/bram_en
add wave -noupdate -color {Lime Green} -itemcolor {Lime Green} /soft_if_tb/uut_soft_if/bram_wr_en
add wave -noupdate /soft_if_tb/uut_soft_if/u_mat_ctrl/gen_mem(0)/mem/ram
add wave -noupdate /soft_if_tb/uut_soft_if/u_mat_ctrl/gen_mem(1)/mem/ram
add wave -noupdate /soft_if_tb/uut_soft_if/u_mat_ctrl/gen_mem(2)/mem/ram
add wave -noupdate /soft_if_tb/uut_soft_if/u_mat_ctrl/gen_mem(31)/mem/ram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1568 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 273
configure wave -valuecolwidth 142
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {357122 ns}
