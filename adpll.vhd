library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adpll is
port(
  clk_i      : in std_logic;
  rst_i      : in std_logic;
  ref_i      : in std_logic; -- reference signal after zero crossing
--  phase_I    : out std_logic_vector (14-1 downto 0);
--  phase_Q    : out std_logic_vector (14-1 downto 0);
  locked_o   : out std_logic;
  sin_o      : out std_logic_vector(14-1 downto 0);
  cos_o      : out std_logic_vector(14-1 downto 0)
);
end adpll;

architecture rtl of adpll is

component sincos_lut_14
port (
  clk_i   : in  std_logic;
  addr_i  : in  std_logic_vector(14-1 downto 0);
  sin     : out std_logic_vector(14-1 downto 0);
  cos     : out std_logic_vector(14-1 downto 0)
  );
end component;

constant C_GAIN: std_logic_vector(32-1 downto 0):= std_logic_vector(to_unsigned(2097152, 32)); --"00000000001000000000000000000000"; 8192.00
--constant C_GAIN: std_logic_vector(32-1 downto 0):= std_logic_vector(to_unsigned(59782528, 32)); --"00000000001000000000000000000000"; 8192.00
constant I_GAIN: std_logic_vector(32-1 downto 0):= std_logic_vector(to_unsigned(32,32));
--PSD realted signals
signal reset: std_logic := '0';
signal comp_up_reg, comp_up_next : std_logic := '0';
signal comp_dn_reg, comp_dn_next : std_logic := '0';

--Loop filter related signals
signal pos_gain_reg, pos_gain_next : std_logic_vector(32-1 downto 0);
signal neg_gain_reg, neg_gain_next : std_logic_vector(32-1 downto 0);
signal dds_fbk_reg, dds_fbk_next   : std_logic_vector(32-1 downto 0);
signal dds_fbk                     : std_logic_vector(32-1 downto 0);

--DDS related signals
signal phase_acc_reg, phase_acc_next: std_logic_vector(50-1 downto 0);
signal phase_step: std_logic_vector(50-1 downto 0) := (others => '0');
signal dds_sync  : std_logic;

--Locked indicator related signals
signal ref_reg, ref_next: std_logic;
signal ref_period_cntr_reg, ref_period_cntr_next : std_logic_vector(31 downto 0);
signal ref_period_reg, ref_period_next : std_logic_vector(31 downto 0);
signal ref_count_done_reg, ref_count_done_next: std_logic;
signal dds_period_cntr_reg, dds_period_cntr_next : std_logic_vector(31 downto 0);
signal dds_period_reg, dds_period_next : std_logic_vector(31 downto 0);
signal dds_count_done_reg, dds_count_done_next: std_logic;
signal dds_reg, dds_next: std_logic;
signal up_sal, dn_sal : std_logic;
signal lut_addr : std_logic_vector(14-1 downto 0);

begin

reset      <= comp_up_reg and comp_dn_reg;

--PFD phase comparator flip flops
process(ref_i, reset)
begin
 if reset = '1' then
  comp_up_reg <= '0';
 elsif rising_edge(ref_i)  then
  comp_up_reg <= comp_up_next;
end if;
end process;

comp_up_next <= '1';--'0' when (reset = '1') else '1';

process(dds_sync, reset)
begin
 if reset = '1' then
  comp_dn_reg <= '0';
 elsif rising_edge(dds_sync) then
  comp_dn_reg <= comp_dn_next;
end if;
end process;

comp_dn_next <= '1';--'0' when (reset = '1') else '1';


-- PI loop filter
process(clk_i)
begin
 if rising_edge(clk_i) then
   if rst_i = '0' then
     dds_fbk_reg <= (others => '0');
     pos_gain_reg <= (others => '0');
     neg_gain_reg <= (others => '0');
     phase_acc_reg <= (others => '0');
   else
     dds_fbk_reg <= dds_fbk_next;
     pos_gain_reg <= pos_gain_next;
     neg_gain_reg <= neg_gain_next;
     phase_acc_reg <= phase_acc_next;
   end if;
 end if;
end process;

 
 dds_fbk_next <= std_logic_vector(unsigned(dds_fbk_reg)-unsigned(I_GAIN)) when ((comp_dn_reg = '1') and (comp_up_reg = '0')) else 
                std_logic_vector(unsigned(dds_fbk_reg)+unsigned(I_GAIN)) when ((comp_up_reg = '1') and (comp_dn_reg = '0')) else 
                dds_fbk_reg;

 pos_gain_next <= C_GAIN when (comp_up_reg = '1') else
                 (others =>'0') when (comp_dn_reg = '1') else
                 (others =>'0');

 neg_gain_next <= C_GAIN when (comp_dn_reg = '1') else
                  (others =>'0') when (comp_up_reg = '1') else
                  (others =>'0');

 dds_fbk <= std_logic_vector(unsigned(dds_fbk_reg) + unsigned(pos_gain_reg) - unsigned(neg_gain_reg) + 64);
 
 --DDS signal generator
 phase_step <= std_logic_vector(to_unsigned(35184,18) * unsigned(dds_fbk));

 phase_acc_next <= std_logic_vector(unsigned(phase_acc_reg) + unsigned(phase_step));

 dds_sync <= not(phase_acc_reg(50-1));

 --phase_I <= phase_acc_reg(50-1 downto 36);
 --phase_Q <= std_logic_vector(unsigned(phase_acc_reg(50-1 downto 36)) + to_unsigned(4095, 12)); 
 

lut_addr <= phase_acc_reg(50-1 downto 36);
 
 lut: sincos_lut_14 
   port map( 
     clk_i   => clk_i,
     addr_i  => lut_addr,
     sin     => sin_o,
     cos     => cos_o
   );
 
 --Locked state detector
 process(clk_i)
begin
if rising_edge(clk_i) then
  if rst_i = '0' then
    ref_reg <= '0';
    dds_reg <= '0';
    ref_period_reg <= (others=>'0');
    dds_period_reg <= (others=>'0');
    ref_count_done_reg <= '0';
    dds_count_done_reg <= '0';
    ref_period_cntr_reg <= (others=>'0');
    dds_period_cntr_reg <= (others=>'0');
  else
    ref_reg <= ref_next;
    dds_reg <= dds_next;
    ref_period_reg <= ref_period_next;
    dds_period_reg <= dds_period_next;
    ref_count_done_reg <= ref_count_done_next;
    dds_count_done_reg <= dds_count_done_next;
    ref_period_cntr_reg <= ref_period_cntr_next;
    dds_period_cntr_reg <= dds_period_cntr_next;
  end if;
end if;
end process;

 --next state logic
 ref_next        <= ref_i;

 dds_next        <= dds_sync;

 ref_count_done_next  <= '1' when ((ref_next = '0') and (ref_reg = '1') and (ref_count_done_reg = '0')) else
                         '0' when ((ref_next = '1') and (ref_reg = '0') and (ref_count_done_reg = '1')) else
                         ref_count_done_reg;

 dds_count_done_next  <= '1' when ((dds_next = '0') and (dds_reg = '1') and (dds_count_done_reg = '0')) else
                         '0' when ((dds_next = '1') and (dds_reg = '0') and (dds_count_done_reg = '1')) else
                         dds_count_done_reg;

 ref_period_cntr_next <= (others => '0') when ((ref_next = '1') and (ref_reg = '0') and (ref_count_done_reg = '1')) else
                         std_logic_vector(unsigned(ref_period_cntr_reg) + 1);

 dds_period_cntr_next <= (others => '0') when ((dds_next = '1') and (dds_reg = '0') and (dds_count_done_reg = '1')) else
                    std_logic_vector(unsigned(dds_period_cntr_reg) + 1);

 ref_period_next <= ref_period_cntr_reg when ((ref_next = '0') and (ref_reg = '1') and (ref_count_done_reg = '0')) else
                    ref_period_reg;

 dds_period_next <= dds_period_cntr_reg when ((dds_next = '0') and (dds_reg = '1') and (dds_count_done_reg = '0')) else
                    dds_period_reg;
 --output
                  --if dds period is within +/- 25% of ref period, turn on local lock signal. 3/4 < x > 5/4
 locked_o        <= '1' when ((unsigned(dds_period_reg) > (3*unsigned(ref_period_reg)/4)) and (unsigned(dds_period_reg) < (5*unsigned(ref_period_reg)/4))) else '0';
 

end rtl;

