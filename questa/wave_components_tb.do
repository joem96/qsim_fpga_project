onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider add_all
add wave -noupdate /components_tb/uut/input
add wave -noupdate /components_tb/uut/output
add wave -noupdate /components_tb/uut/conc_sigs
add wave -noupdate /components_tb/uut/reg_sigs
add wave -noupdate -divider mult_elewise
add wave -noupdate /components_tb/uut2/input1
add wave -noupdate /components_tb/uut2/input2
add wave -noupdate /components_tb/uut2/output
add wave -noupdate /components_tb/uut2/out_vec
add wave -noupdate -divider row_vec_mult
add wave -noupdate /components_tb/uut3/row
add wave -noupdate /components_tb/uut3/vec
add wave -noupdate /components_tb/uut3/output
add wave -noupdate /components_tb/uut3/elewise_out
add wave -noupdate /components_tb/uut3/added_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {352 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {136 ns} {1572 ns}
