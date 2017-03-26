library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_lockin_amp is
	port(
  	clk_i: in std_logic;
  	SPI_SS_B: out  std_logic;
  	SPI_SCK : out  std_logic:='0';
  	AD_CONV : out  std_logic;
  	SPI_MISO : in  std_logic;
  	SPI_MOSI : out  std_logic;
  	AMP_CS : out  std_logic:='1';
  	AMP_SHDN : out  std_logic:='0';
  	DAC_CS: out std_logic;
  	LED : out std_logic_vector(7 downto 0);
  	sf_e: out std_logic;
  	e: out std_logic;
  	rs: out std_logic;
  	rw: out std_logic;
  	d: out std_logic;
  	c: out std_logic;
  	b: out std_logic;
  	a: out std_logic
);
end top_lockin_amp;

architecture rtl of top_lockin_amp is

signal signal_in: std_logic_vector (15 downto 0);
signal reference_in: std_logic_vector (15 downto 0);

signal X_display: std_logic_vector (20 downto 0);
signal Y_display: std_logic_vector (20 downto 0);
signal Z_display: std_logic_vector (20 downto 0);

signal signalI2: std_logic_vector (31 downto 0);
signal signalQ2: std_logic_vector (31 downto 0);

signal DDS_frequency: std_logic_vector (23 downto 0);

signal lock_in_clock: std_logic;

signal quantity1: std_logic_vector(23 downto 0);
signal sum1: std_logic_vector(33 downto 0);
signal quantity2: std_logic_vector(23 downto 0);
signal sum2: std_logic_vector(33 downto 0);

begin

ADC_in: entity work.adc 
port map ( 
	SPI_SS_B => SPI_SS_B,
	SPI_SCK => SPI_SCK,
	AD_CONV => AD_CONV,
	SPI_MISO => SPI_MISO,
	SPI_MOSI => SPI_MOSI,
	AMP_CS => AMP_CS,
	AMP_SHDN => AMP_SHDN,
	DAC_CS => DAC_CS, 
	clk_i => clk_i,
	DDS_frequency => DDS_frequency,
	lock_in_clock => lock_in_clock,
	signal_A => signal_in,
	signal_B => reference_in,
	LED => LED
);
			
lock_in_amplifier: entity work.lock_in_amp 
port map (
	signal_in => signal_in,
	reference_in => reference_in,
	clock_in => lock_in_clock,
	clk_i => clk_i,
	DDS_frequency => DDS_frequency,
	quantity1 => quantity1,
	sum1 => sum1,
	quantity2 => quantity2,
	sum2 => sum2,
	signalI2 => signalI2,
	signalQ2 => signalQ2
);

Show_characters: entity work.LCD_disp 
port map (
	clk_i => clk_i,
	data_in_X => X_display,
	data_in_Y => Y_display,
	data_in_Z => Z_display,
	sf_e => sf_e,
	e => e,
	rs => rs,
	rw => rw,
	d => d,
	c => c,
	b => b,
	a => a
);

X_display<=to_bcd(std_logic_vector(resize(signed(signalI2), 16)));
--X_display<=to_bcd(signal_in);
Y_display<=to_bcd(std_logic_vector(resize(signed(signalQ2), 16)));
--Y_display<=to_bcd(reference_in);
Z_display <= to_bcd(std_logic_vector(sqrt(resize(unsigned((signed(signalI2)*signed(signalI2)) + (signed(signalQ2)*signed(signalQ2))),32))));

end rtl;

