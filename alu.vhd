library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  
  port (
    data_in    : in  std_logic_vector(15 downto 0);
    tvalid_in  : in  std_logic;
    clk        : in  std_logic;
    reset      : in  std_logic;
    tready_in  : in std_logic;
    data_out   : out std_logic_vector(15 downto 0);
    tvalid_out : out std_logic;
    tready_out : out  std_logic);

end entity alu;

architecture Behavioral of alu is

  type data_array is array(natural range <>) of std_logic_vector(15 downto 0);
  signal a_in, b_in: std_logic_vector(15 downto 0);
  signal data_reg: data_array(2 downto 0);
  signal result: std_logic_vector(15 downto 0);
  signal op_code: std_logic_vector (2 downto 0);
  signal addr: integer := 0;

begin  -- architecture Behavioral



 process (clk, reset) is
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      data_out<= "0000000000000000";
      tvalid_out <= '0';
      tready_out <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
        tready_out <= '1';
        if tvalid_in = '1' then
          if addr < 3 then
            
            data_reg(addr) <= data_in;
            addr <= addr + 1;
          else
            tready_out <= '0';
            addr <= 0;
          end if;
          case addr is
              when 0 => op_code <= data_reg(addr)(2 downto 0);
              when 1 => a_in <= data_reg(addr);
              when 2 => b_in <= data_reg(addr);
              when others => null;
          end case;
         end if;       
    end if;
    
  end process;
  
process(clk) is
begin  -- process
    if clk'event and clk = '1' then
    
     case op_code is
        when "000" => result <= std_logic_vector(signed(a_in) + signed(b_in));
        when "001" => result <= std_logic_vector(signed(a_in) - signed(b_in));
        when "010" => result <= std_logic_vector(signed(a_in) * signed(b_in));
        when others => null;
      end case; 
    end if;
    data_out<=result;
    tvalid_out <= '1';
   -- tready_out <= '0';

 end process;
 
end architecture Behavioral;