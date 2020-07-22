library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library work;
use work.add_all_pkg.all;

--Description: Dual-Port Read-First Ram. Only port A can both read/write. port
--B can only read. 

entity bram is
  
  generic (
    WIDTH     : integer := 256;
    DEPTH     : integer := 2;
    ADDR_SIZE : integer := 1;
    FOR_TEST  : integer := 1);

  port (
    clk    : in  std_logic;
    enA    : in  std_logic;
    enB    : in  std_logic;
    wenA   : in  std_logic;
    addrA  : in  std_logic_vector(ADDR_SIZE-1 downto 0);
    addrB  : in  std_logic_vector(ADDR_SIZE-1 downto 0);
    dinA   : in  std_logic_vector(WIDTH-1 downto 0);
    doutA  : out std_logic_vector(WIDTH-1 downto 0);
    doutB  : out std_logic_vector(WIDTH-1 downto 0));
end bram ;

architecture rtl of bram is

  type ram_type is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
  
  signal ram : ram_type;

begin  -- rtl

  process(clk)
  begin
    if(rising_edge(clk)) then
      if(enA = '1') then
        if(wenA = '1') then
          ram(conv_integer(addrA)) <= dinA;
        end if;
        doutA <= ram(conv_integer(addrA));
      end if;
      if(enB = '1') then
        doutB <= ram(conv_integer(addrB));
      end if;
    end if;
  end process;

end rtl;
