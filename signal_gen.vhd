library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_gen is
port(
	clk_i   : in std_logic;		
	rst_i   : in std_logic;	
	freq_i  : in std_logic_vector (32-1 downto 0);				
	sync_o  : out std_logic;	
	phase_I : out std_logic_vector (14-1 downto 0);
	phase_Q : out std_logic_vector (14-1 downto 0)
);
end signal_gen;

architecture rtl of signal_gen is

signal phase_acc_reg, phase_acc_next: std_logic_vector (49 downto 0);
signal phase_step: std_logic_vector (49 downto 0) := (others => '0');

begin

process(clk_i)
begin
if rising_edge(clk_i) then
  if rst_i = '0' then
    phase_acc_reg <= (others => '0');
  else
    phase_acc_reg <= phase_acc_next;
  end if;
end if;
end process;

--next state
 --fout = fclock * A / (# step per full cycle) * fin *2^6.     # steps is 2^50, f=125MHz => A = 140737.
 --phase_step <= std_logic_vector(to_unsigned(140737,20) * unsigned(freq_i)); 
 phase_step <= std_logic_vector(to_unsigned(35184,18) * unsigned(freq_i)); --for 2^8
 
 phase_acc_next <= std_logic_vector(unsigned(phase_acc_reg) + unsigned(phase_step)); 

--output
 --phase_I <= phase_acc_reg(49 downto 40);
 phase_I <= phase_acc_reg(49 downto 36);
 --phase_Q <= std_logic_vector(unsigned(phase_acc_reg(49 downto 40)) + to_unsigned(255, 10)); --phase of Q is 90deg advanced from I. 256.
 phase_Q <= std_logic_vector(unsigned(phase_acc_reg(49 downto 36)) + to_unsigned(4095, 10)); --phase of Q is 90deg advanced from I. 256.
 sync_o <= not(phase_acc_reg(49));

end rtl;

