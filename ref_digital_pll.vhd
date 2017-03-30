library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ref_digital_psd is
port(
  clk_i      : in std_logic;
  dds_sync_i : in std_logic;
  ref_i      : in std_logic; -- reference signal after zero crossing
  dds_fbk_o  : out std_logic_vector (21 downto 0);
  comp_up_o  : out std_logic;
  comp_dwn_o : out std_logic
);
end ref_digital_psd;

architecture rtl of ref_digital_psd is

constant gain: std_logic_vector(21 downto 0):="0010000000000000000000"; --16 Hz //524288
signal comp_up_reg, comp_up_next : std_logic;
signal comp_dwn_reg, comp_dwn_next : std_logic;

signal dds_fbk_o_1: std_logic_vector(21 downto 0):=(others=>'0');
signal pos_gain: std_logic_vector(21 downto 0):=(others=>'0');
signal neg_gain: std_logic_vector(21 downto 0):=(others=>'0');
signal reset: std_logic;
signal neg_temp1: std_logic;
signal pos_temp1: std_logic;
signal out_pos_flash: std_logic;
signal out_neg_flash: std_logic;

begin

comp_up_o <= comp_up_reg;
comp_neg_o <= comp_dwn_reg;
--reset      <= dds_sync_i and ref_i;
reset      <= comp_up_reg and comp_dwn_reg;

--phase comparator flip flops
process(dds_sync_i)		
begin
if rising_edge(dds_sync_i) then
  comp_dwn_reg <= com_neg_next;
end if;
end process;

comp_dwn_next <= '0' when (reset = '1') else '1';

process(ref_i)
begin
if rising_edge(ref_i)  then
  comp_up_reg <= com_pos_next;
end if;
end process;

comp_up_next <= '0' when (reset = '1') else '1';

out_pos_flash <= pos_temp1;	
out_neg_flash <= neg_temp1;

process(clk_i)
begin
 if rising_edge(clk_i) then
   pos_temp1<=comp_up_reg;
   neg_temp1<=comp_dwn_reg;

	 if ((out_neg_flash='1') and (out_pos_flash ='0')) then 
	   dds_fbk_o_1(21 downto 0) <= std_logic_vector(unsigned(dds_fbk_o_1)-32); -- -1 hz step
	 elsif ((out_pos_flash ='1') and (out_neg_flash='0')) then	
	   dds_fbk_o_1(21 downto 0) <= std_logic_vector(unsigned(dds_fbk_o_1)+32); -- +1 hz step
	 end if;

	 if (pos_temp1='1') then
	   neg_gain <= (others =>'0');
		 pos_gain <= gain;
	 elsif (neg_temp1='1') then
		 pos_gain <= (others =>'0');
		 neg_gain <= gain;
	 else
		 pos_gain <= (others =>'0');
		 neg_gain <= (others =>'0');
	 end if;
 end if;
end process;

dds_fbk_o <= std_logic_vector(unsigned(dds_fbk_o_1) + unsigned(pos_gain) - unsigned(neg_gain) + 64);

end rtl;

