module Find_LRU (
	io_usefulness_0_0,
	io_usefulness_0_1,
	io_usefulness_0_2,
	io_usefulness_0_3,
	io_usefulness_1_0,
	io_usefulness_1_1,
	io_usefulness_1_2,
	io_usefulness_1_3,
	io_usefulness_2_0,
	io_usefulness_2_1,
	io_usefulness_2_2,
	io_usefulness_2_3,
	io_usefulness_3_0,
	io_usefulness_3_1,
	io_usefulness_3_2,
	io_usefulness_3_3,
	io_usefulness_4_0,
	io_usefulness_4_1,
	io_usefulness_4_2,
	io_usefulness_4_3,
	io_usefulness_5_0,
	io_usefulness_5_1,
	io_usefulness_5_2,
	io_usefulness_5_3,
	io_usefulness_6_0,
	io_usefulness_6_1,
	io_usefulness_6_2,
	io_usefulness_6_3,
	io_usefulness_7_0,
	io_usefulness_7_1,
	io_usefulness_7_2,
	io_usefulness_7_3,
	io_input_sets,
	io_max_usefulness
);
	input [1:0] io_usefulness_0_0;
	input [1:0] io_usefulness_0_1;
	input [1:0] io_usefulness_0_2;
	input [1:0] io_usefulness_0_3;
	input [1:0] io_usefulness_1_0;
	input [1:0] io_usefulness_1_1;
	input [1:0] io_usefulness_1_2;
	input [1:0] io_usefulness_1_3;
	input [1:0] io_usefulness_2_0;
	input [1:0] io_usefulness_2_1;
	input [1:0] io_usefulness_2_2;
	input [1:0] io_usefulness_2_3;
	input [1:0] io_usefulness_3_0;
	input [1:0] io_usefulness_3_1;
	input [1:0] io_usefulness_3_2;
	input [1:0] io_usefulness_3_3;
	input [1:0] io_usefulness_4_0;
	input [1:0] io_usefulness_4_1;
	input [1:0] io_usefulness_4_2;
	input [1:0] io_usefulness_4_3;
	input [1:0] io_usefulness_5_0;
	input [1:0] io_usefulness_5_1;
	input [1:0] io_usefulness_5_2;
	input [1:0] io_usefulness_5_3;
	input [1:0] io_usefulness_6_0;
	input [1:0] io_usefulness_6_1;
	input [1:0] io_usefulness_6_2;
	input [1:0] io_usefulness_6_3;
	input [1:0] io_usefulness_7_0;
	input [1:0] io_usefulness_7_1;
	input [1:0] io_usefulness_7_2;
	input [1:0] io_usefulness_7_3;
	input [2:0] io_input_sets;
	output wire [1:0] io_max_usefulness;
	wire [15:0] _GEN = {io_usefulness_7_0, io_usefulness_6_0, io_usefulness_5_0, io_usefulness_4_0, io_usefulness_3_0, io_usefulness_2_0, io_usefulness_1_0, io_usefulness_0_0};
	wire [15:0] _GEN_0 = {io_usefulness_7_1, io_usefulness_6_1, io_usefulness_5_1, io_usefulness_4_1, io_usefulness_3_1, io_usefulness_2_1, io_usefulness_1_1, io_usefulness_0_1};
	wire [15:0] _GEN_1 = {io_usefulness_7_2, io_usefulness_6_2, io_usefulness_5_2, io_usefulness_4_2, io_usefulness_3_2, io_usefulness_2_2, io_usefulness_1_2, io_usefulness_0_2};
	wire [15:0] _GEN_2 = {io_usefulness_7_3, io_usefulness_6_3, io_usefulness_5_3, io_usefulness_4_3, io_usefulness_3_3, io_usefulness_2_3, io_usefulness_1_3, io_usefulness_0_3};
	wire _lruPair_T_2 = _GEN[io_input_sets * 2+:2] >= _GEN_0[io_input_sets * 2+:2];
	wire [1:0] _lruPair_T_1 = (_lruPair_T_2 ? _GEN[io_input_sets * 2+:2] : _GEN_0[io_input_sets * 2+:2]);
	wire _lruPair_T_6 = _lruPair_T_1 >= _GEN_1[io_input_sets * 2+:2];
	assign io_max_usefulness = ((_lruPair_T_6 ? _lruPair_T_1 : _GEN_1[io_input_sets * 2+:2]) >= _GEN_2[io_input_sets * 2+:2] ? (_lruPair_T_6 ? {1'h0, ~_lruPair_T_2} : 2'h2) : 2'h3);
endmodule
module Update_Usefulness (
	io_usefulness_0_0,
	io_usefulness_0_1,
	io_usefulness_0_2,
	io_usefulness_0_3,
	io_usefulness_1_0,
	io_usefulness_1_1,
	io_usefulness_1_2,
	io_usefulness_1_3,
	io_usefulness_2_0,
	io_usefulness_2_1,
	io_usefulness_2_2,
	io_usefulness_2_3,
	io_usefulness_3_0,
	io_usefulness_3_1,
	io_usefulness_3_2,
	io_usefulness_3_3,
	io_usefulness_4_0,
	io_usefulness_4_1,
	io_usefulness_4_2,
	io_usefulness_4_3,
	io_usefulness_5_0,
	io_usefulness_5_1,
	io_usefulness_5_2,
	io_usefulness_5_3,
	io_usefulness_6_0,
	io_usefulness_6_1,
	io_usefulness_6_2,
	io_usefulness_6_3,
	io_usefulness_7_0,
	io_usefulness_7_1,
	io_usefulness_7_2,
	io_usefulness_7_3,
	io_input_sets,
	io_input_recently_updated,
	io_updated_usefulness_arr_0,
	io_updated_usefulness_arr_1,
	io_updated_usefulness_arr_2,
	io_updated_usefulness_arr_3
);
	input [1:0] io_usefulness_0_0;
	input [1:0] io_usefulness_0_1;
	input [1:0] io_usefulness_0_2;
	input [1:0] io_usefulness_0_3;
	input [1:0] io_usefulness_1_0;
	input [1:0] io_usefulness_1_1;
	input [1:0] io_usefulness_1_2;
	input [1:0] io_usefulness_1_3;
	input [1:0] io_usefulness_2_0;
	input [1:0] io_usefulness_2_1;
	input [1:0] io_usefulness_2_2;
	input [1:0] io_usefulness_2_3;
	input [1:0] io_usefulness_3_0;
	input [1:0] io_usefulness_3_1;
	input [1:0] io_usefulness_3_2;
	input [1:0] io_usefulness_3_3;
	input [1:0] io_usefulness_4_0;
	input [1:0] io_usefulness_4_1;
	input [1:0] io_usefulness_4_2;
	input [1:0] io_usefulness_4_3;
	input [1:0] io_usefulness_5_0;
	input [1:0] io_usefulness_5_1;
	input [1:0] io_usefulness_5_2;
	input [1:0] io_usefulness_5_3;
	input [1:0] io_usefulness_6_0;
	input [1:0] io_usefulness_6_1;
	input [1:0] io_usefulness_6_2;
	input [1:0] io_usefulness_6_3;
	input [1:0] io_usefulness_7_0;
	input [1:0] io_usefulness_7_1;
	input [1:0] io_usefulness_7_2;
	input [1:0] io_usefulness_7_3;
	input [2:0] io_input_sets;
	input [1:0] io_input_recently_updated;
	output wire [1:0] io_updated_usefulness_arr_0;
	output wire [1:0] io_updated_usefulness_arr_1;
	output wire [1:0] io_updated_usefulness_arr_2;
	output wire [1:0] io_updated_usefulness_arr_3;
	wire [15:0] _GEN = {io_usefulness_7_0, io_usefulness_6_0, io_usefulness_5_0, io_usefulness_4_0, io_usefulness_3_0, io_usefulness_2_0, io_usefulness_1_0, io_usefulness_0_0};
	wire [15:0] _GEN_0 = {io_usefulness_7_1, io_usefulness_6_1, io_usefulness_5_1, io_usefulness_4_1, io_usefulness_3_1, io_usefulness_2_1, io_usefulness_1_1, io_usefulness_0_1};
	wire [15:0] _GEN_1 = {io_usefulness_7_2, io_usefulness_6_2, io_usefulness_5_2, io_usefulness_4_2, io_usefulness_3_2, io_usefulness_2_2, io_usefulness_1_2, io_usefulness_0_2};
	wire [15:0] _GEN_2 = {io_usefulness_7_3, io_usefulness_6_3, io_usefulness_5_3, io_usefulness_4_3, io_usefulness_3_3, io_usefulness_2_3, io_usefulness_1_3, io_usefulness_0_3};
	wire [7:0] _GEN_3 = {_GEN_2[io_input_sets * 2+:2], _GEN_1[io_input_sets * 2+:2], _GEN_0[io_input_sets * 2+:2], _GEN[io_input_sets * 2+:2]};
	assign io_updated_usefulness_arr_0 = (io_input_recently_updated == 2'h0 ? 2'h0 : (_GEN[io_input_sets * 2+:2] < _GEN_3[io_input_recently_updated * 2+:2] ? _GEN[io_input_sets * 2+:2] + 2'h1 : _GEN[io_input_sets * 2+:2]));
	assign io_updated_usefulness_arr_1 = (io_input_recently_updated == 2'h1 ? 2'h0 : (_GEN_0[io_input_sets * 2+:2] < _GEN_3[io_input_recently_updated * 2+:2] ? _GEN_0[io_input_sets * 2+:2] + 2'h1 : _GEN_0[io_input_sets * 2+:2]));
	assign io_updated_usefulness_arr_2 = (io_input_recently_updated == 2'h2 ? 2'h0 : (_GEN_1[io_input_sets * 2+:2] < _GEN_3[io_input_recently_updated * 2+:2] ? _GEN_1[io_input_sets * 2+:2] + 2'h1 : _GEN_1[io_input_sets * 2+:2]));
	assign io_updated_usefulness_arr_3 = (&io_input_recently_updated ? 2'h0 : (_GEN_2[io_input_sets * 2+:2] < _GEN_3[io_input_recently_updated * 2+:2] ? _GEN_2[io_input_sets * 2+:2] + 2'h1 : _GEN_2[io_input_sets * 2+:2]));
endmodule
module Cache (
	clock,
	reset,
	io_w_enable,
	io_data_in,
	io_location,
	io_stalled_inputloc,
	io_stalled_input_wenable,
	io_replacement_incoming,
	io_state,
	io_dirty_out,
	io_data_out,
	io_needs_replacement,
	io_stalled_location,
	io_stalled_wenable,
	io_stalled
);
	input clock;
	input reset;
	input io_w_enable;
	input [511:0] io_data_in;
	input [31:0] io_location;
	input [31:0] io_stalled_inputloc;
	input io_stalled_input_wenable;
	input io_replacement_incoming;
	output wire [2:0] io_state;
	output wire [511:0] io_dirty_out;
	output wire [31:0] io_data_out;
	output wire io_needs_replacement;
	output wire [31:0] io_stalled_location;
	output wire io_stalled_wenable;
	output wire io_stalled;
	wire [1:0] _updateUsefulness_io_updated_usefulness_arr_0;
	wire [1:0] _updateUsefulness_io_updated_usefulness_arr_1;
	wire [1:0] _updateUsefulness_io_updated_usefulness_arr_2;
	wire [1:0] _updateUsefulness_io_updated_usefulness_arr_3;
	wire [1:0] _findLru_io_max_usefulness;
	reg [1:0] usefulness_0_0;
	reg [1:0] usefulness_0_1;
	reg [1:0] usefulness_0_2;
	reg [1:0] usefulness_0_3;
	reg [1:0] usefulness_1_0;
	reg [1:0] usefulness_1_1;
	reg [1:0] usefulness_1_2;
	reg [1:0] usefulness_1_3;
	reg [1:0] usefulness_2_0;
	reg [1:0] usefulness_2_1;
	reg [1:0] usefulness_2_2;
	reg [1:0] usefulness_2_3;
	reg [1:0] usefulness_3_0;
	reg [1:0] usefulness_3_1;
	reg [1:0] usefulness_3_2;
	reg [1:0] usefulness_3_3;
	reg [1:0] usefulness_4_0;
	reg [1:0] usefulness_4_1;
	reg [1:0] usefulness_4_2;
	reg [1:0] usefulness_4_3;
	reg [1:0] usefulness_5_0;
	reg [1:0] usefulness_5_1;
	reg [1:0] usefulness_5_2;
	reg [1:0] usefulness_5_3;
	reg [1:0] usefulness_6_0;
	reg [1:0] usefulness_6_1;
	reg [1:0] usefulness_6_2;
	reg [1:0] usefulness_6_3;
	reg [1:0] usefulness_7_0;
	reg [1:0] usefulness_7_1;
	reg [1:0] usefulness_7_2;
	reg [1:0] usefulness_7_3;
	reg [511:0] infoArray_0_0;
	reg [511:0] infoArray_0_1;
	reg [511:0] infoArray_0_2;
	reg [511:0] infoArray_0_3;
	reg [511:0] infoArray_1_0;
	reg [511:0] infoArray_1_1;
	reg [511:0] infoArray_1_2;
	reg [511:0] infoArray_1_3;
	reg [511:0] infoArray_2_0;
	reg [511:0] infoArray_2_1;
	reg [511:0] infoArray_2_2;
	reg [511:0] infoArray_2_3;
	reg [511:0] infoArray_3_0;
	reg [511:0] infoArray_3_1;
	reg [511:0] infoArray_3_2;
	reg [511:0] infoArray_3_3;
	reg [511:0] infoArray_4_0;
	reg [511:0] infoArray_4_1;
	reg [511:0] infoArray_4_2;
	reg [511:0] infoArray_4_3;
	reg [511:0] infoArray_5_0;
	reg [511:0] infoArray_5_1;
	reg [511:0] infoArray_5_2;
	reg [511:0] infoArray_5_3;
	reg [511:0] infoArray_6_0;
	reg [511:0] infoArray_6_1;
	reg [511:0] infoArray_6_2;
	reg [511:0] infoArray_6_3;
	reg [511:0] infoArray_7_0;
	reg [511:0] infoArray_7_1;
	reg [511:0] infoArray_7_2;
	reg [511:0] infoArray_7_3;
	reg [22:0] tagArray_0_0;
	reg [22:0] tagArray_0_1;
	reg [22:0] tagArray_0_2;
	reg [22:0] tagArray_0_3;
	reg [22:0] tagArray_1_0;
	reg [22:0] tagArray_1_1;
	reg [22:0] tagArray_1_2;
	reg [22:0] tagArray_1_3;
	reg [22:0] tagArray_2_0;
	reg [22:0] tagArray_2_1;
	reg [22:0] tagArray_2_2;
	reg [22:0] tagArray_2_3;
	reg [22:0] tagArray_3_0;
	reg [22:0] tagArray_3_1;
	reg [22:0] tagArray_3_2;
	reg [22:0] tagArray_3_3;
	reg [22:0] tagArray_4_0;
	reg [22:0] tagArray_4_1;
	reg [22:0] tagArray_4_2;
	reg [22:0] tagArray_4_3;
	reg [22:0] tagArray_5_0;
	reg [22:0] tagArray_5_1;
	reg [22:0] tagArray_5_2;
	reg [22:0] tagArray_5_3;
	reg [22:0] tagArray_6_0;
	reg [22:0] tagArray_6_1;
	reg [22:0] tagArray_6_2;
	reg [22:0] tagArray_6_3;
	reg [22:0] tagArray_7_0;
	reg [22:0] tagArray_7_1;
	reg [22:0] tagArray_7_2;
	reg [22:0] tagArray_7_3;
	reg validBits_0_0;
	reg validBits_0_1;
	reg validBits_0_2;
	reg validBits_0_3;
	reg validBits_1_0;
	reg validBits_1_1;
	reg validBits_1_2;
	reg validBits_1_3;
	reg validBits_2_0;
	reg validBits_2_1;
	reg validBits_2_2;
	reg validBits_2_3;
	reg validBits_3_0;
	reg validBits_3_1;
	reg validBits_3_2;
	reg validBits_3_3;
	reg validBits_4_0;
	reg validBits_4_1;
	reg validBits_4_2;
	reg validBits_4_3;
	reg validBits_5_0;
	reg validBits_5_1;
	reg validBits_5_2;
	reg validBits_5_3;
	reg validBits_6_0;
	reg validBits_6_1;
	reg validBits_6_2;
	reg validBits_6_3;
	reg validBits_7_0;
	reg validBits_7_1;
	reg validBits_7_2;
	reg validBits_7_3;
	reg replacement_indicator;
	reg [2:0] state;
	reg [31:0] dataout;
	reg [31:0] stalledLocationReg;
	reg stalledReg;
	reg stalled_w_enable_Reg;
	always @(posedge clock) begin : sv2v_autoblock_1
		reg [183:0] _GEN;
		reg hit_per_way_1;
		reg [183:0] _GEN_0;
		reg hit_per_way_2;
		reg [183:0] _GEN_1;
		reg hit_per_way_3;
		reg [183:0] _GEN_2;
		reg hit_found;
		reg [1:0] hit;
		reg _GEN_3;
		reg _GEN_4;
		reg _GEN_5;
		reg _GEN_6;
		reg _GEN_7;
		reg _GEN_8;
		reg _GEN_9;
		reg _GEN_10;
		reg _GEN_11;
		reg _GEN_12;
		reg _GEN_13;
		reg _GEN_14;
		reg _GEN_15;
		reg _GEN_16;
		reg _GEN_17;
		reg _GEN_18;
		reg _GEN_19;
		reg _GEN_20;
		reg _GEN_21;
		reg _GEN_22;
		reg _GEN_23;
		reg _GEN_24;
		reg _GEN_25;
		reg _GEN_26;
		reg _GEN_27;
		reg _GEN_28;
		reg _GEN_29;
		reg _GEN_30;
		reg _GEN_31;
		reg _GEN_32;
		reg _GEN_33;
		reg _GEN_34;
		reg _GEN_35;
		reg _GEN_36;
		reg _GEN_37;
		reg _GEN_38;
		reg _GEN_39;
		reg _GEN_40;
		reg _GEN_41;
		reg _GEN_42;
		reg _GEN_43;
		reg _GEN_44;
		reg _GEN_45;
		reg _GEN_46;
		reg _GEN_47;
		reg _GEN_48;
		reg _GEN_49;
		reg _GEN_50;
		reg _GEN_51;
		reg _GEN_52;
		reg _GEN_53;
		reg _GEN_54;
		reg _GEN_55;
		reg _GEN_56;
		reg _GEN_57;
		reg _GEN_58;
		reg _GEN_59;
		reg _GEN_60;
		reg _GEN_61;
		reg _GEN_62;
		reg _GEN_63;
		reg _GEN_64;
		reg _GEN_65;
		reg _GEN_66;
		reg _GEN_67;
		reg _GEN_68;
		reg _GEN_69;
		reg _GEN_70;
		reg _GEN_71;
		reg _GEN_72;
		reg _GEN_73;
		reg _GEN_74;
		reg _GEN_75;
		reg _GEN_76;
		reg _GEN_77;
		reg _GEN_78;
		reg _GEN_79;
		reg _GEN_80;
		reg _GEN_81;
		reg _GEN_82;
		reg _GEN_83;
		reg _GEN_84;
		reg _GEN_85;
		_GEN_51 = _findLru_io_max_usefulness == 2'h0;
		_GEN_53 = _findLru_io_max_usefulness == 2'h1;
		_GEN_55 = _findLru_io_max_usefulness == 2'h2;
		_GEN = {tagArray_7_1, tagArray_6_1, tagArray_5_1, tagArray_4_1, tagArray_3_1, tagArray_2_1, tagArray_1_1, tagArray_0_1};
		hit_per_way_1 = _GEN[io_location[8:6] * 23+:23] == io_location[31:9];
		_GEN_0 = {tagArray_7_2, tagArray_6_2, tagArray_5_2, tagArray_4_2, tagArray_3_2, tagArray_2_2, tagArray_1_2, tagArray_0_2};
		hit_per_way_2 = _GEN_0[io_location[8:6] * 23+:23] == io_location[31:9];
		_GEN_1 = {tagArray_7_3, tagArray_6_3, tagArray_5_3, tagArray_4_3, tagArray_3_3, tagArray_2_3, tagArray_1_3, tagArray_0_3};
		hit_per_way_3 = _GEN_1[io_location[8:6] * 23+:23] == io_location[31:9];
		_GEN_2 = {tagArray_7_0, tagArray_6_0, tagArray_5_0, tagArray_4_0, tagArray_3_0, tagArray_2_0, tagArray_1_0, tagArray_0_0};
		hit_found = (((_GEN_2[io_location[8:6] * 23+:23] == io_location[31:9]) | hit_per_way_1) | hit_per_way_2) | hit_per_way_3;
		hit = {|{hit_per_way_3, hit_per_way_2}, hit_per_way_3 | hit_per_way_1};
		_GEN_3 = state == 3'h0;
		_GEN_4 = state == 3'h1;
		_GEN_5 = state == 3'h3;
		_GEN_6 = io_location[8:6] == 3'h0;
		_GEN_7 = hit == 2'h0;
		_GEN_8 = _GEN_6 & _GEN_7;
		_GEN_9 = hit == 2'h1;
		_GEN_10 = _GEN_6 & _GEN_9;
		_GEN_11 = hit == 2'h2;
		_GEN_12 = _GEN_6 & _GEN_11;
		_GEN_13 = _GEN_6 & (&hit);
		_GEN_14 = io_location[8:6] == 3'h1;
		_GEN_15 = _GEN_14 & _GEN_7;
		_GEN_16 = _GEN_14 & _GEN_9;
		_GEN_17 = _GEN_14 & _GEN_11;
		_GEN_18 = _GEN_14 & (&hit);
		_GEN_19 = io_location[8:6] == 3'h2;
		_GEN_20 = _GEN_19 & _GEN_7;
		_GEN_21 = _GEN_19 & _GEN_9;
		_GEN_22 = _GEN_19 & _GEN_11;
		_GEN_23 = _GEN_19 & (&hit);
		_GEN_24 = io_location[8:6] == 3'h3;
		_GEN_25 = _GEN_24 & _GEN_7;
		_GEN_26 = _GEN_24 & _GEN_9;
		_GEN_27 = _GEN_24 & _GEN_11;
		_GEN_28 = _GEN_24 & (&hit);
		_GEN_29 = io_location[8:6] == 3'h4;
		_GEN_30 = _GEN_29 & _GEN_7;
		_GEN_31 = _GEN_29 & _GEN_9;
		_GEN_32 = _GEN_29 & _GEN_11;
		_GEN_33 = _GEN_29 & (&hit);
		_GEN_34 = io_location[8:6] == 3'h5;
		_GEN_35 = _GEN_34 & _GEN_7;
		_GEN_36 = _GEN_34 & _GEN_9;
		_GEN_37 = _GEN_34 & _GEN_11;
		_GEN_38 = _GEN_34 & (&hit);
		_GEN_39 = io_location[8:6] == 3'h6;
		_GEN_40 = _GEN_39 & _GEN_7;
		_GEN_41 = _GEN_39 & _GEN_9;
		_GEN_42 = _GEN_39 & _GEN_11;
		_GEN_43 = _GEN_39 & (&hit);
		_GEN_44 = &io_location[8:6] & _GEN_7;
		_GEN_45 = &io_location[8:6] & _GEN_9;
		_GEN_46 = &io_location[8:6] & _GEN_11;
		_GEN_47 = &io_location[8:6] & (&hit);
		_GEN_48 = _GEN_3 | _GEN_4;
		_GEN_49 = state == 3'h2;
		_GEN_50 = state == 3'h4;
		_GEN_52 = _GEN_6 & _GEN_51;
		_GEN_54 = _GEN_6 & _GEN_53;
		_GEN_56 = _GEN_6 & _GEN_55;
		_GEN_57 = _GEN_6 & (&_findLru_io_max_usefulness);
		_GEN_58 = _GEN_14 & _GEN_51;
		_GEN_59 = _GEN_14 & _GEN_53;
		_GEN_60 = _GEN_14 & _GEN_55;
		_GEN_61 = _GEN_14 & (&_findLru_io_max_usefulness);
		_GEN_62 = _GEN_19 & _GEN_51;
		_GEN_63 = _GEN_19 & _GEN_53;
		_GEN_64 = _GEN_19 & _GEN_55;
		_GEN_65 = _GEN_19 & (&_findLru_io_max_usefulness);
		_GEN_66 = _GEN_24 & _GEN_51;
		_GEN_67 = _GEN_24 & _GEN_53;
		_GEN_68 = _GEN_24 & _GEN_55;
		_GEN_69 = _GEN_24 & (&_findLru_io_max_usefulness);
		_GEN_70 = _GEN_29 & _GEN_51;
		_GEN_71 = _GEN_29 & _GEN_53;
		_GEN_72 = _GEN_29 & _GEN_55;
		_GEN_73 = _GEN_29 & (&_findLru_io_max_usefulness);
		_GEN_74 = _GEN_34 & _GEN_51;
		_GEN_75 = _GEN_34 & _GEN_53;
		_GEN_76 = _GEN_34 & _GEN_55;
		_GEN_77 = _GEN_34 & (&_findLru_io_max_usefulness);
		_GEN_78 = _GEN_39 & _GEN_51;
		_GEN_79 = _GEN_39 & _GEN_53;
		_GEN_80 = _GEN_39 & _GEN_55;
		_GEN_81 = _GEN_39 & (&_findLru_io_max_usefulness);
		_GEN_82 = &io_location[8:6] & _GEN_51;
		_GEN_83 = &io_location[8:6] & _GEN_53;
		_GEN_84 = &io_location[8:6] & _GEN_55;
		_GEN_85 = &io_location[8:6] & (&_findLru_io_max_usefulness);
		if ((((_GEN_3 | _GEN_4) | _GEN_5) | _GEN_49) | ~_GEN_50)
			;
		else if (hit_found) begin
			if (_GEN_8)
				usefulness_0_0 <= 2'h0;
			if (_GEN_10)
				usefulness_0_1 <= 2'h0;
			if (_GEN_12)
				usefulness_0_2 <= 2'h0;
			if (_GEN_13)
				usefulness_0_3 <= 2'h0;
			if (_GEN_15)
				usefulness_1_0 <= 2'h0;
			if (_GEN_16)
				usefulness_1_1 <= 2'h0;
			if (_GEN_17)
				usefulness_1_2 <= 2'h0;
			if (_GEN_18)
				usefulness_1_3 <= 2'h0;
			if (_GEN_20)
				usefulness_2_0 <= 2'h0;
			if (_GEN_21)
				usefulness_2_1 <= 2'h0;
			if (_GEN_22)
				usefulness_2_2 <= 2'h0;
			if (_GEN_23)
				usefulness_2_3 <= 2'h0;
			if (_GEN_25)
				usefulness_3_0 <= 2'h0;
			if (_GEN_26)
				usefulness_3_1 <= 2'h0;
			if (_GEN_27)
				usefulness_3_2 <= 2'h0;
			if (_GEN_28)
				usefulness_3_3 <= 2'h0;
			if (_GEN_30)
				usefulness_4_0 <= 2'h0;
			if (_GEN_31)
				usefulness_4_1 <= 2'h0;
			if (_GEN_32)
				usefulness_4_2 <= 2'h0;
			if (_GEN_33)
				usefulness_4_3 <= 2'h0;
			if (_GEN_35)
				usefulness_5_0 <= 2'h0;
			if (_GEN_36)
				usefulness_5_1 <= 2'h0;
			if (_GEN_37)
				usefulness_5_2 <= 2'h0;
			if (_GEN_38)
				usefulness_5_3 <= 2'h0;
			if (_GEN_40)
				usefulness_6_0 <= 2'h0;
			if (_GEN_41)
				usefulness_6_1 <= 2'h0;
			if (_GEN_42)
				usefulness_6_2 <= 2'h0;
			if (_GEN_43)
				usefulness_6_3 <= 2'h0;
			if (_GEN_44)
				usefulness_7_0 <= 2'h0;
			if (_GEN_45)
				usefulness_7_1 <= 2'h0;
			if (_GEN_46)
				usefulness_7_2 <= 2'h0;
			if (_GEN_47)
				usefulness_7_3 <= 2'h0;
		end
		else begin
			if (_GEN_6) begin
				usefulness_0_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_0_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_0_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_0_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (_GEN_14) begin
				usefulness_1_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_1_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_1_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_1_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (_GEN_19) begin
				usefulness_2_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_2_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_2_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_2_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (_GEN_24) begin
				usefulness_3_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_3_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_3_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_3_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (_GEN_29) begin
				usefulness_4_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_4_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_4_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_4_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (_GEN_34) begin
				usefulness_5_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_5_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_5_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_5_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (_GEN_39) begin
				usefulness_6_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_6_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_6_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_6_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
			if (&io_location[8:6]) begin
				usefulness_7_0 <= _updateUsefulness_io_updated_usefulness_arr_0;
				usefulness_7_1 <= _updateUsefulness_io_updated_usefulness_arr_1;
				usefulness_7_2 <= _updateUsefulness_io_updated_usefulness_arr_2;
				usefulness_7_3 <= _updateUsefulness_io_updated_usefulness_arr_3;
			end
		end
		if (_GEN_48 | ~(_GEN_5 & _GEN_8))
			;
		else
			infoArray_0_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_10))
			;
		else
			infoArray_0_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_12))
			;
		else
			infoArray_0_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_13))
			;
		else
			infoArray_0_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_15))
			;
		else
			infoArray_1_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_16))
			;
		else
			infoArray_1_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_17))
			;
		else
			infoArray_1_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_18))
			;
		else
			infoArray_1_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_20))
			;
		else
			infoArray_2_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_21))
			;
		else
			infoArray_2_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_22))
			;
		else
			infoArray_2_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_23))
			;
		else
			infoArray_2_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_25))
			;
		else
			infoArray_3_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_26))
			;
		else
			infoArray_3_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_27))
			;
		else
			infoArray_3_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_28))
			;
		else
			infoArray_3_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_30))
			;
		else
			infoArray_4_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_31))
			;
		else
			infoArray_4_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_32))
			;
		else
			infoArray_4_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_33))
			;
		else
			infoArray_4_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_35))
			;
		else
			infoArray_5_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_36))
			;
		else
			infoArray_5_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_37))
			;
		else
			infoArray_5_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_38))
			;
		else
			infoArray_5_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_40))
			;
		else
			infoArray_6_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_41))
			;
		else
			infoArray_6_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_42))
			;
		else
			infoArray_6_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_43))
			;
		else
			infoArray_6_3 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_44))
			;
		else
			infoArray_7_0 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_45))
			;
		else
			infoArray_7_1 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_46))
			;
		else
			infoArray_7_2 <= io_data_in;
		if (_GEN_48 | ~(_GEN_5 & _GEN_47))
			;
		else
			infoArray_7_3 <= io_data_in;
		if (~_GEN_48) begin
			if (_GEN_5) begin
				if (_GEN_8)
					tagArray_0_0 <= io_location[31:9];
				if (_GEN_10)
					tagArray_0_1 <= io_location[31:9];
				if (_GEN_12)
					tagArray_0_2 <= io_location[31:9];
				if (_GEN_13)
					tagArray_0_3 <= io_location[31:9];
				if (_GEN_15)
					tagArray_1_0 <= io_location[31:9];
				if (_GEN_16)
					tagArray_1_1 <= io_location[31:9];
				if (_GEN_17)
					tagArray_1_2 <= io_location[31:9];
				if (_GEN_18)
					tagArray_1_3 <= io_location[31:9];
				if (_GEN_20)
					tagArray_2_0 <= io_location[31:9];
				if (_GEN_21)
					tagArray_2_1 <= io_location[31:9];
				if (_GEN_22)
					tagArray_2_2 <= io_location[31:9];
				if (_GEN_23)
					tagArray_2_3 <= io_location[31:9];
				if (_GEN_25)
					tagArray_3_0 <= io_location[31:9];
				if (_GEN_26)
					tagArray_3_1 <= io_location[31:9];
				if (_GEN_27)
					tagArray_3_2 <= io_location[31:9];
				if (_GEN_28)
					tagArray_3_3 <= io_location[31:9];
				if (_GEN_30)
					tagArray_4_0 <= io_location[31:9];
				if (_GEN_31)
					tagArray_4_1 <= io_location[31:9];
				if (_GEN_32)
					tagArray_4_2 <= io_location[31:9];
				if (_GEN_33)
					tagArray_4_3 <= io_location[31:9];
				if (_GEN_35)
					tagArray_5_0 <= io_location[31:9];
				if (_GEN_36)
					tagArray_5_1 <= io_location[31:9];
				if (_GEN_37)
					tagArray_5_2 <= io_location[31:9];
				if (_GEN_38)
					tagArray_5_3 <= io_location[31:9];
				if (_GEN_40)
					tagArray_6_0 <= io_location[31:9];
				if (_GEN_41)
					tagArray_6_1 <= io_location[31:9];
				if (_GEN_42)
					tagArray_6_2 <= io_location[31:9];
				if (_GEN_43)
					tagArray_6_3 <= io_location[31:9];
				if (_GEN_44)
					tagArray_7_0 <= io_location[31:9];
				if (_GEN_45)
					tagArray_7_1 <= io_location[31:9];
				if (_GEN_46)
					tagArray_7_2 <= io_location[31:9];
				if (_GEN_47)
					tagArray_7_3 <= io_location[31:9];
			end
			else begin
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_8 : _GEN_52)))
					;
				else
					tagArray_0_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_10 : _GEN_54)))
					;
				else
					tagArray_0_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_12 : _GEN_56)))
					;
				else
					tagArray_0_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_13 : _GEN_57)))
					;
				else
					tagArray_0_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_15 : _GEN_58)))
					;
				else
					tagArray_1_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_16 : _GEN_59)))
					;
				else
					tagArray_1_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_17 : _GEN_60)))
					;
				else
					tagArray_1_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_18 : _GEN_61)))
					;
				else
					tagArray_1_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_20 : _GEN_62)))
					;
				else
					tagArray_2_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_21 : _GEN_63)))
					;
				else
					tagArray_2_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_22 : _GEN_64)))
					;
				else
					tagArray_2_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_23 : _GEN_65)))
					;
				else
					tagArray_2_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_25 : _GEN_66)))
					;
				else
					tagArray_3_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_26 : _GEN_67)))
					;
				else
					tagArray_3_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_27 : _GEN_68)))
					;
				else
					tagArray_3_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_28 : _GEN_69)))
					;
				else
					tagArray_3_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_30 : _GEN_70)))
					;
				else
					tagArray_4_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_31 : _GEN_71)))
					;
				else
					tagArray_4_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_32 : _GEN_72)))
					;
				else
					tagArray_4_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_33 : _GEN_73)))
					;
				else
					tagArray_4_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_35 : _GEN_74)))
					;
				else
					tagArray_5_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_36 : _GEN_75)))
					;
				else
					tagArray_5_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_37 : _GEN_76)))
					;
				else
					tagArray_5_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_38 : _GEN_77)))
					;
				else
					tagArray_5_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_40 : _GEN_78)))
					;
				else
					tagArray_6_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_41 : _GEN_79)))
					;
				else
					tagArray_6_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_42 : _GEN_80)))
					;
				else
					tagArray_6_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_43 : _GEN_81)))
					;
				else
					tagArray_6_3 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_44 : _GEN_82)))
					;
				else
					tagArray_7_0 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_45 : _GEN_83)))
					;
				else
					tagArray_7_1 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_46 : _GEN_84)))
					;
				else
					tagArray_7_2 <= io_location[31:9];
				if (_GEN_49 | ~(_GEN_50 & (hit_found ? _GEN_47 : _GEN_85)))
					;
				else
					tagArray_7_3 <= io_location[31:9];
			end
		end
		if (reset) begin
			validBits_0_0 <= 1'h0;
			validBits_0_1 <= 1'h0;
			validBits_0_2 <= 1'h0;
			validBits_0_3 <= 1'h0;
			validBits_1_0 <= 1'h0;
			validBits_1_1 <= 1'h0;
			validBits_1_2 <= 1'h0;
			validBits_1_3 <= 1'h0;
			validBits_2_0 <= 1'h0;
			validBits_2_1 <= 1'h0;
			validBits_2_2 <= 1'h0;
			validBits_2_3 <= 1'h0;
			validBits_3_0 <= 1'h0;
			validBits_3_1 <= 1'h0;
			validBits_3_2 <= 1'h0;
			validBits_3_3 <= 1'h0;
			validBits_4_0 <= 1'h0;
			validBits_4_1 <= 1'h0;
			validBits_4_2 <= 1'h0;
			validBits_4_3 <= 1'h0;
			validBits_5_0 <= 1'h0;
			validBits_5_1 <= 1'h0;
			validBits_5_2 <= 1'h0;
			validBits_5_3 <= 1'h0;
			validBits_6_0 <= 1'h0;
			validBits_6_1 <= 1'h0;
			validBits_6_2 <= 1'h0;
			validBits_6_3 <= 1'h0;
			validBits_7_0 <= 1'h0;
			validBits_7_1 <= 1'h0;
			validBits_7_2 <= 1'h0;
			validBits_7_3 <= 1'h0;
			replacement_indicator <= 1'h0;
			state <= 3'h0;
			dataout <= 32'h00000000;
			stalledLocationReg <= 32'h00000000;
			stalledReg <= 1'h0;
			stalled_w_enable_Reg <= 1'h0;
		end
		else begin : sv2v_autoblock_2
			reg [7:0] _GEN_86;
			reg [7:0] _GEN_87;
			reg [7:0] _GEN_88;
			reg [7:0] _GEN_89;
			reg [3:0] _GEN_90;
			reg _GEN_91;
			reg [23:0] _GEN_92;
			_GEN_86 = {validBits_7_3, validBits_6_3, validBits_5_3, validBits_4_3, validBits_3_3, validBits_2_3, validBits_1_3, validBits_0_3};
			_GEN_87 = {validBits_7_2, validBits_6_2, validBits_5_2, validBits_4_2, validBits_3_2, validBits_2_2, validBits_1_2, validBits_0_2};
			_GEN_88 = {validBits_7_1, validBits_6_1, validBits_5_1, validBits_4_1, validBits_3_1, validBits_2_1, validBits_1_1, validBits_0_1};
			_GEN_89 = {validBits_7_0, validBits_6_0, validBits_5_0, validBits_4_0, validBits_3_0, validBits_2_0, validBits_1_0, validBits_0_0};
			_GEN_90 = {_GEN_86[io_location[8:6]], _GEN_87[io_location[8:6]], _GEN_88[io_location[8:6]], _GEN_89[io_location[8:6]]};
			_GEN_91 = hit_found & _GEN_90[hit];
			if (~_GEN_48) begin : sv2v_autoblock_3
				reg _GEN_93;
				reg _GEN_94;
				reg _GEN_95;
				reg _GEN_96;
				reg _GEN_97;
				reg _GEN_98;
				reg _GEN_99;
				reg _GEN_100;
				reg _GEN_101;
				reg _GEN_102;
				reg _GEN_103;
				reg _GEN_104;
				reg _GEN_105;
				reg _GEN_106;
				reg _GEN_107;
				reg _GEN_108;
				reg _GEN_109;
				reg _GEN_110;
				reg _GEN_111;
				reg _GEN_112;
				reg _GEN_113;
				reg _GEN_114;
				reg _GEN_115;
				reg _GEN_116;
				reg _GEN_117;
				reg _GEN_118;
				reg _GEN_119;
				reg _GEN_120;
				reg _GEN_121;
				reg _GEN_122;
				reg _GEN_123;
				reg _GEN_124;
				_GEN_93 = _GEN_8 | validBits_0_0;
				_GEN_94 = _GEN_10 | validBits_0_1;
				_GEN_95 = _GEN_12 | validBits_0_2;
				_GEN_96 = _GEN_13 | validBits_0_3;
				_GEN_97 = _GEN_15 | validBits_1_0;
				_GEN_98 = _GEN_16 | validBits_1_1;
				_GEN_99 = _GEN_17 | validBits_1_2;
				_GEN_100 = _GEN_18 | validBits_1_3;
				_GEN_101 = _GEN_20 | validBits_2_0;
				_GEN_102 = _GEN_21 | validBits_2_1;
				_GEN_103 = _GEN_22 | validBits_2_2;
				_GEN_104 = _GEN_23 | validBits_2_3;
				_GEN_105 = _GEN_25 | validBits_3_0;
				_GEN_106 = _GEN_26 | validBits_3_1;
				_GEN_107 = _GEN_27 | validBits_3_2;
				_GEN_108 = _GEN_28 | validBits_3_3;
				_GEN_109 = _GEN_30 | validBits_4_0;
				_GEN_110 = _GEN_31 | validBits_4_1;
				_GEN_111 = _GEN_32 | validBits_4_2;
				_GEN_112 = _GEN_33 | validBits_4_3;
				_GEN_113 = _GEN_35 | validBits_5_0;
				_GEN_114 = _GEN_36 | validBits_5_1;
				_GEN_115 = _GEN_37 | validBits_5_2;
				_GEN_116 = _GEN_38 | validBits_5_3;
				_GEN_117 = _GEN_40 | validBits_6_0;
				_GEN_118 = _GEN_41 | validBits_6_1;
				_GEN_119 = _GEN_42 | validBits_6_2;
				_GEN_120 = _GEN_43 | validBits_6_3;
				_GEN_121 = _GEN_44 | validBits_7_0;
				_GEN_122 = _GEN_45 | validBits_7_1;
				_GEN_123 = _GEN_46 | validBits_7_2;
				_GEN_124 = _GEN_47 | validBits_7_3;
				if (_GEN_5) begin
					validBits_0_0 <= _GEN_93;
					validBits_0_1 <= _GEN_94;
					validBits_0_2 <= _GEN_95;
					validBits_0_3 <= _GEN_96;
					validBits_1_0 <= _GEN_97;
					validBits_1_1 <= _GEN_98;
					validBits_1_2 <= _GEN_99;
					validBits_1_3 <= _GEN_100;
					validBits_2_0 <= _GEN_101;
					validBits_2_1 <= _GEN_102;
					validBits_2_2 <= _GEN_103;
					validBits_2_3 <= _GEN_104;
					validBits_3_0 <= _GEN_105;
					validBits_3_1 <= _GEN_106;
					validBits_3_2 <= _GEN_107;
					validBits_3_3 <= _GEN_108;
					validBits_4_0 <= _GEN_109;
					validBits_4_1 <= _GEN_110;
					validBits_4_2 <= _GEN_111;
					validBits_4_3 <= _GEN_112;
					validBits_5_0 <= _GEN_113;
					validBits_5_1 <= _GEN_114;
					validBits_5_2 <= _GEN_115;
					validBits_5_3 <= _GEN_116;
					validBits_6_0 <= _GEN_117;
					validBits_6_1 <= _GEN_118;
					validBits_6_2 <= _GEN_119;
					validBits_6_3 <= _GEN_120;
					validBits_7_0 <= _GEN_121;
					validBits_7_1 <= _GEN_122;
					validBits_7_2 <= _GEN_123;
					validBits_7_3 <= _GEN_124;
				end
				else if (_GEN_49 | ~_GEN_50)
					;
				else if (hit_found) begin
					validBits_0_0 <= _GEN_93;
					validBits_0_1 <= _GEN_94;
					validBits_0_2 <= _GEN_95;
					validBits_0_3 <= _GEN_96;
					validBits_1_0 <= _GEN_97;
					validBits_1_1 <= _GEN_98;
					validBits_1_2 <= _GEN_99;
					validBits_1_3 <= _GEN_100;
					validBits_2_0 <= _GEN_101;
					validBits_2_1 <= _GEN_102;
					validBits_2_2 <= _GEN_103;
					validBits_2_3 <= _GEN_104;
					validBits_3_0 <= _GEN_105;
					validBits_3_1 <= _GEN_106;
					validBits_3_2 <= _GEN_107;
					validBits_3_3 <= _GEN_108;
					validBits_4_0 <= _GEN_109;
					validBits_4_1 <= _GEN_110;
					validBits_4_2 <= _GEN_111;
					validBits_4_3 <= _GEN_112;
					validBits_5_0 <= _GEN_113;
					validBits_5_1 <= _GEN_114;
					validBits_5_2 <= _GEN_115;
					validBits_5_3 <= _GEN_116;
					validBits_6_0 <= _GEN_117;
					validBits_6_1 <= _GEN_118;
					validBits_6_2 <= _GEN_119;
					validBits_6_3 <= _GEN_120;
					validBits_7_0 <= _GEN_121;
					validBits_7_1 <= _GEN_122;
					validBits_7_2 <= _GEN_123;
					validBits_7_3 <= _GEN_124;
				end
				else begin
					validBits_0_0 <= _GEN_52 | validBits_0_0;
					validBits_0_1 <= _GEN_54 | validBits_0_1;
					validBits_0_2 <= _GEN_56 | validBits_0_2;
					validBits_0_3 <= _GEN_57 | validBits_0_3;
					validBits_1_0 <= _GEN_58 | validBits_1_0;
					validBits_1_1 <= _GEN_59 | validBits_1_1;
					validBits_1_2 <= _GEN_60 | validBits_1_2;
					validBits_1_3 <= _GEN_61 | validBits_1_3;
					validBits_2_0 <= _GEN_62 | validBits_2_0;
					validBits_2_1 <= _GEN_63 | validBits_2_1;
					validBits_2_2 <= _GEN_64 | validBits_2_2;
					validBits_2_3 <= _GEN_65 | validBits_2_3;
					validBits_3_0 <= _GEN_66 | validBits_3_0;
					validBits_3_1 <= _GEN_67 | validBits_3_1;
					validBits_3_2 <= _GEN_68 | validBits_3_2;
					validBits_3_3 <= _GEN_69 | validBits_3_3;
					validBits_4_0 <= _GEN_70 | validBits_4_0;
					validBits_4_1 <= _GEN_71 | validBits_4_1;
					validBits_4_2 <= _GEN_72 | validBits_4_2;
					validBits_4_3 <= _GEN_73 | validBits_4_3;
					validBits_5_0 <= _GEN_74 | validBits_5_0;
					validBits_5_1 <= _GEN_75 | validBits_5_1;
					validBits_5_2 <= _GEN_76 | validBits_5_2;
					validBits_5_3 <= _GEN_77 | validBits_5_3;
					validBits_6_0 <= _GEN_78 | validBits_6_0;
					validBits_6_1 <= _GEN_79 | validBits_6_1;
					validBits_6_2 <= _GEN_80 | validBits_6_2;
					validBits_6_3 <= _GEN_81 | validBits_6_3;
					validBits_7_0 <= _GEN_82 | validBits_7_0;
					validBits_7_1 <= _GEN_83 | validBits_7_1;
					validBits_7_2 <= _GEN_84 | validBits_7_2;
					validBits_7_3 <= _GEN_85 | validBits_7_3;
				end
			end
			if (_GEN_3) begin
				replacement_indicator <= ~_GEN_91 | (io_w_enable & replacement_indicator);
				stalledReg <= ~_GEN_91 | stalledReg;
			end
			else begin
				replacement_indicator <= ~_GEN_4 & (_GEN_5 | ~_GEN_49 ? replacement_indicator : ~io_replacement_incoming);
				stalledReg <= ((((_GEN_4 | _GEN_5) | _GEN_49) | _GEN_50) | (state != 3'h5)) & stalledReg;
			end
			_GEN_92 = {state, state, 9'h028, (io_replacement_incoming ? 3'h4 : state), 3'h0, (_GEN_91 ? {1'h0, io_w_enable, 1'h1} : 3'h2)};
			state <= _GEN_92[state * 3+:3];
			if (_GEN_3 | ~_GEN_4)
				;
			else begin : sv2v_autoblock_4
				reg [4095:0] _GEN_125;
				reg [4095:0] _GEN_126;
				reg [4095:0] _GEN_127;
				reg [4095:0] _GEN_128;
				reg [2047:0] _GEN_129;
				reg [511:0] _wordsInLine_WIRE;
				reg [511:0] _GEN_130;
				_GEN_125 = {infoArray_7_3, infoArray_6_3, infoArray_5_3, infoArray_4_3, infoArray_3_3, infoArray_2_3, infoArray_1_3, infoArray_0_3};
				_GEN_126 = {infoArray_7_2, infoArray_6_2, infoArray_5_2, infoArray_4_2, infoArray_3_2, infoArray_2_2, infoArray_1_2, infoArray_0_2};
				_GEN_127 = {infoArray_7_1, infoArray_6_1, infoArray_5_1, infoArray_4_1, infoArray_3_1, infoArray_2_1, infoArray_1_1, infoArray_0_1};
				_GEN_128 = {infoArray_7_0, infoArray_6_0, infoArray_5_0, infoArray_4_0, infoArray_3_0, infoArray_2_0, infoArray_1_0, infoArray_0_0};
				_GEN_129 = {_GEN_125[io_location[8:6] * 512+:512], _GEN_126[io_location[8:6] * 512+:512], _GEN_127[io_location[8:6] * 512+:512], _GEN_128[io_location[8:6] * 512+:512]};
				_wordsInLine_WIRE = _GEN_129[hit * 512+:512];
				_GEN_130 = {_wordsInLine_WIRE[511:480], _wordsInLine_WIRE[479:448], _wordsInLine_WIRE[447:416], _wordsInLine_WIRE[415:384], _wordsInLine_WIRE[383:352], _wordsInLine_WIRE[351:320], _wordsInLine_WIRE[319:288], _wordsInLine_WIRE[287:256], _wordsInLine_WIRE[255:224], _wordsInLine_WIRE[223:192], _wordsInLine_WIRE[191:160], _wordsInLine_WIRE[159:128], _wordsInLine_WIRE[127:96], _wordsInLine_WIRE[95:64], _wordsInLine_WIRE[63:32], _wordsInLine_WIRE[31:0]};
				dataout <= _GEN_130[io_location[5:2] * 32+:32];
			end
			if (~_GEN_3 | _GEN_91)
				;
			else begin
				stalledLocationReg <= io_location;
				stalled_w_enable_Reg <= io_w_enable;
			end
		end
	end
	initial begin : sv2v_autoblock_5
		reg [31:0] _RANDOM [0:541];
	end
	Find_LRU findLru(
		.io_usefulness_0_0(usefulness_0_0),
		.io_usefulness_0_1(usefulness_0_1),
		.io_usefulness_0_2(usefulness_0_2),
		.io_usefulness_0_3(usefulness_0_3),
		.io_usefulness_1_0(usefulness_1_0),
		.io_usefulness_1_1(usefulness_1_1),
		.io_usefulness_1_2(usefulness_1_2),
		.io_usefulness_1_3(usefulness_1_3),
		.io_usefulness_2_0(usefulness_2_0),
		.io_usefulness_2_1(usefulness_2_1),
		.io_usefulness_2_2(usefulness_2_2),
		.io_usefulness_2_3(usefulness_2_3),
		.io_usefulness_3_0(usefulness_3_0),
		.io_usefulness_3_1(usefulness_3_1),
		.io_usefulness_3_2(usefulness_3_2),
		.io_usefulness_3_3(usefulness_3_3),
		.io_usefulness_4_0(usefulness_4_0),
		.io_usefulness_4_1(usefulness_4_1),
		.io_usefulness_4_2(usefulness_4_2),
		.io_usefulness_4_3(usefulness_4_3),
		.io_usefulness_5_0(usefulness_5_0),
		.io_usefulness_5_1(usefulness_5_1),
		.io_usefulness_5_2(usefulness_5_2),
		.io_usefulness_5_3(usefulness_5_3),
		.io_usefulness_6_0(usefulness_6_0),
		.io_usefulness_6_1(usefulness_6_1),
		.io_usefulness_6_2(usefulness_6_2),
		.io_usefulness_6_3(usefulness_6_3),
		.io_usefulness_7_0(usefulness_7_0),
		.io_usefulness_7_1(usefulness_7_1),
		.io_usefulness_7_2(usefulness_7_2),
		.io_usefulness_7_3(usefulness_7_3),
		.io_input_sets(io_location[8:6]),
		.io_max_usefulness(_findLru_io_max_usefulness)
	);
	Update_Usefulness updateUsefulness(
		.io_usefulness_0_0(usefulness_0_0),
		.io_usefulness_0_1(usefulness_0_1),
		.io_usefulness_0_2(usefulness_0_2),
		.io_usefulness_0_3(usefulness_0_3),
		.io_usefulness_1_0(usefulness_1_0),
		.io_usefulness_1_1(usefulness_1_1),
		.io_usefulness_1_2(usefulness_1_2),
		.io_usefulness_1_3(usefulness_1_3),
		.io_usefulness_2_0(usefulness_2_0),
		.io_usefulness_2_1(usefulness_2_1),
		.io_usefulness_2_2(usefulness_2_2),
		.io_usefulness_2_3(usefulness_2_3),
		.io_usefulness_3_0(usefulness_3_0),
		.io_usefulness_3_1(usefulness_3_1),
		.io_usefulness_3_2(usefulness_3_2),
		.io_usefulness_3_3(usefulness_3_3),
		.io_usefulness_4_0(usefulness_4_0),
		.io_usefulness_4_1(usefulness_4_1),
		.io_usefulness_4_2(usefulness_4_2),
		.io_usefulness_4_3(usefulness_4_3),
		.io_usefulness_5_0(usefulness_5_0),
		.io_usefulness_5_1(usefulness_5_1),
		.io_usefulness_5_2(usefulness_5_2),
		.io_usefulness_5_3(usefulness_5_3),
		.io_usefulness_6_0(usefulness_6_0),
		.io_usefulness_6_1(usefulness_6_1),
		.io_usefulness_6_2(usefulness_6_2),
		.io_usefulness_6_3(usefulness_6_3),
		.io_usefulness_7_0(usefulness_7_0),
		.io_usefulness_7_1(usefulness_7_1),
		.io_usefulness_7_2(usefulness_7_2),
		.io_usefulness_7_3(usefulness_7_3),
		.io_input_sets(io_location[8:6]),
		.io_input_recently_updated(_findLru_io_max_usefulness),
		.io_updated_usefulness_arr_0(_updateUsefulness_io_updated_usefulness_arr_0),
		.io_updated_usefulness_arr_1(_updateUsefulness_io_updated_usefulness_arr_1),
		.io_updated_usefulness_arr_2(_updateUsefulness_io_updated_usefulness_arr_2),
		.io_updated_usefulness_arr_3(_updateUsefulness_io_updated_usefulness_arr_3)
	);
	assign io_state = state;
	assign io_dirty_out = 512'h0;
	assign io_data_out = dataout;
	assign io_needs_replacement = replacement_indicator;
	assign io_stalled_location = stalledLocationReg;
	assign io_stalled_wenable = stalled_w_enable_Reg;
	assign io_stalled = stalledReg;
endmodule
