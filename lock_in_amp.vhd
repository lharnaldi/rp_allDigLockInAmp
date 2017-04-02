library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lock_in_amp is
  port(
    clk_i    : in std_logic;
    signal_i : in std_logic_vector (15 downto 0);
    ref_i    : in std_logic_vector (15 downto 0);
    SPARTAN_clk: in std_logic;
    DDS_square_wave: inout std_logic;
    DDS_frequency: out std_logic_vector (23 downto 0);
    signalI2: out std_logic_vector (31 downto 0);
    signalQ2: out std_logic_vector (31 downto 0);
    quantity1: out std_logic_vector(23 downto 0);
    sum1: out std_logic_vector(33 downto 0);
    quantity2: out std_logic_vector(23 downto 0);
    sum2: out std_logic_vector(33 downto 0)
  );
end lock_in_amp;

architecture rtl of lock_in_amp is

--signal reference_square_wave: std_logic;
signal amplitude1: std_logic_vector (20 downto 0);
signal signalI1: std_logic_vector (31 downto 0);
signal signalQ1: std_logic_vector  (31 downto 0);
--output signals, asstd_logic_vector to VGA DACs.
--(A/D board seem to really suck, not sure why.   
-- <- cause it's badly destd_logic_vector, that's 
-- why!)
signal sigout_A: std_logic_vector (9 downto 0);  
signal sigout_B: std_logic_vector (9 downto 0);
signal refout_I: std_logic_vector (15 downto 0);
signal refout_Q: std_logic_vector (15 downto 0);

begin

SIGNED_MULT_I1: entity work.signed_mult 
port map (
  a => signal_i,
  b => refout_I,
  output => signalI1,
  clk_i => clk_i
);

SIGNED_MULT_Q1: entity work.signed_mult 
port map (
  a => signal_i,
  b => refout_Q,
  output => signalQ1,
  clk_i => clk_i
);

I2: entity work.avg_filter
port map (
  signal_i => signalI1,
  signal_out => signalI2,
  DDS_square_wave => DDS_square_wave,
  clk_i => clk_i,
  quantity => quantity1,
  sum => sum1
);

Q2: entity work.avg_filter
port map (
  signal_i => signalQ1,
  signal_out => signalQ2,
  DDS_square_wave => (not DDS_square_wave),
  clk_i => clk_i,
  quantity => quantity2,
  sum => sum2
);

PLL: entity work.phase_locked_loop
port map (
  ref_i => ref_i,
  clk_i => clk_i,
  SPARTAN_clk => SPARTAN_clk,
  DDS_square_out => DDS_square_wave,
  DDS_frequency => DDS_frequency,
  refout_I => refout_I,
  refout_Q => refout_Q
);

end rtl;
