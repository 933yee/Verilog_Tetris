`timescale 1ns / 1ps
`include "global.v"

module checklines(
    input clk,
    input [0:199] boardMemory, 
    output fullLine, 
    output [0:19] fullLines
);
reg fullLine;
reg [0:19]fullLines;

always@(posedge clk) begin
    fullLine <= fullLines[0] | fullLines[1] | fullLines[2] | fullLines[3] | fullLines[4] | fullLines[5] | fullLines[6] | fullLines[7] | fullLines[8] | fullLines[9] |
                fullLines[10] | fullLines[11] | fullLines[12] | fullLines[13] | fullLines[14] | fullLines[15] | fullLines[16] | fullLines[17] | fullLines[18] | fullLines[19];
end

always@(*) begin
    // line1
    fullLines[0] = boardMemory[0] & boardMemory[1] & boardMemory[2] & boardMemory[3] & boardMemory[4]  & boardMemory[5]  & boardMemory[6]  & boardMemory[7]  & boardMemory[8] & boardMemory[9];
    fullLines[1] = boardMemory[10] & boardMemory[11] & boardMemory[12] & boardMemory[13] & boardMemory[14]  & boardMemory[15]  & boardMemory[16]  & boardMemory[17]  & boardMemory[18] & boardMemory[19];
    fullLines[2] = boardMemory[20] & boardMemory[21] & boardMemory[22] & boardMemory[23] & boardMemory[24]  & boardMemory[25]  & boardMemory[26]  & boardMemory[27]  & boardMemory[28] & boardMemory[29];
    fullLines[3] = boardMemory[30] & boardMemory[31] & boardMemory[32] & boardMemory[33] & boardMemory[34]  & boardMemory[35]  & boardMemory[36]  & boardMemory[37]  & boardMemory[38] & boardMemory[39];
    fullLines[4] = boardMemory[40] & boardMemory[41] & boardMemory[42] & boardMemory[43] & boardMemory[44]  & boardMemory[45]  & boardMemory[46]  & boardMemory[47]  & boardMemory[48] & boardMemory[49];
    fullLines[5] = boardMemory[50] & boardMemory[51] & boardMemory[52] & boardMemory[53] & boardMemory[54]  & boardMemory[55]  & boardMemory[56]  & boardMemory[57]  & boardMemory[58] & boardMemory[59];
    fullLines[6] = boardMemory[60] & boardMemory[61] & boardMemory[62] & boardMemory[63] & boardMemory[64]  & boardMemory[65]  & boardMemory[66]  & boardMemory[67]  & boardMemory[68] & boardMemory[69];
    fullLines[7] = boardMemory[70] & boardMemory[71] & boardMemory[72] & boardMemory[73] & boardMemory[74]  & boardMemory[75]  & boardMemory[76]  & boardMemory[77]  & boardMemory[78] & boardMemory[79];
    fullLines[8] = boardMemory[80] & boardMemory[81] & boardMemory[82] & boardMemory[83] & boardMemory[84]  & boardMemory[85]  & boardMemory[86]  & boardMemory[87]  & boardMemory[88] & boardMemory[89];
    fullLines[9] = boardMemory[90] & boardMemory[91] & boardMemory[92] & boardMemory[93] & boardMemory[94]  & boardMemory[95]  & boardMemory[96]  & boardMemory[97]  & boardMemory[98] & boardMemory[99];
    fullLines[10] = boardMemory[100] & boardMemory[101] & boardMemory[102] & boardMemory[103] & boardMemory[104]  & boardMemory[105]  & boardMemory[106]  & boardMemory[107]  & boardMemory[108] & boardMemory[109];
    fullLines[11] = boardMemory[110] & boardMemory[111] & boardMemory[112] & boardMemory[113] & boardMemory[114]  & boardMemory[115]  & boardMemory[116]  & boardMemory[117]  & boardMemory[118] & boardMemory[119];
    fullLines[12] = boardMemory[120] & boardMemory[121] & boardMemory[122] & boardMemory[123] & boardMemory[124]  & boardMemory[125]  & boardMemory[126]  & boardMemory[127]  & boardMemory[128] & boardMemory[129];
    fullLines[13] = boardMemory[130] & boardMemory[131] & boardMemory[132] & boardMemory[133] & boardMemory[134]  & boardMemory[135]  & boardMemory[136]  & boardMemory[137]  & boardMemory[138] & boardMemory[139];
    fullLines[14] = boardMemory[140] & boardMemory[141] & boardMemory[142] & boardMemory[143] & boardMemory[144]  & boardMemory[145]  & boardMemory[146]  & boardMemory[147]  & boardMemory[148] & boardMemory[149];
    fullLines[15] = boardMemory[150] & boardMemory[151] & boardMemory[152] & boardMemory[153] & boardMemory[154]  & boardMemory[155]  & boardMemory[156]  & boardMemory[157]  & boardMemory[158] & boardMemory[159];
    fullLines[16] = boardMemory[160] & boardMemory[161] & boardMemory[162] & boardMemory[163] & boardMemory[164]  & boardMemory[165]  & boardMemory[166]  & boardMemory[167]  & boardMemory[168] & boardMemory[169];
    fullLines[17] = boardMemory[170] & boardMemory[171] & boardMemory[172] & boardMemory[173] & boardMemory[174]  & boardMemory[175]  & boardMemory[176]  & boardMemory[177]  & boardMemory[178] & boardMemory[179];
    fullLines[18] = boardMemory[180] & boardMemory[181] & boardMemory[182] & boardMemory[183] & boardMemory[184]  & boardMemory[185]  & boardMemory[186]  & boardMemory[187]  & boardMemory[188] & boardMemory[189];
    fullLines[19] = boardMemory[190] & boardMemory[191] & boardMemory[192] & boardMemory[193] & boardMemory[194]  & boardMemory[195]  & boardMemory[196]  & boardMemory[197]  & boardMemory[198] & boardMemory[199];

end

endmodule