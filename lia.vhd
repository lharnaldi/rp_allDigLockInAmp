library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lia is
generic(
 ADC_DATA_WIDTH : natural := 14;
 AXIS_TDATA_WIDTH: natural := 32
);
port(
  clk_i      : in std_logic;
  rst_i      : in std_logic;
  sig_i      : in std_logic_vector(AXIS_TDATA_WIDTH/2-1 downto 0); 
  I          : out std_logic_vector(9 downto 0);
  Q          : out std_logic_vector(9 downto 0);
  locked_o   : out std_logic
);
end lia;

architecture rtl of lia is

signal zcd_o : std_logic;
signal freq_sig : std_logic_vector(29 downto 0);
signal sync_sig : std_logic;

signal sin_sig, cos_sig : std_logic_vector(AXIS_TDATA_WIDTH/2-1 downto 0);
signal mult1_s, mult2_s : std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0);

begin

ZCD: entity work.zero_cross_det
  generic map( ADC_DATA_WIDTH => ADC_DATA_WIDTH )
  port map(
    aclk   => clk_i,
    aresetn => rst_i,
    sig_i => sig_i,
    det_o => zcd_o
  );

ADPLL: entity work.adpll
  generic map( ADC_DATA_WIDTH => ADC_DATA_WIDTH,
               AXIS_TDATA_WIDTH => AXIS_TDATA_WIDTH
             )
  port map(
    aclk      => clk_i,
    aresetn    => rst_i,
    ref_i      => zcd_o,
  --  phase_I  => 
  --  phase_Q  =>
    locked_o   => locked_o,
    sin_o      => sin_sig,
    cos_o      => cos_sig
  );

SM1: entity work.signed_mult
  generic map(
  ADC_DATA_WIDTH => ADC_DATA_WIDTH,
  AXIS_TDATA_WIDTH => AXIS_TDATA_WIDTH
)
port map(
  aclk => clk_i,
  a_i   => sin_sig,
  b_i   => sig_i,
  mult_o => mult1_s
);

LPF1: entity work.lpf_iir
port map(
  aclk     => clk_i,
  aresetn  => rst_i, 
  sig_i    => mult1_s,
  tc_i     => std_logic_vector(to_unsigned(2147376429,AXIS_TDATA_WIDTH)),
  data_o(AXIS_TDATA_WIDTH-1 downto AXIS_TDATA_WIDTH/2 + 6)    => I
);

SM2: entity work.signed_mult
  generic map(
   ADC_DATA_WIDTH => ADC_DATA_WIDTH,
   AXIS_TDATA_WIDTH => AXIS_TDATA_WIDTH
)
port map(
  aclk => clk_i,
  a_i   => cos_sig,
  b_i   => sig_i,
  mult_o => mult2_s
);

LPF2: entity work.lpf_iir
port map(
  aclk     => clk_i,
  aresetn  => rst_i, 
  sig_i    => mult2_s,
  tc_i     => std_logic_vector(to_unsigned(2147376429, AXIS_TDATA_WIDTH)),
  data_o(AXIS_TDATA_WIDTH-1 downto AXIS_TDATA_WIDTH/2 + 6)    => Q
);

end rtl;
