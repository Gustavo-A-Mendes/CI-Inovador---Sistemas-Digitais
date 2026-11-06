// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
// Date        : Fri Nov  6 10:03:18 2026
// Host        : CI-03 running 64-bit Rocky Linux release 9.8 (Blue Onyx)
// Command     : write_verilog -force -mode timesim -sdf_anno true
//               ./Vivado_projects/3_INTRODUCAO_HDL/atividade2/meu_projeto_netlist.v
// Design      : ula_neander
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "504d0e6b" *) 
(* NotValidForBitStream *)
(* \DesignAttr:ENABLE_NOC_NETLIST_VIEW  *) 
(* \DesignAttr:ENABLE_AIE_NETLIST_VIEW  *) 
module ula_neander
   (AC,
    RDM,
    sel_ula,
    resultado,
    N,
    Z);
  input [7:0]AC;
  input [7:0]RDM;
  input [2:0]sel_ula;
  output [7:0]resultado;
  output N;
  output Z;

  wire [7:0]AC;
  wire [7:0]AC_IBUF;
  wire N;
  wire N_OBUF;
  wire [7:0]RDM;
  wire [7:0]RDM_IBUF;
  wire Z;
  wire Z_OBUF;
  wire Z_OBUF_inst_i_2_n_0;
  wire [7:0]data1;
  wire [7:0]resultado;
  wire [6:0]resultado_OBUF;
  wire \resultado_OBUF[3]_inst_i_2_n_0 ;
  wire \resultado_OBUF[3]_inst_i_3_n_0 ;
  wire \resultado_OBUF[3]_inst_i_4_n_0 ;
  wire \resultado_OBUF[3]_inst_i_5_n_0 ;
  wire \resultado_OBUF[3]_inst_i_6_n_0 ;
  wire \resultado_OBUF[7]_inst_i_3_n_0 ;
  wire \resultado_OBUF[7]_inst_i_4_n_0 ;
  wire \resultado_OBUF[7]_inst_i_5_n_0 ;
  wire \resultado_OBUF[7]_inst_i_6_n_0 ;
  wire [2:0]sel_ula;
  wire [2:0]sel_ula_IBUF;
  wire [2:0]\NLW_resultado_OBUF[3]_inst_i_2_CO_UNCONNECTED ;
  wire [3:0]\NLW_resultado_OBUF[7]_inst_i_2_CO_UNCONNECTED ;

initial begin
 $sdf_annotate("meu_projeto_netlist.sdf",,,,"tool_control");
end
  IBUF \AC_IBUF[0]_inst 
       (.I(AC[0]),
        .O(AC_IBUF[0]));
  IBUF \AC_IBUF[1]_inst 
       (.I(AC[1]),
        .O(AC_IBUF[1]));
  IBUF \AC_IBUF[2]_inst 
       (.I(AC[2]),
        .O(AC_IBUF[2]));
  IBUF \AC_IBUF[3]_inst 
       (.I(AC[3]),
        .O(AC_IBUF[3]));
  IBUF \AC_IBUF[4]_inst 
       (.I(AC[4]),
        .O(AC_IBUF[4]));
  IBUF \AC_IBUF[5]_inst 
       (.I(AC[5]),
        .O(AC_IBUF[5]));
  IBUF \AC_IBUF[6]_inst 
       (.I(AC[6]),
        .O(AC_IBUF[6]));
  IBUF \AC_IBUF[7]_inst 
       (.I(AC[7]),
        .O(AC_IBUF[7]));
  OBUF N_OBUF_inst
       (.I(N_OBUF),
        .O(N));
  IBUF \RDM_IBUF[0]_inst 
       (.I(RDM[0]),
        .O(RDM_IBUF[0]));
  IBUF \RDM_IBUF[1]_inst 
       (.I(RDM[1]),
        .O(RDM_IBUF[1]));
  IBUF \RDM_IBUF[2]_inst 
       (.I(RDM[2]),
        .O(RDM_IBUF[2]));
  IBUF \RDM_IBUF[3]_inst 
       (.I(RDM[3]),
        .O(RDM_IBUF[3]));
  IBUF \RDM_IBUF[4]_inst 
       (.I(RDM[4]),
        .O(RDM_IBUF[4]));
  IBUF \RDM_IBUF[5]_inst 
       (.I(RDM[5]),
        .O(RDM_IBUF[5]));
  IBUF \RDM_IBUF[6]_inst 
       (.I(RDM[6]),
        .O(RDM_IBUF[6]));
  IBUF \RDM_IBUF[7]_inst 
       (.I(RDM[7]),
        .O(RDM_IBUF[7]));
  OBUF Z_OBUF_inst
       (.I(Z_OBUF),
        .O(Z));
  LUT5 #(
    .INIT(32'h00000001)) 
    Z_OBUF_inst_i_1
       (.I0(resultado_OBUF[4]),
        .I1(resultado_OBUF[5]),
        .I2(N_OBUF),
        .I3(resultado_OBUF[6]),
        .I4(Z_OBUF_inst_i_2_n_0),
        .O(Z_OBUF));
  LUT4 #(
    .INIT(16'hFFFE)) 
    Z_OBUF_inst_i_2
       (.I0(resultado_OBUF[1]),
        .I1(resultado_OBUF[0]),
        .I2(resultado_OBUF[3]),
        .I3(resultado_OBUF[2]),
        .O(Z_OBUF_inst_i_2_n_0));
  OBUF \resultado_OBUF[0]_inst 
       (.I(resultado_OBUF[0]),
        .O(resultado[0]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[0]_inst_i_1 
       (.I0(data1[0]),
        .I1(RDM_IBUF[0]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[0]),
        .O(resultado_OBUF[0]));
  OBUF \resultado_OBUF[1]_inst 
       (.I(resultado_OBUF[1]),
        .O(resultado[1]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[1]_inst_i_1 
       (.I0(data1[1]),
        .I1(RDM_IBUF[1]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[1]),
        .O(resultado_OBUF[1]));
  OBUF \resultado_OBUF[2]_inst 
       (.I(resultado_OBUF[2]),
        .O(resultado[2]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[2]_inst_i_1 
       (.I0(data1[2]),
        .I1(RDM_IBUF[2]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[2]),
        .O(resultado_OBUF[2]));
  OBUF \resultado_OBUF[3]_inst 
       (.I(resultado_OBUF[3]),
        .O(resultado[3]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[3]_inst_i_1 
       (.I0(data1[3]),
        .I1(RDM_IBUF[3]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[3]),
        .O(resultado_OBUF[3]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \resultado_OBUF[3]_inst_i_2 
       (.CI(1'b0),
        .CO({\resultado_OBUF[3]_inst_i_2_n_0 ,\NLW_resultado_OBUF[3]_inst_i_2_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI(AC_IBUF[3:0]),
        .O(data1[3:0]),
        .S({\resultado_OBUF[3]_inst_i_3_n_0 ,\resultado_OBUF[3]_inst_i_4_n_0 ,\resultado_OBUF[3]_inst_i_5_n_0 ,\resultado_OBUF[3]_inst_i_6_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[3]_inst_i_3 
       (.I0(AC_IBUF[3]),
        .I1(RDM_IBUF[3]),
        .O(\resultado_OBUF[3]_inst_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[3]_inst_i_4 
       (.I0(AC_IBUF[2]),
        .I1(RDM_IBUF[2]),
        .O(\resultado_OBUF[3]_inst_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[3]_inst_i_5 
       (.I0(AC_IBUF[1]),
        .I1(RDM_IBUF[1]),
        .O(\resultado_OBUF[3]_inst_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[3]_inst_i_6 
       (.I0(AC_IBUF[0]),
        .I1(RDM_IBUF[0]),
        .O(\resultado_OBUF[3]_inst_i_6_n_0 ));
  OBUF \resultado_OBUF[4]_inst 
       (.I(resultado_OBUF[4]),
        .O(resultado[4]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[4]_inst_i_1 
       (.I0(data1[4]),
        .I1(RDM_IBUF[4]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[4]),
        .O(resultado_OBUF[4]));
  OBUF \resultado_OBUF[5]_inst 
       (.I(resultado_OBUF[5]),
        .O(resultado[5]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[5]_inst_i_1 
       (.I0(data1[5]),
        .I1(RDM_IBUF[5]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[5]),
        .O(resultado_OBUF[5]));
  OBUF \resultado_OBUF[6]_inst 
       (.I(resultado_OBUF[6]),
        .O(resultado[6]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[6]_inst_i_1 
       (.I0(data1[6]),
        .I1(RDM_IBUF[6]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[6]),
        .O(resultado_OBUF[6]));
  OBUF \resultado_OBUF[7]_inst 
       (.I(N_OBUF),
        .O(resultado[7]));
  LUT6 #(
    .INIT(64'h00CA00FF000A0FC0)) 
    \resultado_OBUF[7]_inst_i_1 
       (.I0(data1[7]),
        .I1(RDM_IBUF[7]),
        .I2(sel_ula_IBUF[1]),
        .I3(sel_ula_IBUF[2]),
        .I4(sel_ula_IBUF[0]),
        .I5(AC_IBUF[7]),
        .O(N_OBUF));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \resultado_OBUF[7]_inst_i_2 
       (.CI(\resultado_OBUF[3]_inst_i_2_n_0 ),
        .CO(\NLW_resultado_OBUF[7]_inst_i_2_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,AC_IBUF[6:4]}),
        .O(data1[7:4]),
        .S({\resultado_OBUF[7]_inst_i_3_n_0 ,\resultado_OBUF[7]_inst_i_4_n_0 ,\resultado_OBUF[7]_inst_i_5_n_0 ,\resultado_OBUF[7]_inst_i_6_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[7]_inst_i_3 
       (.I0(AC_IBUF[7]),
        .I1(RDM_IBUF[7]),
        .O(\resultado_OBUF[7]_inst_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[7]_inst_i_4 
       (.I0(AC_IBUF[6]),
        .I1(RDM_IBUF[6]),
        .O(\resultado_OBUF[7]_inst_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[7]_inst_i_5 
       (.I0(AC_IBUF[5]),
        .I1(RDM_IBUF[5]),
        .O(\resultado_OBUF[7]_inst_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \resultado_OBUF[7]_inst_i_6 
       (.I0(AC_IBUF[4]),
        .I1(RDM_IBUF[4]),
        .O(\resultado_OBUF[7]_inst_i_6_n_0 ));
  IBUF \sel_ula_IBUF[0]_inst 
       (.I(sel_ula[0]),
        .O(sel_ula_IBUF[0]));
  IBUF \sel_ula_IBUF[1]_inst 
       (.I(sel_ula[1]),
        .O(sel_ula_IBUF[1]));
  IBUF \sel_ula_IBUF[2]_inst 
       (.I(sel_ula[2]),
        .O(sel_ula_IBUF[2]));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
