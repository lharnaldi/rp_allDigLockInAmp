library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_mult is
  generic (
  ADC_DATA_WIDTH  : natural := 14;
  AXIS_TDATA_WIDTH: natural := 32
);

port(
  aclk  : in std_logic;
  a_i   : in std_logic_vector (AXIS_TDATA_WIDTH/2-1 downto 0);
  b_i   : in std_logic_vector (AXIS_TDATA_WIDTH/2-1 downto 0);
  mult_o: out std_logic_vector (AXIS_TDATA_WIDTH-1 downto 0)
);
end signed_mult;

architecture rtl of signed_mult is

 constant PADDING_WIDTH : natural := AXIS_TDATA_WIDTH/2 - ADC_DATA_WIDTH;
signal mult_reg, mult_next: std_logic_vector(2*ADC_DATA_WIDTH-1 downto 0) := (others => '0');

begin

  process(aclk)
  begin
    if rising_edge(aclk) then
      mult_reg <= mult_next;
    end if;
  end process;

  --Next state logic
  mult_next <= std_logic_vector(signed(a_i(ADC_DATA_WIDTH-1 downto 0)) * signed(b_i(ADC_DATA_WIDTH-1 downto 0)));

  mult_o <= ((2*PADDING_WIDTH-1) downto 0 => mult_reg(2*ADC_DATA_WIDTH-1)) & mult_reg;
  
end rtl;

