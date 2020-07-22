library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.add_all_pkg.all;
use work.mat_ctrl_pkg.all;

--Description: testbench to verify components: add_all, mult_elewise,
--row_vec_mult.

entity components_tb is
end components_tb;

architecture rtl of components_tb is

  constant clk_period : time := 100 ns;
  
  constant ELEMENTS : integer := 5;
  constant STAGES : integer := 2;
  constant ELE_WIDTH_1 : integer := 8;
  
  signal clk : std_logic := '0';
  signal reset : std_logic := '0';
  signal clear : std_logic := '0';
  signal input : std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
  signal output : std_logic_vector(ELE_WIDTH_1-1 downto 0);

  signal input1 : std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
  signal input2 : std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
  signal mult_out : std_logic_vector(2*ELEMENTS*ELE_WIDTH_1-1 downto 0);
  signal uut3_out : std_logic_vector(2*ELE_WIDTH_1-1 downto 0);

  signal bram_en : std_logic;
  signal bram_wr_en : std_logic_vector(MAT_ROW-1 downto 0);
  signal bram_addr : std_logic_vector(ADDR_SIZE-1 downto 0);
  signal bram_data : std_logic_vector(RAM_WIDTH-1 downto 0);
  signal set_vec : std_logic;
  signal vec_init : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
  signal start_mult : std_logic;
  signal out_mc : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0); 

  component add_all
    generic (
      ELEMENTS  : integer := 20;
      STAGES    : integer := 4;
      ELE_WIDTH : integer := 8);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      clear  : in  std_logic;
      input  : in  std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
      output : out std_logic_vector(ELE_WIDTH_1-1 downto 0));
  end component;

  component mult_elewise 
    generic (
      ELEMENTS  : integer := 20;
      ELE_WIDTH : integer := 8);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      clear  : in  std_logic;
      input1 : in  std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
      input2 : in  std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
      output : out std_logic_vector(2*ELEMENTS*ELE_WIDTH_1-1 downto 0));
  end component;

  component row_vec_mult
    generic (
      ELEMENTS   : integer;
      ELE_WIDTH  : integer := 8;
      ADD_STAGES : integer := 4);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      clear  : in  std_logic;
      row    : in  std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
      vec    : in  std_logic_vector(ELEMENTS*ELE_WIDTH_1-1 downto 0);
      output : out std_logic_vector(2*ELE_WIDTH_1-1 downto 0));
  end component;
  
begin  -- rtl

  uut: add_all
    generic map (
      ELEMENTS  => ELEMENTS,
      STAGES    => STAGES,
      ELE_WIDTH => ELE_WIDTH_1)
    port map (
      clk    => clk,
      reset  => reset,
      clear  => clear,
      input  => input1,
      output => output);

  uut2: mult_elewise
    generic map (
      ELEMENTS  => ELEMENTS,
      ELE_WIDTH => ELE_WIDTH_1)
    port map (
      clk    => clk,
      reset  => reset,
      clear  => clear,
      input1 => input1,
      input2 => input2,
      output => mult_out);

  uut3: row_vec_mult
    generic map (
      ELEMENTS  => ELEMENTS,
      ELE_WIDTH => ELE_WIDTH_1)
    port map (
      clk    => clk,
      reset  => reset,
      clear  => clear,
      row    => input1,
      vec    => input2,
      output => uut3_out);
  
  run_clk : process
    begin
      clk <= not clk;
      wait for clk_period/2;
    end process;

  run_test: process
    begin    
      
      wait for clk_period;
      wait for 0 ns;
      clear <= '0';
      reset <= '1';
      wait for clk_period;
      wait for 0 ns;
      
      reset <= '0';
      input1 <= x"0102010304";
      input2 <= x"0104070708";
      wait for clk_period;
      wait for 0 ns;

      reset <= '0';
      input1 <= x"0102010304";
      input2 <= x"0101010101";
      start_mult <= '1';
      wait for clk_period;
      wait for 0 ns;

      input1 <= x"0102010304";
      input2 <= x"02050A0C0D";
      wait;
      
    end process;

end rtl;
