library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lia is
port(
  clk_i      : in std_logic;
  rst_i      : in std_logic;
  sig_i      : in std_logic_vector(13 downto 0); 
  I          : out std_logic_vector(9 downto 0);
  Q          : out std_logic_vector(9 downto 0);
  locked_o   : out std_logic
);
end lia;

architecture rtl of lia is

signal zcd_o : std_logic;
signal freq_sig : std_logic_vector(29 downto 0);
signal sync_sig : std_logic;

signal sin_sig, cos_sig : std_logic_vector(14-1 downto 0);

begin

ZCD: entity work.zero_cross_det
  generic map( ADC_DATA_WIDTH =>14)
  port map(
    clk_i => clk_i,
    rst_i => rst_i,
    sig_i => sig_i,
    det_o => zcd_o
  );

ADPLL: entity work.adpll
  port map(
    clk_i      => clk_i,
    rst_i      => rst_i,
    ref_i      => zcd_o,
  --  phase_I  => 
  --  phase_Q  =>
    locked_o   => locked_o,
    sin_o      => sin_sig
    cos_o      => cos_sig,
  );

SM1: entity work.signed_mult
  generic map(
  ADC_DATA_WIDTH => 14,
  AXIS_TDATA_WIDTH => 32
)
port map(
  clk_i => clk_i,
  a_i   => sin_sig,
  b_i   => sig_i,
  mult_o => mult1_s
);

LPF1: entity work.exp_decay_filter
port map(
  aclk     => clk_i,
  aresetn  => rst_i, 
  sig_i    => mult1_s,
  tc_i     => 
  sig_o    => I
);

SM2: entity work.signed_mult
  generic map(
  ADC_DATA_WIDTH => 14,
  AXIS_TDATA_WIDTH => 32
)
port map(
  clk_i => clk_i,
  a_i   => cos_sig,
  b_i   => sig_i,
  mult_o => mult2_s
);

LPF2: entity work.exp_decay_filter
port map(
  aclk     => clk_i,
  aresetn  => rst_i, 
  sig_i    => mult2_s,
  tc_i     => 
  sig_o    => Q
);

end rtl;
