# 板载时钟 100 Mhz
set_property -dict {PACKAGE_PIN AC18  IOSTANDARD LVCMOS18} [get_ports {clk}];
# 复位信号 - FPGA RST 按钮
set_property -dict {PACKAGE_PIN W13   IOSTANDARD LVCMOS18} [get_ports {rstn}];

# 八位七段数码管
set_property -dict {PACKAGE_PIN M24 IOSTANDARD LVCMOS33} [get_ports {segled_clk}];
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {SEGLED_CLR}];
set_property -dict {PACKAGE_PIN L24 IOSTANDARD LVCMOS33} [get_ports {SEGLED_DO}];
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {SEGLED_PEN}];

# 板载 LED
set_property -dict {PACKAGE_PIN N26 IOSTANDARD LVCMOS33} [get_ports {LED_CLK}];
set_property -dict {PACKAGE_PIN N24 IOSTANDARD LVCMOS33} [get_ports {LED_CLR}];
set_property -dict {PACKAGE_PIN M26 IOSTANDARD LVCMOS33} [get_ports {LED_DO}];
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {LED_PEN}];

# 键盘阵列
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_X[0]}];
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_X[1]}];
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_X[2]}];
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_X[3]}];
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_X[4]}];
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_Y[0]}];
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_Y[1]}];
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_Y[2]}];
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS18 PULLUP} [get_ports {BTN_Y[3]}];

# 开关
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS15} [get_ports {SW[0]}];
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS15} [get_ports {SW[1]}];
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS15} [get_ports {SW[2]}];
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS15} [get_ports {SW[3]}];
set_property -dict {PACKAGE_PIN Y13  IOSTANDARD LVCMOS15} [get_ports {SW[4]}];
set_property -dict {PACKAGE_PIN Y12  IOSTANDARD LVCMOS15} [get_ports {SW[5]}];
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVCMOS15} [get_ports {SW[6]}];
set_property -dict {PACKAGE_PIN AD10 IOSTANDARD LVCMOS15} [get_ports {SW[7]}];
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS15} [get_ports {SW[8]}];
set_property -dict {PACKAGE_PIN AE12 IOSTANDARD LVCMOS15} [get_ports {SW[9]}];
set_property -dict {PACKAGE_PIN AF12 IOSTANDARD LVCMOS15} [get_ports {SW[10]}];
set_property -dict {PACKAGE_PIN AE8  IOSTANDARD LVCMOS15} [get_ports {SW[11]}];
set_property -dict {PACKAGE_PIN AF8  IOSTANDARD LVCMOS15} [get_ports {SW[12]}];
set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS15} [get_ports {SW[13]}];
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS15} [get_ports {SW[14]}];
set_property -dict {PACKAGE_PIN AF10 IOSTANDARD LVCMOS15} [get_ports {SW[15]}];

# Arduino 蜂鸣器
set_property -dict {PACKAGE_PIN AF24  IOSTANDARD LVCMOS33} [get_ports {buzzer}];

# 3.5 mm 耳机接口
set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVCMOS33} [get_ports {AUD_PWM}];
set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS33} [get_ports {AUD_SD}];

# VGA 颜色信号
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[0]}];
set_property -dict {PACKAGE_PIN R20 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[1]}];
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[2]}];
set_property -dict {PACKAGE_PIN T23 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {b[3]}];
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[0]}];
set_property -dict {PACKAGE_PIN R23 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[1]}];
set_property -dict {PACKAGE_PIN T24 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[2]}];
set_property -dict {PACKAGE_PIN T25 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {g[3]}];
set_property -dict {PACKAGE_PIN N21 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[0]}];
set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[1]}];
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[2]}];
set_property -dict {PACKAGE_PIN P21 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {r[3]}];
# VGA 同步信号
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {hs}];
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {vs}];

# PS/2 键盘
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {ps2_clk}];
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {ps2_data}];
