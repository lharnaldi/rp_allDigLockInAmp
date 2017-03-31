library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_gen is
port(
	clk_i   : in std_logic;			--100MHz
	freq_i  : in std_logic_vector (29 downto 0);				--40 bit output freq_i in 24.16 format gives 15uHz resolution
	sync_o  : out std_logic;	--logic square wave out
	phase_I : out std_logic_vector (9 downto 0);
	phase_Q : out std_logic_vector (9 downto 0)
);
end signal_gen;

architecture rtl of signal_gen is

signal freq_reg, freq_next: std_logic_vector (29 downto 0):=(others=>'0');
--DDS variables
signal phase_acc_reg, phase_acc_next: std_logic_vector (49 downto 0):=(others=>'0');
signal phase_step_reg, phase_step_next: std_logic_vector (49 downto 0);

begin

process(clk_i)
begin
if rising_edge(clk_i) then
 freq_reg <= freq_next;
 phase_step_reg <= phase_step_next;
 phase_acc_reg <= phase_acc_next;
end if;
end process;

--next state
 freq_next <= freq_i;

 --fout = fclock * a / (# step per full cycle) * fin *2^16.     # steps is 2^60, f=100MHz => a = 175922.
 phase_step_next <= std_logic_vector(to_unsigned(175922,29) * unsigned(freq_reg)); 
 
 phase_acc_next <= std_logic_vector(unsigned(phase_acc_reg) + unsigned(phase_step_reg)); 

--output
 phase_I <= phase_acc_reg(49 downto 40);
 phase_Q <= std_logic_vector(unsigned(phase_acc_reg(49 downto 40)) + to_unsigned(255, 10)); 	--phase of Q is 90deg advanced from I. 256.
 sync_o <= not(phase_acc_reg(49));

--process(clk_i)
--variable phasestep: unsigned (49 downto 0);
--begin
--if rising_edge(clk_i) then
--	phasestep:= to_unsigned(22517998, 26) * unsigned(freq_i_int);			--fout = fclock * a / (# step per full cycle) * fin *2^16.     # steps is 2^60, f=100MHz => a = 175922.
--	phaseacc <= std_logic_vector(unsigned(phaseacc) + phasestep);
----phaseacc <= std_logic_vector(to_unsigned(255, 50));
--end if;
--end process;

end rtl;

