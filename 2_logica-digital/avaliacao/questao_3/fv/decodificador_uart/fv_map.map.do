
//input ports
add mapped point clk clk -type PI PI
add mapped point reset reset -type PI PI
add mapped point RX RX -type PI PI

//output ports
add mapped point dado_valido dado_valido -type PO PO
add mapped point dado[7] dado[7] -type PO PO
add mapped point dado[6] dado[6] -type PO PO
add mapped point dado[5] dado[5] -type PO PO
add mapped point dado[4] dado[4] -type PO PO
add mapped point dado[3] dado[3] -type PO PO
add mapped point dado[2] dado[2] -type PO PO
add mapped point dado[1] dado[1] -type PO PO
add mapped point dado[0] dado[0] -type PO PO
add mapped point paridade paridade -type PO PO
add mapped point inicio inicio -type PO PO

//inout ports




//Sequential Pins
add mapped point paridade_atual/q paridade_atual_reg/Q -type DFF DFF
add mapped point dado_recebido_atual[5]/q dado_recebido_atual_reg[5]/Q -type DFF DFF
add mapped point dado_recebido_atual[3]/q dado_recebido_atual_reg[3]/Q -type DFF DFF
add mapped point dado_recebido_atual[1]/q dado_recebido_atual_reg[1]/Q -type DFF DFF
add mapped point dado_recebido_atual[7]/q dado_recebido_atual_reg[7]/Q -type DFF DFF
add mapped point dado_recebido_atual[0]/q dado_recebido_atual_reg[0]/Q -type DFF DFF
add mapped point dado_recebido_atual[2]/q dado_recebido_atual_reg[2]/Q -type DFF DFF
add mapped point dado_recebido_atual[4]/q dado_recebido_atual_reg[4]/Q -type DFF DFF
add mapped point dado_recebido_atual[6]/q dado_recebido_atual_reg[6]/Q -type DFF DFF
add mapped point count_atual[2]/q count_atual_reg[2]/Q -type DFF DFF
add mapped point estado_atual[0]/q estado_atual_reg[0]/Q -type DFF DFF
add mapped point count_atual[1]/q count_atual_reg[1]/Q -type DFF DFF
add mapped point count_atual[0]/q count_atual_reg[0]/Q -type DFF DFF
add mapped point dv_atual/q dv_atual_reg/Q -type DFF DFF
add mapped point estado_atual[1]/q estado_atual_reg[1]/Q -type DFF DFF
add mapped point estado_atual[2]/q estado_atual_reg[2]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
