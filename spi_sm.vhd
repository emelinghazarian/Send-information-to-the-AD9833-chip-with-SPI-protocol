----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2023 04:38:37 PM
-- Design Name: 
-- Module Name: spi_sm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity spi_sm is
port( mclk: out STD_LOGIC;
      sclk: out STD_LOGIC;
      sdata: out STD_LOGIC;
      fsync: out STD_LOGIC;
      clock: in STD_LOGIC;
      reset: in STD_LOGIC   
);
end spi_sm;
architecture Behavioral of spi_sm is
component sys_clk is
Port ( clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       cnv_clk : out STD_LOGIC );
end component;
signal signal_clk : STD_LOGIC;
signal sig_fsync : STD_LOGIC;
signal sig_sclk : STD_LOGIC;

type state is ( reset_st, freqreg_st1,freqreg_st2, phasereg_st, set_st, controlreg_st, middle_state,middle_state2,middle_state3);
signal state_st : state := set_st;
  
begin
uut: sys_clk port map
     ( clk => clock,
       reset => reset,
       cnv_clk =>signal_clk );

process(signal_clk) --(clock,state_st,signal_clk,sig_sclk)

variable count:integer:=0;
variable control_register : unsigned(15 downto 0):="0010100000001010";
variable freq_value1: unsigned(15 downto 0):= "0001011110010111"; --MSB
variable freq_value2: unsigned(15 downto 0):= "1100000000000000";  --LSB
variable phase_value: unsigned(15 downto 0):= X"C000";  
variable sig_sdata : STD_LOGIC;
--variable sig_fsync: STD_LOGIC; 

begin
sig_sclk <=signal_clk and sig_fsync;
if rising_edge(signal_clk)  then
case state_st is 
when set_st =>
sig_fsync <= '0';
state_st <= controlreg_st;

when controlreg_st =>
sig_sdata := control_register(15-count) ;
if (count = 15) then
count := 0;
sig_fsync <= '1';
state_st <= middle_state;
else
count := count + 1;
end if;

when middle_state =>
sig_fsync <= '0';
sig_sdata :='X';
state_st <= freqreg_st1;

when freqreg_st1 =>
sig_sdata := freq_value1(15-count) ;
if (count = 15)then
count := 0;
sig_fsync <= '1';
state_st <= middle_state2;
else
count := count + 1;
end if;

when middle_state2 =>
sig_fsync <= '0';
sig_sdata :='X';
state_st <= freqreg_st2;

when freqreg_st2 =>
sig_sdata := freq_value2(15-count) ;
if (count = 15)then
count := 0;
sig_fsync <= '1';
state_st <= middle_state3;
else
count := count + 1;
end if;

when middle_state3 =>
sig_fsync <= '0';
sig_sdata :='X';
state_st <= phasereg_st;

when phasereg_st =>
sig_sdata := phase_value(15-count);
if (count = 15)then
count := 0;
sig_fsync <= '1';
state_st <= reset_st;
else
count := count + 1;
end if;

when reset_st =>
control_register := "0000000111000000";
sig_fsync <= '1';

end case;

fsync<= sig_fsync ;
sdata <= sig_sdata;
mclk <= signal_clk;
sclk <= sig_sclk;
end if;

end process;
end Behavioral;
