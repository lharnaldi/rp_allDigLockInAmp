library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pll is
	port(
		clk_i: in std_logic;
		ref_in: in std_logic_vector (15 downto 0);
		SPARTAN_clk: in std_logic;
		DDS_square_out: out std_logic;
		DDS_frequency: out std_logic_vector (23 downto 0);
		refout_I: out std_logic_vector	(15 downto 0);
		refout_Q: out std_logic_vector	(15 downto 0)
);
end pll;

architecture rtl of pll is

signal reference_square_wave: std_logic;
signal DDS_sync_output: std_logic;
signal DDS_feedback_out: std_logic_vector (23 downto 0):=(others => '0');
signal	PLL_pos: std_logic;
signal	PLL_neg: std_logic;
signal	phase_I: std_logic_vector (9 downto 0);
signal	phase_Q: std_logic_vector (9 downto 0);

begin

	--ref_square_wave_out <= reference_square_wave;
	DDS_square_out <= DDS_sync_output;
	DDS_frequency <= DDS_feedback_out;
	--ref_check <= reference_square_wave;
	--DDS_check <= DDS_sync_output;
	--freq <= DDS_feedback_out;

SIGNAL_GENERATOR_1: entity work.signal_gen 
port map (
	frequency => DDS_feedback_out,	--output frequency
	clk_in => SPARTAN_clk,				--
	sync_output => DDS_sync_output,	--sync to PLL
	phase_I => phase_I,		--output both I and Q
	phase_Q => phase_Q
);

phase_I_sine: entity work.sine_lut 
port map (
	THETA => phase_I,
	CLK => SPARTAN_clk,
	SINE_OUT => refout_I
);

phase_Q_cos: entity work.sine_lut 
port map (
	THETA => phase_Q,
	CLK => SPARTAN_clk,
	SINE_OUT => refout_Q
);

ZERO_CROSSING_DETECTOR_1: entity work.zero_crossing_det 
port map (
	sig_in => ref_in, 		--signal in should be in 2's comp. for zero crossing, we probably only need to look at sign bit. but for now, let's use full signal
	signal_clock => clk_i,
	crossing_detect_out => reference_square_wave
);

REF_FREQUENCY_1: entity work.ref_frequency 
port map (
	reference_sync_wave => reference_square_wave,
	SPARTAN_clk => SPARTAN_clk,
	clk_in => clk_i,
	DDS_feedback_out => DDS_feedback_out
);

end rtl;

