# script general de simulacion
# questa v6

vlib work

# libs


vcom -explicit	-93 "src/dual_mem.vhd"  
vcom -explicit  -93 "src/key_schedule.vhd"  
vcom -explicit  -93 "src/aes_lib.vhd"  
vcom -explicit  -93 "src/aes_enc.vhd"
vcom -explicit  -93 "src/aes_ccm.vhd"
vcom -explicit  -93 "src/tb_aes_ccm.vhd"

# Sim

vsim -lib work -t 1ps tb_aes_ccm

view wave
view source
view structure
view signals
add wave *

mem load -infile mem/s_box.mem -format hex tb_aes_ccm/uut/aes_round_n/s_box_dual_1
mem load -infile mem/s_box.mem -format hex tb_aes_ccm/uut/aes_round_n/s_box_dual_2

mem load -infile mem/s_box.mem -format hex tb_aes_ccm/uut/key_gen/s_box_dual_1
mem load -infile mem/s_box.mem -format hex tb_aes_ccm/uut/key_gen/s_box_dual_2

#mem load -infile mem/key.mem -format hex tb_aes_ccm/uut/sub_keys_dram

add wave \
{sim:/tb_aes_ccm/uut/state } 
add wave \
{sim:/tb_aes_ccm/uut/block_out_s } 
add wave \
{sim:/tb_aes_ccm/uut/count } 
add wave \
{sim:/tb_aes_ccm/uut/key_data_1 } \
{sim:/tb_aes_ccm/uut/key_data_2 } 
add wave \
{sim:/tb_aes_ccm/uut/aes_round_n/sub_key } 

add wave \
{sim:/tb_aes_ccm/uut/count_12 } 

add wave sim:/tb_aes_ccm/uut/key_gen/*
add wave sim:/tb_aes_ccm/uut/sub_keys_dram/*
add wave \
{sim:/tb_aes_ccm/uut/count_12 } 

add wave \
{sim:/tb_aes_ccm/uut/aes_ctr_cnt } 
add wave \
{sim:/tb_aes_ccm/uut/update_ctr } 

add wave \
{sim:/tb_aes_ccm/uut/aes_cbc_reg } 
add wave \
{sim:/tb_aes_ccm/uut/load_cbc_reg } 

add wave \
{sim:/tb_aes_ccm/uut/aes_cbc_start_flag } \
{sim:/tb_aes_ccm/uut/set_aes_cbc_start_flag } 

#bp src/aes_ccm.vhd 153

run 16 us

