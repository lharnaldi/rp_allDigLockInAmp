library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ref_digital_psd is
  port(
		clk_i: in std_logic;
		DDS_sync_output:in std_logic;
		reference_sync_wave: in std_logic; -- reference signal after zero crossing
		DDS_feedback_out: out std_logic_vector (21 downto 0);
		comparator_out_pos:inout std_logic;
		comparator_out_neg:inout std_logic
);
end ref_digital_psd;

architecture rtl of ref_digital_psd is

signal DDS_feedback_out_1: std_logic_vector(21 downto 0):=(others=>'0');
signal pos_gain: std_logic_vector(21 downto 0):=(others=>'0');
signal neg_gain: std_logic_vector(21 downto 0):=(others=>'0');
signal reset: std_logic;
signal neg_temp1: std_logic;
signal pos_temp1: std_logic;
signal out_pos_flash: std_logic;
signal out_neg_flash: std_logic;
constant gain: std_logic_vector(21 downto 0):="0010000000000000000000"; --16 Hz //524288

begin

--process (clk_i)
--begin
--if rising_edge(clk_i) then
--reset<=DDS_sync_output and reference_sync_wave;

--if DDS_sync_output = '1' then
--if(reset='1') then
		--comparator_out_neg <= '0';
	--else
		--comparator_out_neg <= '1';
	--end if;
--end if;

--if reference_sync_wave='1'  then
	--if(reset='1') then
		--comparator_out_pos <= '0';
	--else
		--comparator_out_pos <= '1';
	--end if;
--end if;
--end if;
--end process;

reset<=DDS_sync_output and reference_sync_wave;

process (reset)		--phase comparator flip flops
begin
if rising_edge (reset) then
--	comparator_out_pos <= '0';
--	comparator_out_neg <= '0';
end if;
end process;

process (DDS_sync_output)		--phase comparator flip flops
begin
if rising_edge(DDS_sync_output) then
	if(reset='1') then
		comparator_out_neg <= '0';
	else
		comparator_out_neg <= '1';
	end if;
end if;
end process;

process (reference_sync_wave)
begin
if rising_edge(reference_sync_wave)  then
	if(reset='1') then
		comparator_out_pos <= '0';
	else
		comparator_out_pos <= '1';
	end if;
end if;
end process;

out_pos_flash <= pos_temp1;	
out_neg_flash <= neg_temp1;

Process (clk_i)
--Process (reference_sync_wave)

begin

if rising_edge(clk_i) then

pos_temp1<=comparator_out_pos;
neg_temp1<=comparator_out_neg;

	if ((out_neg_flash='1') and (out_pos_flash ='0')) then 
	DDS_feedback_out_1(21 downto 0)<=std_logic_vector(unsigned(DDS_feedback_out_1)-32); -- -1 hz step

	elsif ((out_pos_flash ='1') and (out_neg_flash='0')) then	
	DDS_feedback_out_1(21 downto 0)<=std_logic_vector(unsigned(DDS_feedback_out_1)+32); -- +1 hz step
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

DDS_feedback_out <= std_logic_vector(unsigned(DDS_feedback_out_1) + unsigned(pos_gain) - unsigned(neg_gain) + 64);

end rtl;

