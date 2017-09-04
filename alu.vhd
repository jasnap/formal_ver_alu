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
  signal a_plus_b: std_logic_vector(15 downto 0);
  signal a_minus_b: std_logic_vector(15 downto 0);

begin  -- architecture Behavioral

    a_plus_b <= std_logic_vector(signed(a_in) + signed(b_in));
    a_minus_b <= std_logic_vector(signed(a_in) - signed(b_in));


-- data instruction handling
 process (clk, reset, addr) is
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      data_out<= "0000000000000000";
      tvalid_out <= '0';
      tready_out <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
        if tvalid_in = '1' then
            data_reg(addr) <= data_in;
            if addr = 2 then
                addr <= 0;
                tready_out <= '0';
            else
                addr <= addr + 1;
            end if;
        end if;       
    end if;
    
  end process;
  
  op_code <= data_reg(0)(2 downto 0);
  a_in <= data_reg(1);
  b_in <= data_reg(2);
  
process(clk, op_code) is
begin  -- process
    if clk'event and clk = '1' then
     case op_code is
        when "000" => result <= a_plus_b;
        when "001" => result <= a_minus_b;
        when "010" => result <= std_logic_vector(signed(a_in) * signed(b_in));
        when others => null;
      end case; 
      tvalid_out<= '1';
      data_out <= result;
    end if;
 end process;


end architecture Behavioral;