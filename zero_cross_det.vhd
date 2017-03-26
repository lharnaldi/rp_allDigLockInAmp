library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zero_cross_det is
generic (
  ADC_DATA_WIDTH  : natural := 14
);
port (

port (
  clk_i: in std_logic;
  sig_i: in std_logic_vector(ADC_DATA_WIDTH-1 downto 0); 		
  det_o: out std_logic
);
end zero_cross_det;

architecture rtl of zero_cross_det is

-- amount signal must deviate below or above zero to allow zero crossing to be valid
--constant hyst    : signed(ADC_DATA_WIDTH-1 downto 0) :=x"0008"; 
constant hyst    : signed(ADC_DATA_WIDTH-1 downto 0) :="00100000000000"; 

signal sig_i_reg, sig_i_next: std_logic_vector(ADC_DATA_WIDTH-1 downto 0) ;
signal det_o_reg, det_o_next: std_logic;
signal hyst_low  : std_logic;
signal hyst_high : std_logic;

begin

process(clk_i)
begin
if rising_edge(clk_i) then
  sig_i_reg <= sig_i_next;
  det_o_reg <= det_o_next;
end if;
end process;

--Next state logic
sig_i_next <= sig_i;

det_o_next <= '1' when (sig_i_reg(sig_i_reg'left) = '1' and sig_i_next(sig_i_next'left) = '0' and hyst_low = '1') else
              '0' when (sig_i_reg(sig_i_reg'left) = '0' and sig_i_next(sig_i_next'left) = '1' and hyst_high = '1') else
              det_o_reg;

hyst_high <= '1' when (signed(sig_i_next) > (hyst)) else
             '0' when (sig_i_reg(sig_i_reg'left) = '0' and sig_i_next(sig_i_next'left) = '1' and hyst_high = '1');
              
hyst_low  <= '1' when (signed(sig_i_next) < (-hyst)) else
             '0' when (sig_i_reg(sig_i_reg'left) = '1' and sig_i_next(sig_i_next'left) = '0' and hyst_low = '1');

det_o <= det_o_reg;

end rtl;

