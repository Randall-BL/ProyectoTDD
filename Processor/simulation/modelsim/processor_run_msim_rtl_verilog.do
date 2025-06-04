transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/Nbit_Sub.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/Nbit_Adder.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/full_subtractor.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/full_adder.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/datapath.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/flopr.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/adder.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/mux2.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/register_file.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/extend.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/alu.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/condcheck.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/decoder.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/arm.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/controller.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/condlogic.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/processor.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/shifter.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/vgaController.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/pll.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/vga_initializer.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/Nbit_Mult.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/instruction_memory.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/data_memory.sv}
vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/videoGen.sv}

vlog -sv -work work +incdir+C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor {C:/Users/YITAN/OneDrive/Escritorio/TDD_Docs_II2024/jtenorio_aflores_klobo_digital_design_lab_2024-master/Proyecto/Processor/controller_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  controller_tb

add wave *
view structure
view signals
run -all
