library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.funct.all;

entity ref_freq is
  generic (
  ADC_DATA_WIDTH : natural := 14;
  AXIS_TDATA_WIDTH: natural := 32
);

port(
  clk_i        : in std_logic;
  ref_sync_wave: in std_logic; -- reference signal after zero crossing
  SPARTAN_clk  : in std_logic;
  DDS_feedback_out: out std_logic_vector (23 downto 0);
  ref_period_cnt_out: out std_logic_vector (25 downto 0)
);
end ref_freq;

architecture rtl of ref_freq is

constant freq_const: unsigned (25 downto 0):="10111110101111000010000000"; --50 000 000

signal ref_period_counter: unsigned (25 downto 0):= ((0)=>'1', others=>'0');
signal ref_period_int: unsigned (25 downto 0):= ((0)=>'1', others=>'0');
signal ref_frequency: std_logic_vector (23 downto 0):=(others=>'0');
signal previous_ref_state: std_logic:='0';

begin

DDS_feedback_out <= ref_frequency;

process(SPARTAN_clk)
begin
  if rising_edge(SPARTAN_clk) then
    previous_ref_state <= ref_sync_wave;
    if ((ref_sync_wave = '1') and (previous_ref_state  = '0')) then --if reference pulse goes high, begin count
      ref_period_int<=ref_period_counter;
      ref_period_counter <=  ((0)=>'1', others=>'0');
    else -- it counts for both positive and negative periods, but period is taken for one
      ref_period_counter <= ref_period_counter + 1;
    end if;
  end if;
end process;

process (clk_i)
begin
  if rising_edge(clk_i) then
    --ref_frequency<=std_logic_vector(resize(ref_period_int, 24));
    if (ref_period_int>1) then 
      ref_frequency <= std_logic_vector(resize(divide(freq_const, ref_period_int), 24));
    else
      ref_frequency <= (others=>'0');
    end if;
end if;

end process;

end rtl;


