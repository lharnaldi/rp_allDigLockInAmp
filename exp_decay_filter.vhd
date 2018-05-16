library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp_decay_filter is
port(
  aclk       : in std_logic;
  aresetn    : in std_logic;
  sig_i      : in std_logic_vector(36-1 downto 0);
  tc_i       : in std_logic_vector (36-1 downto 0); -- time constant: parameter equal to e^-1/d where d is number of samples time constant
  sig_o      : out std_logic_vector(36-1 downto 0);
);
end exp_decay_filter;

architecture rtl of exp_decay_filter is

signal sig_reg, sig_next : signed(36-1 downto 0);
signal signal_out_old : signed(36-1 downto 0);

signal multiply_out :	signed(72-1 downto 0);

signal a0 : signed(36-1 downto 0);
signal b1 : signed(36-1 downto 0);

begin

b1 <= signed("01" & (33 downto 0 => '0')) - signed(tc_i); --{2'b01, 34'b0} - time_constant;  //{16'b0011111111000000, 20'b0};	//switch!!!! //  //1 - x
a0 <= tc_i;  --{10'b0, 10'b1111111111, 16'b0};  //	//time constant is in equal to x=1 - e^-1/d where d is number of samples decay time.  
multiply_out <= b1 * signal_out_old + a0 * sig_i;

process(aclk)
begin
	if(aresetn = '0') then
		sig_reg 		<= signal_in;
		signal_out_old 	<= signal_in;
	elsif rising_edge(aclk) then
		signal_out <= multiply_out(71) & multiply_out(68 downto 34);
		signal_out_old <= signal_out;
	end if;
end process;

sig_next <= sig_i;

end rtl;
