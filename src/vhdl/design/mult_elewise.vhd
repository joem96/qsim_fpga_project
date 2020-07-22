library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Description: takes two vectors and multiplies element-wise and outputs a
--vector with twice the size.

entity mult_elewise is
  generic (
    ELEMENTS  : integer := 20;
    ELE_WIDTH : integer := 8);

  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    clear  : in  std_logic;
    input1 : in  std_logic_vector(ELEMENTS*ELE_WIDTH-1 downto 0);
    input2 : in  std_logic_vector(ELEMENTS*ELE_WIDTH-1 downto 0);
    output : out std_logic_vector(2*ELEMENTS*ELE_WIDTH-1 downto 0));
end mult_elewise;

architecture rtl of mult_elewise is

  signal out_vec : signed(2*ELEMENTS*ELE_WIDTH-1 downto 0);

begin  -- rtl

  process(clk)
    begin
      if(rising_edge(clk)) then
        if(reset = '1' or clear = '1') then
          out_vec <= (others => '0');
        else  
          mult_elements: for i in 0 to ELEMENTS-1 loop
            out_vec(2*ELE_WIDTH*(i+1)-1 downto 2*ELE_WIDTH*i) <= signed(input1(ELE_WIDTH*(i+1)-1 downto ELE_WIDTH*i))*signed(input2(ELE_WIDTH*(i+1)-1 downto ELE_WIDTH*i));
          end loop mult_elements;
        end if;
      end if;
    end process;
  output <= std_logic_vector(out_vec);
end rtl;
