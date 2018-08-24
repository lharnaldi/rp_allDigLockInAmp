library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_lia_tb is

end entity top_lia_tb;

architecture behavioral of top_lia_tb is

component lia
       generic(
        ADC_DATA_WIDTH : natural := 14;
       AXIS_TDATA_WIDTH: natural := 32
       );
        port(
        clk_i      : in std_logic;
        rst_i      : in std_logic;
        sig_i      : in std_logic_vector(AXIS_TDATA_WIDTH/2-1 downto 0); 
        I          : out std_logic_vector(9 downto 0);
        Q          : out std_logic_vector(9 downto 0);
        locked_o   : out std_logic
        );
end component;

    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal adc_sig : std_logic_vector(16-1 downto 0);
    signal dds_sync_sig: std_logic := '0';
    signal dds_fbk: std_logic_vector(29 downto 0);
    signal comp_up, comp_dn :std_logic;
    signal I_sig, Q_sig : std_logic_vector(9 downto 0);
    signal lock_sig : std_logic;

begin

     --Generation of clk with after:
    clk <= not(clk) after 4 ns;
    
    --ref_sig <= not(ref_sig) after 30 ns; --20MHz signal
    --dds_sync_sig <= not(dds_sync_sig) after 31.1 ns; -- 21MHz signal
    --Generation of rst with wait for:
    process
    begin
        --wait for 10 ns;
        --rst <= '1';

        wait for 80 ns;
        rst <= '1';
        wait;
    end process;
--    rst <= '1' after 80 ns, '0' after 20 ns;

    --Generation of en with wait for:
--    process
--    begin
--        wait for 50 ns;
--        en <= '1';

--        wait for 600 ns;
--        en <= '0';
--        wait;
--    end process;
 
   --Generation of ud with wait for:
--     process
--     begin
--         wait for 500 ns;
--         ud <= '0';
 
--         wait for 500 ns;
--         ud <= '1';
--         wait;
--     end process;

    UUT: lia
    port map(
    	clk_i   => clk,
    	rst_i   => rst,
        sig_i   => adc_sig,
        I  => I_sig,
        Q  => Q_sig,
        locked_o => lock_sig 
    );
end behavioral;
