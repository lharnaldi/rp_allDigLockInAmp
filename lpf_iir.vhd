library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lpf_iir is
generic (
  AXIS_TDATA_WIDTH: natural := 32;
  ADC_DATA_WIDTH  : natural := 14
);
port(
  aclk       : in std_logic;
  aresetn    : in std_logic;
  sig_i      : in std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0);
  tc_i       : in std_logic_vector (AXIS_TDATA_WIDTH-1 downto 0); 
  data_o     : out std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0)
);
end lpf_iir;

architecture rtl of lpf_iir is

-- format is sign bit + 1.30
constant one               : std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0) := "01000000000000000000000000000000";

signal sig_reg, sig_next   : std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0);
signal data_reg, data_next : std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0);
signal mult                : std_logic_vector(2*AXIS_TDATA_WIDTH-1 downto 0);

signal a0                  : std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0);
signal b1                  : std_logic_vector(AXIS_TDATA_WIDTH-1 downto 0);

begin

  a0 <= std_logic_vector(signed(one) - signed(tc_i)); 
  b1 <= tc_i; 

  process(aclk)
  begin
    if(aresetn = '0') then
      sig_reg  <= sig_i;
      data_reg  <= sig_i;
    elsif rising_edge(aclk) then
      sig_reg  <= sig_next;
      data_reg  <= data_next;
    end if;
  end process;

  --Next state logic
  sig_next <= sig_i;

  mult <= std_logic_vector(signed(a0)*signed(sig_i) + signed(b1)*signed(data_reg));

  data_next <= mult((2*AXIS_TDATA_WIDTH)-1) & mult(2*AXIS_TDATA_WIDTH-2 downto AXIS_TDATA_WIDTH);

  data_o <= data_reg;

end rtl;
