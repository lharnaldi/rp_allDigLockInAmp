library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_adpll is
port(
  clk_i      : in std_logic;
  sig_i      : in std_logic_vector(13 downto 0); 
  I          : out std_logic_vector(9 downto 0);
  Q          : out std_logic_vector(9 downto 0);
  comp_up_o  : out std_logic;
  comp_dn_o  : out std_logic;
  locked_o   : out std_logic
);
end top_adpll;

architecture rtl of top_adpll is

signal sig_zero_det_out : std_logic;
signal freq_sig : std_logic_vector(29 downto 0);
signal sync_sig : std_logic;

begin

U1: entity work.zero_cross_det
generic map( ADC_DATA_WIDTH =>14)
port map(
  clk_i => clk_i,
  sig_i => sig_i,
  det_o => sig_zero_det_out
);

U2: entity work.adpll
port map(
  clk_i      => clk_i,
  ref_i      => sig_zero_det_out,
  dds_sync_i => sync_sig,
  dds_fbk_o  => freq_sig,
  comp_up_o  => comp_up_o,
  comp_dn_o  => comp_dn_o
);

U3: entity work.ref_ddc_locker
port map(
  clk_i     => clk_i,
  ref_i     => sig_zero_det_out,
  dds_sync_i=> sync_sig,
  locked_o  => locked_o
);

U4: entity work.signal_gen
port map(
  clk_i   => clk_i,
  freq_i  => freq_sig,
  sync_o  => sync_sig,
  phase_I => I,
  phase_Q => Q
);

end rtl;
