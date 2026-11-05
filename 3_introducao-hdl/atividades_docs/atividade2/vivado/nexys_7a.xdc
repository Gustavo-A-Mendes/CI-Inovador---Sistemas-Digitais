# Constraint virtual apenas para forçar o roteador a calcular o esforço de temporização
create_clock -period 10.000 -name clk_virtual -waveform {0.000 5.000}