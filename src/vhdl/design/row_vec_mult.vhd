library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Description: row_vec_mult takes in a row (or part of a row) and a vector
--and outputs their multiplication. It instantiates a mult_ele_wise, which
--element_wise multiplies the row and vector, an add_all, which takes the
--element-wise product and adds them together, and an accum, which accumulates
--the sum every cycle (because each sum can just be the product of the vector
--and PART of the row, so accumulating the sum = the product of the vector and
--the WHOLE row).

entity row_vec_mult is
  
  generic (
    ELEMENTS   : integer := 8;
    ELE_WIDTH  : integer := 8;
    ADD_STAGES : integer := 4);

  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    clear  : in  std_logic;
    row    : in  std_logic_vector(ELEMENTS*ELE_WIDTH-1 downto 0);
    vec    : in  std_logic_vector(ELEMENTS*ELE_WIDTH-1 downto 0);
    output : out std_logic_vector(2*ELE_WIDTH-1 downto 0));

end row_vec_mult;

architecture rtl of row_vec_mult is

  component mult_elewise is
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
  end component;

  component add_all is
    generic(
      ELEMENTS    : integer := 20;
      STAGES      : integer := 4;
      ELE_WIDTH   : integer := 8);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      clear  : in  std_logic;
      input  : in  std_logic_vector(ELEMENTS*ELE_WIDTH-1 downto 0);
      output : out std_logic_vector(ELE_WIDTH-1 downto 0));
  end component;

  component accum is
    generic (
      ELEMENTS  : integer := 5;
      ELE_WIDTH : integer := 8);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      clear  : in  std_logic;
      input  : in  std_logic_vector(ELE_WIDTH-1 downto 0);
      output : out std_logic_vector(ELE_WIDTH-1 downto 0));
  end component;

  signal elewise_out : std_logic_vector(2*ELEMENTS*ELE_WIDTH-1 downto 0);
  signal added_out : std_logic_vector(2*ELE_WIDTH-1 downto 0);
  
begin  -- rtl

  u_mult_elewise : mult_elewise
    generic map (
      ELEMENTS  => ELEMENTS,
      ELE_WIDTH => ELE_WIDTH)
   port map (
     clk    => clk,
     reset  => reset,
     clear  => clear,
     input1 => row,
     input2 => vec,
     output => elewise_out);

  u_add_all : add_all
    generic map (
      ELEMENTS  => ELEMENTS,
      ELE_WIDTH => ELE_WIDTH*2,
      STAGES    => ADD_STAGES)
    port map (
      clk    => clk,
      reset  => reset,
      clear  => clear,
      input  => elewise_out,
      output => added_out);

  u_accum : accum
    generic map (
      ELEMENTS  => ELEMENTS,
      ELE_WIDTH => ELE_WIDTH*2)
    port map (
      clk    => clk,
      reset  => reset,
      clear  => clear,
      input  => added_out,
      output => output);

end rtl;
