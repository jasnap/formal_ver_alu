-------------------------------------------------------------------------------
-- Title      : Testbench for design "alu"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : alu_tb.vhd
-- Author     : Jasna Popovic  <jpopovic@fronsw10>
-- Company    : 
-- Created    : 2017-08-28
-- Last update: 2017-08-28
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2017 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2017-08-28  1.0      jpopovic	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-------------------------------------------------------------------------------

entity alu_tb is

end entity alu_tb;

-------------------------------------------------------------------------------

architecture Behavioral of alu_tb is

  -- component ports
  signal data_in    : std_logic_vector(7 downto 0);
  signal tvalid_in  : std_logic;
  signal reset      : std_logic;
  signal tready_in  : std_logic;
  signal data_out   : std_logic_vector(15 downto 0);
  signal tvalid_out : std_logic;
  signal tready_out : std_logic;

  -- clock
  signal Clk : std_logic := '1';
  signal addr : integer := 0;

begin  -- architecture Behavioral

  -- component instantiation
  DUT: entity work.alu
    port map (
      data_in    => data_in,
      tvalid_in  => tvalid_in,
      clk        => clk,
      reset      => reset,
      tready_in  => tready_in,
      data_out   => data_out,
      tvalid_out => tvalid_out,
      tready_out => tready_out);

  -- clock generation
  Clk <= not Clk after 10 ns;
  reset <= '0' after 15 ns, '1' after 50 ns;
  tready_in <= '0' after 15 ns, '1' after 50 ns;
 -- waveform generation
  WaveGen_Proc: process
    variable seed1, seed2: positive;
    variable rand: real;
    variable range_of_rand: real := 100.0;
    variable opc, tr_num: integer := 0;
  begin
    -- insert signal assignments here
     if reset = '0' then 
        addr <= 0;
        data_in <= std_logic_vector(to_unsigned(opc, 8));
        tvalid_in <= '0';
     else
        if Clk'event and Clk = '1' then
            if tready_out = '1' then
                tvalid_in <= '1';
                if addr = 0 then
                    data_in <= std_logic_vector(to_unsigned(opc, 8));  
                    addr <= addr + 1;
                    if opc = 6 then
                      if tr_num = 1 then 
                       tr_num := 0;
                        opc := 0;
                      else 
                      tr_num := tr_num + 1;
                      end if;
                    elsif opc = 5 then
                      if tr_num = 1 then
                        tr_num := 0;
                        opc := 6;
                      else 
                      tr_num := tr_num + 1;
                      end if;
                    else 
                      opc := opc + 1;
                    end if; 

                elsif addr = 1 then
                    uniform(seed1, seed2, rand);
                    data_in <= std_logic_vector(to_unsigned(integer(rand*range_of_rand), 8));
                    addr <= addr + 1;
                 elsif addr = 2 then
                    uniform(seed1, seed2, rand);
                    data_in <= std_logic_vector(to_unsigned(integer(rand*range_of_rand), 8));
                    addr <= 0;            
                end if;   
            end if;
         end if;
      end if;
    wait until Clk = '1';

  end process WaveGen_Proc;

end architecture Behavioral;

