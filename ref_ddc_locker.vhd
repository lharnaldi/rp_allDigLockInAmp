--
-- Copyright (C) 2016 L. Horacio Arnaldi
-- e-mail: arnaldi@cab.cnea.gov.ar
-- e-mail: lharnaldi@gmail.com
--
-- Laboratorio de Detección de Partículas y Radiación
-- Centro Atómico Bariloche
-- Comisión Nacional de Energía Atómica (CNEA)
-- San Carlos de Bariloche
-- Date: 24/04/2016
-- Revision:
-- Rev. 0.01 - File created
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--  
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ref_ddc_locker is
  generic (
    VER               : natural := 0;     --Code Version
    REV               : natural := 1;     --Code Revision
  );
  port(
		DDS_sync_output:in std_logic;
		reference_sync_wave: in std_logic; -- reference signal after zero crossing
		clk_in: in std_logic;
		local_lock_signal: out std_logic
);
end ref_ddc_locker;

architecture rtl of ref_ddc_locker is

signal ref_period_counter: std_logic_vector (31 downto 0):=(others=>'0');
signal DDS_period_counter: std_logic_vector (31 downto 0):=(others=>'0');
signal ref_period: std_logic_vector (31 downto 0):=(others=>'0');
signal DDS_period: std_logic_vector (31 downto 0):=(others=>'0');
signal previous_ref_state: std_logic:='0';
signal previous_DDS_state: std_logic:='0';
signal ref_count_done: boolean;
signal DDS_count_done: boolean;

begin

Process(clk_in)
begin
if rising_edge(clk_in) then
	previous_ref_state <= reference_sync_wave;
	previous_DDS_state <= DDS_sync_output;
	
	if ((reference_sync_wave = '1') and (previous_ref_state  = '0') and (ref_count_done = true) and (DDS_count_done = true)) then			--if reference pulse goes high, begin count
		ref_count_done <= false;
		DDS_count_done <= false;
		ref_period_counter <= (others =>'0'); -- 32bits
		DDS_period_counter <= (others =>'0');	
	else 
		ref_period_counter <= std_logic_vector(unsigned(ref_period_counter) + 1);
		DDS_period_counter <= std_logic_vector(unsigned(DDS_period_counter) + 1);
		
		if((reference_sync_wave = '0') and (previous_ref_state = '1') and (ref_count_done = false)) then		--if ref pulse goes low, record time
			ref_period <= ref_period_counter;
			ref_count_done<=true;
		end if;
		
		if ((DDS_sync_output = '0') and (previous_DDS_state = '1') and (DDS_count_done = false)) then		--if DDS pulse low, record
			DDS_period <= DDS_period_counter;
			DDS_count_done <=true;
		end if;
	end if;
	
	
	if ( (unsigned(DDS_period) > (3*unsigned(ref_period)/4)) and (unsigned(DDS_period) < (5*unsigned(ref_period)/4)) ) then		--if DDS period is within +/- 25% of ref period, turn on local lock signal. 3/4 < x > 5/4
		local_lock_signal <= '1';
	else
		local_lock_signal <= '0';
	end if;	

end if;
end process;

end rtl;
