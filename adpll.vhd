library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adpll is
port(
  clk_i      : in std_logic;
  rst_i      : in std_logic;
  ref_i      : in std_logic; -- reference signal after zero crossing
  dds_sync_i : in std_logic; -- sync signal from dds generator
  dds_fbk_o  : out std_logic_vector (29 downto 0);
  comp_up_o  : out std_logic;
  comp_dn_o  : out std_logic
);
end adpll;

architecture rtl of adpll is

constant gain: std_logic_vector(29 downto 0):= std_logic_vector(to_unsigned(2097152, 30)); --"000000001000000000000000000000"; 

signal comp_up_reg, comp_up_next : std_logic := '0';
signal comp_dn_reg, comp_dn_next : std_logic := '0';

signal dds_fbk_reg, dds_fbk_next   : std_logic_vector(29 downto 0);
signal pos_gain_reg, pos_gain_next : std_logic_vector(29 downto 0);
signal neg_gain_reg, neg_gain_next : std_logic_vector(29 downto 0);
signal reset: std_logic := '0';

begin

comp_up_o <= comp_up_reg;
comp_dn_o <= comp_dn_reg;

reset      <= comp_up_reg and comp_dn_reg;

--phase comparator flip flops
process(dds_sync_i)
begin
if rising_edge(dds_sync_i) then
  comp_dn_reg <= comp_dn_next;
end if;
end process;

comp_dn_next <= '0' when (reset = '1') else '1';

process(ref_i)
begin
if rising_edge(ref_i)  then
  comp_up_reg <= comp_up_next;
end if;
end process;

comp_up_next <= '0' when (reset = '1') else '1';

-- PI loop filter
process(clk_i)
begin
 if rising_edge(clk_i) then
   if rst_i = '0' then
     dds_fbk_reg <= (others => '0');
     pos_gain_reg <= (others => '0');
     neg_gain_reg <= (others => '0');
   else
     dds_fbk_reg <= dds_fbk_next;
     pos_gain_reg <= pos_gain_next;
     neg_gain_reg <= neg_gain_next;
   end if;
 end if;
end process;

 dds_fbk_next <= std_logic_vector(unsigned(dds_fbk_reg)-32) when ((comp_dn_reg = '1') and (comp_up_reg = '0')) else  -- -1 Hz step
                std_logic_vector(unsigned(dds_fbk_reg)+32) when ((comp_up_reg = '1') and (comp_dn_reg = '0')) else  -- +1 Hz step
                dds_fbk_reg;

 pos_gain_next <= gain when (comp_up_reg = '1') else
                 (others =>'0') when (comp_dn_reg = '1') else
                 (others =>'0');

 neg_gain_next <= gain when (comp_dn_reg = '1') else
                  (others =>'0') when (comp_up_reg = '1') else
                  (others =>'0');

 dds_fbk_o <= std_logic_vector(unsigned(dds_fbk_reg) + unsigned(pos_gain_reg) - unsigned(neg_gain_reg) + 64);
 

end rtl;

