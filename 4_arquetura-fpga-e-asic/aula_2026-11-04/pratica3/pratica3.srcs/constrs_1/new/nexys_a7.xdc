## This file is a general .xdc for the Nexys A7-100T
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];


## Botões (Reset e Sinais de Controlo)
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { reset }];   # BTNC (Botão Central)
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { up_down }]; # BTNU (Botão Cima)
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { lr }];      # BTNL (Botão Esquerda)
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { sel }];     # BTNR (Botão Direita)

## Switches (Entrada de Dados - data_in)
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { data_in[0] }]; # SW0
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { data_in[1] }]; # SW1
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { data_in[2] }]; # SW2
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { data_in[3] }]; # SW3
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { data_in[4] }]; # SW4
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { data_in[5] }]; # SW5
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { data_in[6] }]; # SW6
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { data_in[7] }]; # SW7

## 7-Segment Display (Segmentos Partilhados - Cátodos/Ânodos invertidos conforme lógica)
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { seg[0] }]; # CA
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { seg[1] }]; # CB
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { seg[2] }]; # CC
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { seg[3] }]; # CD
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { seg[4] }]; # CE
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { seg[5] }]; # CF
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { seg[6] }]; # CG

## 7-Segment Display (Ânodos de Seleção de Dígito)
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { an[0] }]; # AN0 (Dígito da Direita)
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { an[1] }]; # AN1 (Dígito da Esquerda)
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { an[2] }]; # AN2
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { an[3] }]; # AN3
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { an[4] }]; # AN4
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { an[5] }]; # AN5
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { an[6] }]; # AN6
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { an[7] }]; # AN7
