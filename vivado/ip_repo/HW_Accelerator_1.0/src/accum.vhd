library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Description: Takes input every cycle and accumulate that to the sum. Output
--that sum every cycle.

entity accum is
  generic (
    ELEMENTS  : integer := 5;
    ELE_WIDTH : integer := 8);
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    clear  : in  std_logic;
    input  : in  std_logic_vector(ELE_WIDTH-1 downto 0);
    output : out std_logic_vector(ELE_WIDTH-1 downto 0));
end accum;

architecture rtl of accum is

  signal sum : signed(ELE_WIDTH-1 downto 0);

begin  -- rtl

  add_input : process(clk)
    begin
      if(rising_edge(clk)) then
        if(reset = '1' or clear = '1') then
          sum <= (others => '0');
        else
          sum <= sum + signed(input);
        end if;
      end if;
    end process;

    output <= std_logic_vector(sum);

end rtl;
