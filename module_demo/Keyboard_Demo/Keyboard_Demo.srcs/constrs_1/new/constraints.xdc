set_property -dict {PACKAGE_PIN AC18  IOSTANDARD LVCMOS18} [get_ports {clk}];
set_property -dict {PACKAGE_PIN W13   IOSTANDARD LVCMOS18} [get_ports {rstn}];

set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {ps2_clk}];
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {ps2_data}];

set_property -dict {PACKAGE_PIN W23  IOSTANDARD LVCMOS33} [get_ports {LED[0]}];
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS33} [get_ports {LED[1]}];
set_property -dict {PACKAGE_PIN Y25  IOSTANDARD LVCMOS33} [get_ports {LED[2]}];
set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS33} [get_ports {LED[3]}];
set_property -dict {PACKAGE_PIN Y23  IOSTANDARD LVCMOS33} [get_ports {LED[4]}];
set_property -dict {PACKAGE_PIN Y22  IOSTANDARD LVCMOS33} [get_ports {LED[5]}];
set_property -dict {PACKAGE_PIN AE21 IOSTANDARD LVCMOS33} [get_ports {LED[6]}];
set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33} [get_ports {LED[7]}];