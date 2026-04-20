set script_dir [file normalize [file dirname [info script]]]
set repo_root [file normalize [file join $script_dir ..]]
set project_name timerpiece_reference
set project_dir [file normalize [file join $repo_root .vivado $project_name]]

file mkdir $project_dir

create_project $project_name $project_dir -part xc7a35tcpg236-1 -force
set_property target_language Verilog [current_project]

set source_files [list     [file join $repo_root Timerpiece.srcs sources_1 new common_control.v]     [file join $repo_root Timerpiece.srcs sources_1 new debouncer.v]     [file join $repo_root Timerpiece.srcs sources_1 new display_select.v]     [file join $repo_root Timerpiece.srcs sources_1 imports 10000_counter fnd_controller.v]     [file join $repo_root Timerpiece.srcs sources_1 new input_conditioning.v]     [file join $repo_root Timerpiece.srcs sources_1 new time_set_module.v]     [file join $repo_root Timerpiece.srcs sources_1 new timepiece_datapath.v]     [file join $repo_root Timerpiece.srcs sources_1 new timepiece_fsm.v]     [file join $repo_root Timerpiece.srcs sources_1 new timer_datapath.v]     [file join $repo_root Timerpiece.srcs sources_1 new timer_fsm.v]     [file join $repo_root Timerpiece.srcs sources_1 new timer_unit.v]     [file join $repo_root Timerpiece.srcs sources_1 new timerpiece.v] ]

set sim_files [list     [file join $repo_root Timerpiece.srcs sim_1 new tb_timerpiece.v] ]

set constraint_files [list     [file join $repo_root Timerpiece.srcs constrs_1 new timerpiece.xdc] ]

add_files -fileset sources_1 $source_files
add_files -fileset sim_1 $sim_files
add_files -fileset constrs_1 $constraint_files

set_property top timerpiece [get_filesets sources_1]
set_property top tb_timerpiece [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Created Vivado project:"
puts "  [file join $project_dir ${project_name}.xpr]"
