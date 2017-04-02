library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avg_filter is
  port(
    clk_i: in std_logic;
    signal_i: in std_logic_vector(31 downto 0);
    signal_o: out std_logic_vector(31 downto 0);
    --SPARTAN_clk: in std_logic;
    DDS_square_wave: in std_logic;
    quantity: out std_logic_vector(23 downto 0);
    sum: out std_logic_vector(33 downto 0)
);
end avg_filter;

architecture rtl of avg_filter is

signal quantity_counter: unsigned (23 downto 0):= ((0)=>'1', others=>'0');
signal signal_acc: signed (33 downto 0):=(others=>'0');
signal average: std_logic_vector (31 downto 0):=(others=>'0');
signal previous_DDS_state: std_logic:='0';


begin

signal_o<= average;
--signal_o<= to_bcd(std_logic_vector(resize(signed(average), 16)));
--signal_o<= std_logic_vector(signed(signal_i)/512);

Process(clk_i)
variable average_int: signed (31 downto 0):=(others=>'0');
variable signal_acc_unsigned: unsigned (33 downto 0):=(others=>'0');
variable signal_acc_shifted: unsigned (23 downto 0):=(others=>'0');
begin
if rising_edge(clk_i) then
  previous_DDS_state <= DDS_square_wave;

  if ((DDS_square_wave = '1') and (previous_DDS_state  = '0')) then      --if reference pulse goes high, begin count

    if signal_acc(33)='1' then
      --signal_acc_unsigned:=unsigned(std_logic_vector(signal_acc) xor all_ones_36)+1;
      signal_acc_unsigned:=unsigned(-signal_acc);      
    else
      signal_acc_unsigned:=unsigned(signal_acc);
    end if;
    signal_acc_shifted:=resize(shift_right(signal_acc_unsigned, 9), 24);
    
    average_int:=signed("00000000" & divide(signal_acc_shifted, quantity_counter));
    
    if signal_acc(33)='1' then
      average_int:=-average_int;  
    else
      average_int:=average_int;
    end if;
    average<=std_logic_vector(average_int);
    quantity_counter <=((0)=>'1', others=>'0');
    signal_acc<=(others=>'0');
    sum<=std_logic_vector(signal_acc);
    quantity<=std_logic_vector(quantity_counter);
  else -- it counts for both positive and negative periods, but period is taken for one
    quantity_counter <= quantity_counter + 1;
    signal_acc<=signal_acc + signed(signal_i);
  end if;
  
end if;
end process;

end rtl;

