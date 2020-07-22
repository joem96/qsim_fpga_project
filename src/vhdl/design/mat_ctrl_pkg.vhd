library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package mat_ctrl_pkg is

  --SET PARAMETERS HERE
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  --type of computation
  constant COMP_TYPE : string := "QUANTUM";
  --number of elements per segment
  constant NUM_ELEMENTS : integer := 2;                                
  --number of bits per element
  constant ELE_WIDTH : integer := 16;
  --number of segments the vector is broken down into (row of a ram)
  constant VEC_SEG : integer := 16;                                     
  --number of pipeline stages for adding process
  constant ADD_STAGES : integer  := 2;

  --software read/write register width
  constant SOFT_REG_WIDTH : integer := 32;
  --how many times we want to matrix multiply
  constant NUM_MAT_COMP : integer := 2;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  --Derived Params
  constant MAT_ROW   : integer := NUM_ELEMENTS*VEC_SEG;
  constant RAM_WIDTH : integer := NUM_ELEMENTS*ELE_WIDTH;
  constant RAM_DEPTH : integer := 516;                                 
  constant ADDR_SIZE : integer := 9;

  --num times software needs to write to populate vec.
  constant SOFT_NUM_POP_VEC : integer := NUM_ELEMENTS*VEC_SEG*ELE_WIDTH/SOFT_REG_WIDTH;
  --num times software needs to write to populate a ram row. 
  constant SOFT_NUM_POP_ELE : integer := RAM_WIDTH/SOFT_REG_WIDTH;
  
  --total number of stages =
  --adder stages + number of times we need to read from the ram
  --+ 1 cycle of clocking into elewise-multiplier + 1 cycle of
  --clocking into adder + 1 cycle of clocking into accum
  -- + 1 cycle of clocking in the computation result.
  constant TOT_STAGES : integer := ADD_STAGES + VEC_SEG + 4; 
  
  type ram_out is array (0 to MAT_ROW-1) of std_logic_vector(RAM_WIDTH-1 downto 0);
  type result is array (0 to MAT_ROW-1) of std_logic_vector(2*ELE_WIDTH-1 downto 0);

  --function for debugging
  function fill_vec (
    constant ELEMENTS  : integer;
    constant ELE_WIDTH : integer)
    return std_logic_vector;

end mat_ctrl_pkg;

package body mat_ctrl_pkg is

  function fill_vec (
    constant ELEMENTS  : integer;
    constant ELE_WIDTH : integer)
    return std_logic_vector is
    variable temp : std_logic_vector(ELEMENTS*ELE_WIDTH-1 downto 0);
  begin
    fill: for i in 0 to ELEMENTS-1 loop
      temp(ELE_WIDTH*(i+1)-1 downto ELE_WIDTH*i) := std_logic_vector(to_unsigned(i,16));
    end loop;
    return temp;
  end fill_vec;
end mat_ctrl_pkg;
