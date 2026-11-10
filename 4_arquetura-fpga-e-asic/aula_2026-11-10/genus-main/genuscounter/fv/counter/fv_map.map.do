
//input ports
add mapped point clk clk -type PI PI
add mapped point m m -type PI PI
add mapped point rst rst -type PI PI

//output ports
add mapped point count[15] count[15] -type PO PO
add mapped point count[14] count[14] -type PO PO
add mapped point count[13] count[13] -type PO PO
add mapped point count[12] count[12] -type PO PO
add mapped point count[11] count[11] -type PO PO
add mapped point count[10] count[10] -type PO PO
add mapped point count[9] count[9] -type PO PO
add mapped point count[8] count[8] -type PO PO
add mapped point count[7] count[7] -type PO PO
add mapped point count[6] count[6] -type PO PO
add mapped point count[5] count[5] -type PO PO
add mapped point count[4] count[4] -type PO PO
add mapped point count[3] count[3] -type PO PO
add mapped point count[2] count[2] -type PO PO
add mapped point count[1] count[1] -type PO PO
add mapped point count[0] count[0] -type PO PO

//inout ports




//Sequential Pins
add mapped point count[15]/q count_reg[15]/Q -type DFF DFF
add mapped point count[11]/q count_reg[11]/Q -type DFF DFF
add mapped point count[14]/q count_reg[14]/Q -type DFF DFF
add mapped point count[10]/q count_reg[10]/Q -type DFF DFF
add mapped point count[13]/q count_reg[13]/Q -type DFF DFF
add mapped point count[7]/q count_reg[7]/Q -type DFF DFF
add mapped point count[12]/q count_reg[12]/Q -type DFF DFF
add mapped point count[9]/q count_reg[9]/Q -type DFF DFF
add mapped point count[6]/q count_reg[6]/Q -type DFF DFF
add mapped point count[8]/q count_reg[8]/Q -type DFF DFF
add mapped point count[3]/q count_reg[3]/Q -type DFF DFF
add mapped point count[5]/q count_reg[5]/Q -type DFF DFF
add mapped point count[2]/q count_reg[2]/Q -type DFF DFF
add mapped point count[4]/q count_reg[4]/Q -type DFF DFF
add mapped point count[1]/q count_reg[1]/Q -type DFF DFF
add mapped point count[0]/q count_reg[0]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
