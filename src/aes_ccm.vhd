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

-- AES-CCM top.


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

use ieee.numeric_std.all;


use work.aes_lib.all;

entity aes_ccm is
	port(	  clk: in std_logic;
		  rst : in std_logic;
		  
		  block_in : in std_logic_vector(127 downto 0);
		  key : in std_logic_vector(127 downto 0);
		  ctr_cnt : in std_logic_vector(127 downto 0);
		  iv_cbc : in std_logic_vector(127 downto 0);
		  
		   -- commands
		  
		  enc : in std_logic;
		  gen_key : in std_logic;
		  load_ctr_cnt : in std_logic;
		  
		   -- options
		  
		  mode : in std_logic; -- 0: ctr, 1: cbc
		  
		   -- outputs
		  		  
		  block_out : out std_logic_vector(127 downto 0);
                  block_ready : out std_logic;
                  key_ready : out std_logic);
	end aes_ccm;

architecture Behavioral of aes_ccm is

  type state_type is (idle, n_round_1, n_round_2, n_round_3, n_round_4, n_round_5, n_round_6, last_round_1,
                      last_round_2, last_round_3, last_round_4, last_round_5, last_round_6, pre, key_1, key_2, key_3);  
  
  signal state, next_state: state_type ;  
  signal block_in_s :  std_logic_vector(127 downto 0);
  signal sub_key_s :  std_logic_vector(127 downto 0);
  signal load_s :  std_logic;
  signal enc_s :  std_logic;
  signal last_s, rst_cnt :  std_logic;
  signal block_out_s, key_out, aes_ctr_cnt :  std_logic_vector(127 downto 0); 
  signal count: natural range 0 to 10;
  signal count_12: natural range 0 to 11;
  signal en_cnt : std_logic;

  signal key_addr_1, key_addr_2 : std_logic_vector(3 downto 0);
  signal key_data_1, key_data_delay_1, key_data_2, key_data_delay_2, aes_cbc_reg : std_logic_vector(127 downto 0);
  signal key_load, rst_cnt_12, key_start, key_ready_s, key_rst, load_cbc_reg : std_logic;
  
  signal dram_write : std_logic;
  signal dram_data : std_logic_vector(127 downto 0);

  signal update_ctr, aes_cbc_start_flag, set_aes_cbc_start_flag : std_logic;

begin

  process1: process (clk,rst)  
  begin  
    if (rst ='1') then  
      state <= idle;  
    elsif rising_edge(clk) then  
      state <= next_state;  
    end if;  
  end process process1; 
 
  process2 : process (state, enc, gen_key, block_in, key, block_out_s, count_12, mode, aes_cbc_start_flag)
    variable block_reg_v : std_logic_vector(127 downto 0);
  begin  
    next_state <= state;
    
    block_reg_v := (others => '0');
    block_in_s <= (others => '0');

   sub_key_s <= (others => '0');
   
   enc_s <= '0';
   load_s <= '0';
   last_s <= '0';
   block_ready <= '0';
   key_ready <= '0';
   key_start <= '0';
   
   rst_cnt <= '0';
   rst_cnt_12 <= '0';
   key_rst <= '0';
   key_load <= '0';
   update_ctr <= '0';
   load_cbc_reg <= '0';
   set_aes_cbc_start_flag <= '0';

    case state is  
          when idle => 
            if (enc ='1' and gen_key = '0') then  
              next_state <= pre;  
            elsif (enc = '0' and gen_key = '1') then
              next_state <= key_1;
            else
              next_state <= idle; 
            end if; 
          when pre =>
            rst_cnt <= '0';
            
            if mode = '0' then 
            
             for i in 0 to 127 loop
               block_reg_v(i) := aes_ctr_cnt(i) xor key(i);
             end loop;
            
            else

             if aes_cbc_start_flag = '0' then
   
              set_aes_cbc_start_flag <= '1';
              
              for i in 0 to 127 loop
               block_reg_v(i) := (block_in(i) xor iv_cbc(i)) xor key(i);
              end loop;
             
             else 
              
              for i in 0 to 127 loop
               block_reg_v(i) := (block_in(i) xor aes_cbc_reg(i)) xor key(i);
              end loop;

             end if;
            
            end if;   
            
            load_s <= '1';            
            enc_s <= '0';
            
            sub_key_s <= key_data_2;
            block_in_s <= block_reg_v;

            next_state <= n_round_1;
          when n_round_1 => 
            enc_s <= '1';
            load_s <= '0';
            
            next_state <= n_round_2;
            
          when n_round_2 =>
            enc_s <= '1';
            load_s <= '0';
            
            next_state <= n_round_3;
          when n_round_3 =>
            enc_s <= '1';
            load_s <= '0';

            next_state <= n_round_4;
          when n_round_4 =>

            enc_s <= '1';
            load_s <= '0';
            
            next_state <= n_round_5;   
          when n_round_5 =>
            enc_s <= '1';
            load_s <= '0';
              
            next_state <= n_round_6;
          when n_round_6 =>
            enc_s <= '1';
            load_s <= '1';
            
            sub_key_s <=  key_data_2;
            block_in_s <= block_out_s;
            
            if count = 9 then
              next_state <= last_round_1;
            else            
              next_state <= n_round_1;
            end if;                         
          when last_round_1 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';
            
            next_state <= last_round_2;
          when last_round_2 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';

            next_state <= last_round_3;
          when last_round_3 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';

            next_state <= last_round_4;
          when last_round_4 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';

            next_state <= last_round_5;
          when last_round_5 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';
            
            rst_cnt <= '1';
            next_state <= last_round_6;
          when last_round_6 =>
            enc_s <= '1';
            load_s <= '0';
            last_s <= '1';
            
            block_ready <= '1';
            
            if mode = '0' then
             update_ctr <= '1';
            else
             load_cbc_reg <= '1';
            end if;
            
            rst_cnt <= '0';
            next_state <= idle;
           when key_1 =>
             key_rst <= '1';
             next_state <= key_2;
           when key_2 =>
             key_rst <= '0';
             key_load <= '1';
             
             rst_cnt_12 <= '1';
             
             next_state <= key_3;
           when key_3 =>
             key_load <= '0';
             key_start <= '1';
             
             rst_cnt_12 <= '0';
             
             if count_12 = 11 then
              key_ready <= '1';
              next_state <= idle;
             else 
              next_state <= key_3;
             end if;        
    end case;  
          
  end process process2; 

  write_keys: process(clk, rst, state, count_12, key_ready_s, key_out)
   variable skip_first : std_logic;
  begin
   if rising_edge(clk) then
    if (rst = '1') then
     skip_first := '0';
    elsif (state = key_3 and key_ready_s = '1') then
     if skip_first = '0' then
      skip_first := '1';
      
      dram_write <= '0';
      dram_data <= (others => '0'); 
      key_addr_1 <= (others => '0');
     else
      if ((count_12 - 1) < 10) then 
       dram_write <= '1';
       dram_data <= key_out;
       key_addr_1 <= std_logic_vector(to_unsigned(count_12 - 1, key_addr_1'length));
      else
       dram_write <= '0';
       dram_data <= (others => '0');
       key_addr_1 <= (others => '0');
      end if; 
     end if;
    else
     dram_write <= '0';
     dram_data <= (others => '0'); 
     key_addr_1 <= (others => '0');
    end if;
   end if;
  
  end process;

  mod_10_cnt : process(clk, rst_cnt)
  begin
    if rising_edge(clk) then
      if (rst_cnt = '1') then
        count <= 0;
      elsif(en_cnt = '1' and (state = n_round_1)) then
        if (count = 9) then
          count <= 0;
        else
          count <= count + 1;
        end if;
      end if;
     end if; 
  end process mod_10_cnt;

  mod_11_cnt : process(clk, rst_cnt_12)
  begin
    if rising_edge(clk) then
      if (rst_cnt_12 = '1') then
        count_12 <= 0;
      elsif(key_ready_s = '1') then
        if (count_12 = 11) then
          count_12 <= 0;
        else
          count_12 <= count_12 + 1;
        end if;
      end if;
     end if; 
  end process mod_11_cnt;

  en_cnt <= '1';
  
  AES_ROUND_N : entity work.aes_enc(Behavioral) port map (clk, 
                                                          rst, 
                                                          block_in_s, 
                                                          sub_key_s, 
                                                          load_s, 
                                                          enc_s, 
                                                          last_s,
                                                          block_out_s);
 
  SUB_KEYS_DRAM : entity work.dual_mem(rtl) generic map (4, 128, 10)
                                            port map (clk,
                                                      dram_write,
                                                      key_addr_1,
                                                      key_addr_2,
                                                      dram_data,
                                                      key_data_1,
                                                      key_data_2);
 
  key_addr_2 <= std_logic_vector(to_unsigned(count, key_addr_2'length));

  block_out <= (block_out_s xor block_in) when mode = '0' else 
               block_out_s;

  KEY_GEN : entity work.key_schedule(Behavioral) port map (clk,
                                                           key_rst,
                                                           key_load,
                                                           key_start,
                                                           key,
                                                           key_ready_s, 
                                                           key_out);  

   -- aes-ctr counter
    
  ctr_counter: process (clk, rst, load_ctr_cnt, ctr_cnt, update_ctr)
  begin
   if rising_edge(clk) then
    if rst = '1' then
     aes_ctr_cnt <= (others => '0');
    elsif (load_ctr_cnt ='1') then
     aes_ctr_cnt <= ctr_cnt;
    elsif update_ctr = '1' then 
     aes_ctr_cnt <= aes_ctr_cnt + 1;
    end if;
   end if;
  end process;

  -- cbc Ci-1 reg

  cbc_reg : process(clk, rst, load_cbc_reg, block_out_s)
  begin
   if rising_edge(clk) then
    if rst = '1' then
     aes_cbc_reg <= (others => '0');
    elsif load_cbc_reg = '1' then
     aes_cbc_reg <= block_out_s; 
    end if;
   end if; 
  end process;

  -- cbc start flag

  cbc_s_f : process(clk, rst, set_aes_cbc_start_flag)
  begin
   if rising_edge(clk) then
    if rst = '1' then
     aes_cbc_start_flag <= '0';
    elsif set_aes_cbc_start_flag = '1' then
     aes_cbc_start_flag <= '1'; 
    end if;
   end if; 
  end process;

end Behavioral;

