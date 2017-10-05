library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  
  port (
    data_in    : in  std_logic_vector(7 downto 0);
    tvalid_in  : in  std_logic;
    clk        : in  std_logic;
    reset      : in  std_logic;
    tready_in  : in  std_logic;
    tlast_in   : in  std_logic;
    data_out   : out std_logic_vector(15 downto 0);
    tvalid_out : out std_logic;
    tready_out : out std_logic;
    cout       : out std_logic);

end entity alu;

architecture Behavioral of alu is

  signal a_in, b_in: std_logic_vector(7 downto 0);
  signal result: std_logic_vector(16 downto 0);
  signal result_low, result_high : std_logic_vector(8 downto 0);
  signal op_code: std_logic_vector (2 downto 0);
  signal addr: integer := 0;
  signal a_plus_b: std_logic_vector(16 downto 0);
  signal a_minus_b: std_logic_vector(16 downto 0);
  signal cout_sig, flag1, flag2, tvalid : std_logic := '0';

begin  -- architecture Behavioral

    --asserts that must pass

    --psl default clock is rising_edge(clk);
    --psl reset_p: assert always(not (reset) -> not(tvalid_out));
    --psl tvalid_active: assert always(tvalid_out -> next (not (tvalid_out)));
    --psl tready_tvalid: assert always(not tready_out -> next (tvalid_out));
    --psl cout_tvalid: assert always (not tvalid_out -> not cout);
    -- check if tvalid_in -> tready mora biti aktivan 3 clk

    a_minus_b(8 downto 0) <= std_logic_vector(signed(a_in(a_in'high) & a_in) + signed(not(b_in(b_in'high) & b_in)) + 1);
    a_plus_b(8 downto 0)  <= std_logic_vector(signed(a_in(a_in'high) & a_in) + signed(b_in(b_in'high) & b_in));
    a_minus_b(16 downto 9) <= "00000000";
    a_plus_b(16 downto 9) <= "00000000";

 process (clk, reset) is
  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      tready_out <= '1';
      tvalid_out <= '0';
      a_in <= "00000000";
      b_in <= "00000000";
      op_code <= "000";
    elsif clk'event and clk = '1' then  -- rising clock edge
        if tvalid_in = '1' then
          case addr is
            when 0 => op_code <= data_in(2 downto 0);
                      addr <= addr + 1;
            when 1 => a_in <= data_in;
                      addr <= addr + 1;
            when 2 => b_in <= data_in;
                      tready_out <= '0';
                      addr <= addr + 1;
            when 3 => addr <= addr + 1;
                		  tvalid_out <= '1';
                		  if (tvalid = '1') then
                		      tvalid_out <= '0';
                		  end if;
            when 4 => addr <= 0;
                      tready_out <= '1';
                      tvalid_out <= '0';
            when others => null;
          end case;
        end if;       
    end if;
  end process;

process(clk) is
begin  -- process
    if clk'event and clk = '1' then
     case op_code is
        when "000" => result <= a_plus_b;                                                        --a+b         
                      cout_sig <= result(8);   
                      tvalid <= '0';               
        when "001" => result <= a_minus_b;                                                       --a-b
                      cout_sig <= result(8);
                      tvalid <= '0';
        when "010" => result(15 downto 0) <= std_logic_vector(unsigned(a_in) * unsigned(b_in));  --a*b
                      cout_sig <= '0';
                      tvalid <= '0';
        when "011" => result <= std_logic_vector(unsigned(a_plus_b) sll 1);                      --2*(a+b)
                      cout_sig <= result(8);
                      tvalid <= '0';
        when "100" => result <= std_logic_vector(unsigned(a_minus_b) sll 1);                     --2*(a-b)
                      cout_sig <= result(8);
                      tvalid <= '0';
        when "101" => if flag1 = '1' then
                        if result_low(8) = '1' then
                            result(16 downto 8) <= std_logic_vector(unsigned(a_plus_b(8 downto 0)) + 1);
                        else 
                        	result(16 downto 8) <= a_plus_b(8 downto 0);                            
                        end if;
                        result(7 downto 0) <= result_low(7 downto 0);
                        flag1 <= '0';
                        tvalid <= '1';
                      else
                        if addr = 2 then
                        	result_high <= a_plus_b(8 downto 0);
                        else 
                        	result_low <= a_plus_b(8 downto 0);
                        end if;
                        flag1 <= '1';
                        tvalid <= '0';
                      end if;  
        when "110" => if flag2 = '1' then                                                        --2*(a-b)
                        if result_low(8) = '1' then
                            result(16 downto 8) <= std_logic_vector(unsigned(a_minus_b(8 downto 0)) + 1);
                        else 
                        	result(16 downto 8) <= a_minus_b(8 downto 0);                            
                        end if;
                        result(7 downto 0) <= result_low(7 downto 0);
                        flag2 <= '0';
                        tvalid <= '1';
                      else
                      	if addr = 2 then
                        	result_high <= a_minus_b(8 downto 0);
                        else 
                        	result_low <= a_minus_b(8 downto 0);
                        end if;
                        flag2 <= '1';
                        tvalid <= '0';
                      end if;  
        when others => null;
      end case;   
    end if;

 end process;
data_out <= result(15 downto 0);
cout <= cout_sig;
end architecture Behavioral;