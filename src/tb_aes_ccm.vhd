-- Copyright (c) 2011 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
                
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
                                
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_aes_ccm IS
END tb_aes_ccm;
 
ARCHITECTURE behavior OF tb_aes_ccm IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT aes_ccm
	port(	  clk: in std_logic;
		  rst : in std_logic;
		  
		  block_in : in std_logic_vector(127 downto 0);
		  key : in std_logic_vector(127 downto 0);
		  ctr_cnt : in std_logic_vector(127 downto 0);
		  iv_cbc : in std_logic_vector(127 downto 0);
		  
		  enc : in std_logic;
		  gen_key : in std_logic;
		  load_ctr_cnt : in std_logic;
		  
		  mode : in std_logic;
		  
		  block_out : out std_logic_vector(127 downto 0);
		  block_ready : out std_logic;
		  key_ready : out std_logic);
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal block_in : std_logic_vector(127 downto 0) := (others => '0');
   signal key : std_logic_vector(127 downto 0) := (others=> '0');
   signal enc : std_logic := '0';
   signal gen_key : std_logic := '0';
   signal ctr_cnt, iv_cbc : std_logic_vector(127 downto 0) := (others => '0');
   signal load_ctr_cnt, mode : std_logic := '0';
   
   
 	--Outputs
   signal block_out : std_logic_vector(127 downto 0);
   signal block_ready : std_logic;
   signal key_ready : std_logic;
   -- Clock period definitions
   constant clk_period : time := 10 ns;

   -- test blocks for ctr mode

   constant block_ctr_0 : std_logic_vector(127 downto 0) := X"0a00000000000000000000000000000a";
   constant block_ctr_1 : std_logic_vector(127 downto 0) := X"0b00000000000000000000000000000b";
   constant block_ctr_2 : std_logic_vector(127 downto 0) := X"0c00000000000000000000000000000c";
   constant block_ctr_3 : std_logic_vector(127 downto 0) := X"0d00000000000000000000000000000d";
   constant block_ctr_4 : std_logic_vector(127 downto 0) := X"0e00000000000000000000000000000e";
   constant block_ctr_5 : std_logic_vector(127 downto 0) := X"0f00000000000000000000000000000f";

   constant iv_cnt : std_logic_vector(127 downto 0)      := X"01010101010101010101010101010101";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: aes_ccm PORT MAP (
          clk => clk,
          rst => rst,
          
          block_in => block_in,
          key => key,
          ctr_cnt => ctr_cnt,
          iv_cbc => iv_cbc,
          
          enc => enc,
          gen_key => gen_key,
          load_ctr_cnt => load_ctr_cnt,
          
          mode => mode,
          
          block_out => block_out,
          block_ready => block_ready,
          key_ready => key_ready);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		
		-- reset
		
		wait for clk_period/2 + clk_period*2;
		rst <= '1';
		
		wait for clk_period;
		
		-- load aes-ctr counter
		
		rst <= '0';
		load_ctr_cnt <= '1';
		ctr_cnt <= (others => '0');
		
		wait for clk_period;
		
		-- gen subkeys
		
		load_ctr_cnt <= '0';
                key <= X"ab00ab00ab00ab00ab00ab00ab00ab00";

		gen_key <= '1';
                enc <= '0';		

		wait for 0.54 us;

		-- encrypt block # 1

		gen_key <= '0';
                enc <= '1';
                
                block_in <= block_ctr_0;                		
		
		wait for 0.64 us;

		-- encrypt block # 2

		gen_key <= '0';
                enc <= '1';
                		
                block_in <= block_ctr_1;
                		
		wait for 0.64 us;
		
		-- encrypt block # 3

		gen_key <= '0';
                enc <= '1';
                		
                block_in <= block_ctr_2;
                		
		wait for 0.64 us;
		
		-- encrypt block # 4

		gen_key <= '0';
                enc <= '1';
                		
                block_in <= block_ctr_3;
                		
		wait for 0.64 us;
		
		-- encrypt block # 5

		gen_key <= '0';
                enc <= '1';
                		
		block_in <= block_ctr_4;
		
		wait for 0.64 us;
		
		-- encrypt block # 6
		
		block_in <= block_ctr_5;

		wait for 0.52 us;
		
		enc <= '0';
		
		wait for 0.64 us;
		
		enc <= '1';
		
		-- encrypt cbc # 1
		
		mode <= '1';
		
		block_in <= block_ctr_0;
               	
               	iv_cbc <= iv_cnt;

               	wait for 0.60 us;
		
		block_in <= block_ctr_1;

		wait for 0.60 us;
		
		block_in <= block_ctr_2;
		
		wait for 0.60 us;
		
		block_in <= block_ctr_3;
		
		wait for 0.60 us;
		
		block_in <= block_ctr_4;
		
		wait for 0.60 us;
		
		block_in <= block_ctr_5;
				
                wait for 0.72 us;
                
                enc <= '0';               
                mode <= '0'; 
                
		load_ctr_cnt <= '1';
		ctr_cnt <= (others => '0');
		
		wait for clk_period;
		
		load_ctr_cnt <= '0';
		
		wait for 1.73 us;

                enc <= '1';
                		
		block_in <= X"0f0e0d0c0b0a09080706050403020100";
		
		wait for 0.62 us;
		
		enc <= '0';
		
		wait for 2.73 us;

                enc <= '1';
                		
		block_in <= X"0f0e0d0c0b0a09080706050403020100";
		key      <= X"0f0e0d0c0b0a09080706050403020100";

		wait for 0.62*2 us;
		
		enc <= '0';
		
		wait for 4.73 us;
		
		key <=      X"3c4fcf098815f7aba6d2ae2816157e2b";
		block_in <= X"2a179373117e3de9969f402ee2bec16b";
		
		gen_key <= '1';

		wait for 0.54 us;
		
		gen_key <= '0';
                enc <= '1';
                
                wait for 0.62 us;
                
                enc <= '0';
		
                wait;
   end process;

END;
