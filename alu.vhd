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

  type t_op_code is(add, sub, mul, two_add8, two_sub8,two_add16, two_sub16, op_error);
  signal a_in, b_in: std_logic_vector(7 downto 0);
  signal result: std_logic_vector(16 downto 0);
  signal result_low, result_high : std_logic_vector(8 downto 0);
  signal op: t_op_code;
  signal op_code: std_logic_vector(2 downto 0);
  signal addr: integer := 0;
  signal a_plus_b: std_logic_vector(16 downto 0);
  signal a_minus_b: std_logic_vector(16 downto 0);
  signal cout_sig, cout_sig1, flag1, flag2, tvalid : std_logic := '0';

begin  -- architecture Behavioral

    --psl default clock is rising_edge(clk);
	--psl reset_a: assert always(not reset -> not tvalid_out);
	--psl tready_tvalid: assert always(tready_out -> not (tvalid_out));
	--psl tready_tvalid2: assert always(tvalid_out -> not tready_out);
	--psl tready_oneclk: assert always((tvalid_in and tvalid_out) -> next(not tvalid_out));
	--psl cout_1: assert always(((tvalid_in = '1') and (op = add)) and (data_out(8) = '1')) -> cout;
	--psl cout_2: assert always(((tvalid_in = '1') and (op = sub)) and (data_out(8) = '1')) -> cout;
	--psl cout_4: assert always(((tvalid_in = '1') and (op = two_add8)) and (data_out(8) = '1')) -> cout;
	--psl cout_5: assert always(((tvalid_in = '1') and (op = two_add8)) and (data_out(8) = '1')) -> cout;
	--psl cout_6: assert always(((tvalid_in = '1') and (op = two_add16)) and (result(16) = '1')) -> cout;
	--psl cout_7: assert always(((tvalid_in = '1') and (op = two_add16)) and (result(16) = '1')) -> cout;

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
        if tvalid_in = '1' then --and tready_in?
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
        else
        --	result <= "0000000000000000";
        	tvalid_out <= '0';
        --	tready_out <= '0';
        end if;       
    end if;
  end process;

process(op_code)is 
begin
	case(op_code) is
		when "000" => op <= add;
		when "001" => op <= sub;
		when "010" => op <= mul;
		when "011" => op <= two_add8;
		when "100" => op <= two_sub8;
		when "101" => op <= two_add16;
		when "110" => op <= two_sub16;
		when others => op <= op_error;
	end case;
end process;

process(clk) is
begin  -- process
    if clk'event and clk = '1' then
     case op is
        when add => result <= a_plus_b;                                                        --a+b           
                      tvalid <= '0';               
        when sub => result <= a_minus_b;                                                       --a-b
                      tvalid <= '0';
        when mul => result(15 downto 0) <= std_logic_vector(unsigned(a_in) * unsigned(b_in));  --a*b
                      tvalid <= '0';
        when two_add8 => result <= std_logic_vector(unsigned(a_plus_b) sll 1);                      --2*(a+b)
                      tvalid <= '0';
        when two_sub8 => result <= std_logic_vector(unsigned(a_minus_b) sll 1);                     --2*(a-b)
                      tvalid <= '0';
        when two_add16 => if flag1 = '1' then
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
        when two_sub16 => if flag2 = '1' then                                                        --2*(a-b)
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

process (result, op) is
begin
	case( op ) is
	
		when add => cout <= result(8);
		when sub =>	cout <= result(8);
		when mul => cout <= '0';
		when two_add8 => cout <= result(8);
		when two_sub8 => cout <= result(8);
		when two_add16 => cout <= result(16);
		when two_sub16 => cout <= result(16);
		when others => null;
	
	end case ;
end process;

data_out <= result(15 downto 0);

--psl result_add: assert always((op = add) and (tvalid_out = '1'))-> result = a_plus_b;
--psl result_sub: assert always((op = sub) and (tvalid_out = '1'))-> result = a_minus_b;
--psl result_mul: assert always((op = mul) and (tvalid_out = '1'))-> result(15 downto 0) = std_logic_vector(unsigned(a_in) * unsigned(b_in));
--psl result_two_add8: assert always((op = two_add8) and (tvalid_out = '1'))-> result = std_logic_vector(unsigned(a_plus_b) sll 1);
--psl result_two_sub8: assert always((op = two_sub8) and (tvalid_out = '1'))-> result = std_logic_vector(unsigned(a_minus_b) sll 1);
--psl result_two_add8_1: assert always(((op = two_add16) and (tvalid_out = '1')) and result_low(8) = '0')-> result(7 downto 0) = result_low(7 downto 0) and result(16 downto 8) = a_plus_b(8 downto 0);
--psl result_two_add16_2: assert always(((op = two_add16) and (tvalid_out = '1')) and result_low(8) = '1')-> result(7 downto 0) = result_low(7 downto 0) and result(16 downto 8) = std_logic_vector(unsigned(a_plus_b(8 downto 0)) + 1);
--psl result_two_sub16_1: assert always((op = two_add16) and (tvalid_out = '1')) and result_low(8) = '0'-> result(7 downto 0) = result_low(7 downto 0) and result(16 downto 8) = a_plus_b(8 downto 0);
--psl result_two_sub16_2: assert always((op = two_add16) and (tvalid_out = '1')) and result_low(8) = '1'-> result(7 downto 0) = result_low(7 downto 0) and result(16 downto 8) = std_logic_vector(unsigned(a_plus_b(8 downto 0)) + 1);

--psl data_out_result: assert always(tvalid_out -> data_out = result(15 downto 0));



end architecture Behavioral;
