library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_gen is
  port(
		clk_i: in std_logic;			--100MHz
		frequency: in std_logic_vector (23 downto 0);				--40 bit output frequency in 24.16 format gives 15uHz resolution
		sync_output: out std_logic;	--logic square wave out
		phase_I: out std_logic_vector (9 downto 0);
		phase_Q: out std_logic_vector (9 downto 0)
);
end signal_gen;

architecture rtl of signal_gen is

signal frequency_int: std_logic_vector (23 downto 0):=(others=>'0');
--DDS variables
signal phaseacc: std_logic_vector (49 downto 0):=(others=>'0');

begin

frequency_int<=frequency;
phase_I <= phaseacc(49 downto 40);
phase_Q <= std_logic_vector(unsigned(phaseacc(49 downto 40)) + to_unsigned(255, 10)); 	--phase of Q is 90deg advanced from I. 256.
sync_output <= not (phaseacc(49));

--process(frequency)
process(clk_i)
variable phasestep: unsigned (49 downto 0);
begin
if rising_edge(clk_i) then
	phasestep:= to_unsigned(22517998, 26) * unsigned(frequency_int);			--fout = fclock * a / (# step per full cycle) * fin *2^16.     # steps is 2^60, f=100MHz => a = 175922.
	phaseacc <= std_logic_vector(unsigned(phaseacc) + phasestep);
--phaseacc <= std_logic_vector(to_unsigned(255, 50));
end if;
end process;

end rtl;

