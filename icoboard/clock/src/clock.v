module clock (
	input clk, 
	output pmod_other_clk
);
	wire clk_25mhz;
	wire pll_locked;

	SB_PLL40_PAD #(
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.PLLOUT_SELECT("GENCLK"),
		.FDA_FEEDBACK(4'b1111),
		.FDA_RELATIVE(4'b1111),
		.DIVR(4'b0000),
		.DIVF(7'b0001001),
		.DIVQ(3'b010),
		.FILTER_RANGE(3'b101)
	) pll (
		.PACKAGEPIN   (clk       ),
		.PLLOUTGLOBAL (clk_25mhz ),
		.LOCK         (pll_locked),
		.BYPASS       (1'b0      ),
		.RESETB       (1'b1      )
	);

	assign pmod_other_clk = clk_25mhz;
	
endmodule
