library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_mult is
port(
  clk_i : in std_logic;
  a_i   : in std_logic_vector (15 downto 0);
  b_i   : in std_logic_vector (15 downto 0);
  mult_o: out std_logic_vector (31 downto 0)
);
end signed_mult;

architecture rtl of signed_mult is
signal mult_o_reg, mult_o_next: std_logic_vector (31 downto 0):=(others=>'0');

begin

process (clk_i)
begin
  if rising_edge(clk_i) then
    mult_o_reg <= mult_o_next;
end if;
end process;

  --Next state logic
  mult_o_next <= std_logic_vector(signed(a_i) * signed(b_i));

  mult_o <= mult_o_reg;
end rtl;

