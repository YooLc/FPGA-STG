# 板载时钟 100 Mhz
set_property -dict {PACKAGE_PIN AC18  IOSTANDARD LVCMOS18} [get_ports {clk}];
# FPGA RST
set_property -dict {PACKAGE_PIN W13   IOSTANDARD LVCMOS18} [get_ports {rstn}];

# 八位七段数码管
set_property -dict {PACKAGE_PIN M24   IOSTANDARD LVCMOS33} [get_ports {SEGLED_CLK}];
set_property -dict {PACKAGE_PIN M20   IOSTANDARD LVCMOS33} [get_ports {SEGLED_CLR}];
set_property -dict {PACKAGE_PIN L24   IOSTANDARD LVCMOS33} [get_ports {SEGLED_DO}];
set_property -dict {PACKAGE_PIN R18   IOSTANDARD LVCMOS33} [get_ports {SEGLED_PEN}];

# 开关
set_property -dict {PACKAGE_PIN AA10  IOSTANDARD LVCMOS15} [get_ports {SW[0]}];
set_property -dict {PACKAGE_PIN AB10  IOSTANDARD LVCMOS15} [get_ports {SW[1]}];
set_property -dict {PACKAGE_PIN AA13  IOSTANDARD LVCMOS15} [get_ports {SW[2]}];
set_property -dict {PACKAGE_PIN AA12  IOSTANDARD LVCMOS15} [get_ports {SW[3]}];
set_property -dict {PACKAGE_PIN Y13   IOSTANDARD LVCMOS15} [get_ports {SW[4]}];
set_property -dict {PACKAGE_PIN Y12   IOSTANDARD LVCMOS15} [get_ports {SW[5]}];
set_property -dict {PACKAGE_PIN AD11  IOSTANDARD LVCMOS15} [get_ports {SW[6]}];
set_property -dict {PACKAGE_PIN AD10  IOSTANDARD LVCMOS15} [get_ports {SW[7]}];
set_property -dict {PACKAGE_PIN AE10  IOSTANDARD LVCMOS15} [get_ports {SW[8]}];
set_property -dict {PACKAGE_PIN AE12  IOSTANDARD LVCMOS15} [get_ports {SW[9]}];
set_property -dict {PACKAGE_PIN AF12  IOSTANDARD LVCMOS15} [get_ports {SW[10]}];
set_property -dict {PACKAGE_PIN AE8   IOSTANDARD LVCMOS15} [get_ports {SW[11]}];
set_property -dict {PACKAGE_PIN AF8   IOSTANDARD LVCMOS15} [get_ports {SW[12]}];
set_property -dict {PACKAGE_PIN AE13  IOSTANDARD LVCMOS15} [get_ports {SW[13]}];
set_property -dict {PACKAGE_PIN AF13  IOSTANDARD LVCMOS15} [get_ports {SW[14]}];
set_property -dict {PACKAGE_PIN AF10  IOSTANDARD LVCMOS15} [get_ports {SW[15]}];

# VGA
set_property -dict {PACKAGE_PIN T20   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[0]}];
set_property -dict {PACKAGE_PIN R20   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[1]}];
set_property -dict {PACKAGE_PIN T22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[2]}];
set_property -dict {PACKAGE_PIN T23   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[3]}];
set_property -dict {PACKAGE_PIN R22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[0]}];
set_property -dict {PACKAGE_PIN R23   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[1]}];
set_property -dict {PACKAGE_PIN T24   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[2]}];
set_property -dict {PACKAGE_PIN T25   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[3]}];
set_property -dict {PACKAGE_PIN N21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[0]}];
set_property -dict {PACKAGE_PIN N22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[1]}];
set_property -dict {PACKAGE_PIN R21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[2]}];
set_property -dict {PACKAGE_PIN P21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[3]}];
set_property -dict {PACKAGE_PIN M22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {hs}];
set_property -dict {PACKAGE_PIN M21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {vs}];

# PS/2 键盘
set_property -dict {PACKAGE_PIN N18  IOSTANDARD LVCMOS33} [get_ports {ps2_clk}];
set_property -dict {PACKAGE_PIN M19  IOSTANDARD LVCMOS33} [get_ports {ps2_data}];

# Arduino LED
set_property -dict {PACKAGE_PIN W23  IOSTANDARD LVCMOS33} [get_ports {LED[0]}];
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS33} [get_ports {LED[1]}];
set_property -dict {PACKAGE_PIN Y25  IOSTANDARD LVCMOS33} [get_ports {LED[2]}];
set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS33} [get_ports {LED[3]}];
set_property -dict {PACKAGE_PIN Y23  IOSTANDARD LVCMOS33} [get_ports {LED[4]}];
set_property -dict {PACKAGE_PIN Y22  IOSTANDARD LVCMOS33} [get_ports {LED[5]}];
set_property -dict {PACKAGE_PIN AE21 IOSTANDARD LVCMOS33} [get_ports {LED[6]}];
set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33} [get_ports {LED[7]}];

# 蜂鸣器与 3.5mm 耳机接口
set_property -dict {PACKAGE_PIN AF25 IOSTANDARD LVCMOS33} [get_ports {buzzer}];
set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVCMOS33} [get_ports {AUD_PWM}];
set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS33} [get_ports {AUD_SD}];

# DDR3 内存
set_property -dict {PACKAGE_PIN AA9  Vccaux_io HIGH} [get_ports {ddr3_addr[0]}];
set_property -dict {PACKAGE_PIN AA7  Vccaux_io HIGH} [get_ports {ddr3_addr[1]}];
set_property -dict {PACKAGE_PIN W9   Vccaux_io HIGH} [get_ports {ddr3_addr[2]}];
set_property -dict {PACKAGE_PIN Y10  Vccaux_io HIGH} [get_ports {ddr3_addr[3]}];
set_property -dict {PACKAGE_PIN V9   Vccaux_io HIGH} [get_ports {ddr3_addr[4]}];
set_property -dict {PACKAGE_PIN AC12 Vccaux_io HIGH} [get_ports {ddr3_addr[5]}];
set_property -dict {PACKAGE_PIN AB12 Vccaux_io HIGH} [get_ports {ddr3_addr[6]}];
set_property -dict {PACKAGE_PIN V11  Vccaux_io HIGH} [get_ports {ddr3_addr[7]}];
set_property -dict {PACKAGE_PIN Y11  Vccaux_io HIGH} [get_ports {ddr3_addr[8]}];
set_property -dict {PACKAGE_PIN AD13 Vccaux_io HIGH} [get_ports {ddr3_addr[9]}];
set_property -dict {PACKAGE_PIN AB7  Vccaux_io HIGH} [get_ports {ddr3_addr[10]}];
set_property -dict {PACKAGE_PIN W11  Vccaux_io HIGH} [get_ports {ddr3_addr[11]}];
set_property -dict {PACKAGE_PIN AB9  Vccaux_io HIGH} [get_ports {ddr3_addr[12]}];
set_property -dict {PACKAGE_PIN AC13 Vccaux_io HIGH} [get_ports {ddr3_addr[13]}];
 
set_property -dict {PACKAGE_PIN V8   Vccaux_io HIGH} [get_ports {ddr3_ba[0]}];
set_property -dict {PACKAGE_PIN Y8   Vccaux_io HIGH} [get_ports {ddr3_ba[1]}];
set_property -dict {PACKAGE_PIN AA8  Vccaux_io HIGH} [get_ports {ddr3_ba[2]}];
set_property -dict {PACKAGE_PIN AC7  Vccaux_io HIGH} [get_ports {ddr3_cas_n}];
set_property -dict {PACKAGE_PIN AF7  Vccaux_io HIGH} [get_ports {ddr3_ck_n[0]}];
set_property -dict {PACKAGE_PIN AE7  Vccaux_io HIGH} [get_ports {ddr3_ck_p[0]}];
set_property -dict {PACKAGE_PIN V7   Vccaux_io HIGH} [get_ports {ddr3_cke[0]}];
set_property -dict {PACKAGE_PIN AD8  Vccaux_io HIGH} [get_ports {ddr3_cs_n[0]}];
set_property -dict {PACKAGE_PIN V3   Vccaux_io HIGH} [get_ports {ddr3_dm[0]}];
set_property -dict {PACKAGE_PIN Y3   Vccaux_io HIGH} [get_ports {ddr3_dm[1]}];
# set_property -dict {PACKAGE_PIN AB6  IOSTANDARD SSTL15 Vccaux_io HIGH} [get_ports {ddr3_dm[2]}];
# set_property -dict {PACKAGE_PIN AD1  IOSTANDARD SSTL15 Vccaux_io HIGH} [get_ports {ddr3_dm[3]}];
set_property -dict {PACKAGE_PIN U2   Vccaux_io HIGH} [get_ports {ddr3_dq[0]}];
set_property -dict {PACKAGE_PIN U7   Vccaux_io HIGH} [get_ports {ddr3_dq[1]}];
set_property -dict {PACKAGE_PIN U6   Vccaux_io HIGH} [get_ports {ddr3_dq[2]}];
set_property -dict {PACKAGE_PIN V4   Vccaux_io HIGH} [get_ports {ddr3_dq[3]}];
set_property -dict {PACKAGE_PIN V6   Vccaux_io HIGH} [get_ports {ddr3_dq[4]}];
set_property -dict {PACKAGE_PIN W3   Vccaux_io HIGH} [get_ports {ddr3_dq[5]}];
set_property -dict {PACKAGE_PIN U5   Vccaux_io HIGH} [get_ports {ddr3_dq[6]}];
set_property -dict {PACKAGE_PIN U1   Vccaux_io HIGH} [get_ports {ddr3_dq[7]}];
set_property -dict {PACKAGE_PIN AA2  Vccaux_io HIGH} [get_ports {ddr3_dq[8]}];
set_property -dict {PACKAGE_PIN Y2   Vccaux_io HIGH} [get_ports {ddr3_dq[9]}];
set_property -dict {PACKAGE_PIN AC2  Vccaux_io HIGH} [get_ports {ddr3_dq[10]}];
set_property -dict {PACKAGE_PIN Y1   Vccaux_io HIGH} [get_ports {ddr3_dq[11]}];
set_property -dict {PACKAGE_PIN AA3  Vccaux_io HIGH} [get_ports {ddr3_dq[12]}];
set_property -dict {PACKAGE_PIN V1   Vccaux_io HIGH} [get_ports {ddr3_dq[13]}];
set_property -dict {PACKAGE_PIN AB2  Vccaux_io HIGH} [get_ports {ddr3_dq[14]}];
set_property -dict {PACKAGE_PIN W1   Vccaux_io HIGH} [get_ports {ddr3_dq[15]}];

# set_property -dict {PACKAGE_PIN AA4  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[16]}];
# set_property -dict {PACKAGE_PIN AC3  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[17]}];
# set_property -dict {PACKAGE_PIN Y5   IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[18]}];
# set_property -dict {PACKAGE_PIN AC6  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[19]}];
# set_property -dict {PACKAGE_PIN Y6   IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[20]}];
# set_property -dict {PACKAGE_PIN AD6  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[21]}];
# set_property -dict {PACKAGE_PIN AB4  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[22]}];
# set_property -dict {PACKAGE_PIN AC4  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[23]}];
# set_property -dict {PACKAGE_PIN AF2  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[24]}];
# set_property -dict {PACKAGE_PIN AE2  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[25]}];
# set_property -dict {PACKAGE_PIN AE3  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[26]}];
# set_property -dict {PACKAGE_PIN AD4  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[27]}];
# set_property -dict {PACKAGE_PIN AE6  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[28]}];
# set_property -dict {PACKAGE_PIN AE1  IOSTANDARD SSTL15_T_DCI  Vccaux_io HIGH} [get_ports {ddr3_dq[29]}];
# set_property -dict {PACKAGE_PIN AF3  IOSTANDARD SSTL15_T_DCI Vccaux_io HIGH} [get_ports {ddr3_dq[30]}];
# set_property -dict {PACKAGE_PIN AE5  IOSTANDARD SSTL15_T_DCI Vccaux_io HIGH} [get_ports {ddr3_dq[31]}];

set_property -dict {PACKAGE_PIN W6   Vccaux_io HIGH} [get_ports {ddr3_dqs_p[0]}];
set_property -dict {PACKAGE_PIN AB1  Vccaux_io HIGH} [get_ports {ddr3_dqs_p[1]}];
# set_property -dict {PACKAGE_PIN AA5  IOSTANDARD DIFF_SSTL15_T_DCI Vccaux_io HIGH} [get_ports {ddr3_dqs_p[2]}];
# set_property -dict {PACKAGE_PIN AF5  IOSTANDARD DIFF_SSTL15_T_DCI Vccaux_io HIGH} [get_ports {ddr3_dqs_p[3]}];
set_property -dict {PACKAGE_PIN W5   Vccaux_io HIGH} [get_ports {ddr3_dqs_n[0]}];
set_property -dict {PACKAGE_PIN AC1  Vccaux_io HIGH} [get_ports {ddr3_dqs_n[1]}];
# set_property -dict {PACKAGE_PIN AB5  IOSTANDARD DIFF_SSTL15_T_DCI Vccaux_io HIGH} [get_ports {ddr3_dqs_n[2]}];
# set_property -dict {PACKAGE_PIN AF4  IOSTANDARD DIFF_SSTL15_T_DCI Vccaux_io HIGH} [get_ports {ddr3_dqs_n[3]}];

set_property -dict {PACKAGE_PIN AC9  Vccaux_io HIGH} [get_ports {ddr3_odt[0]}];
set_property -dict {PACKAGE_PIN Y7   Vccaux_io HIGH} [get_ports {ddr3_ras_n}];
set_property -dict {PACKAGE_PIN V2   Vccaux_io HIGH} [get_ports {ddr3_reset_n}];
set_property -dict {PACKAGE_PIN AD9  Vccaux_io HIGH} [get_ports {ddr3_we_n}];