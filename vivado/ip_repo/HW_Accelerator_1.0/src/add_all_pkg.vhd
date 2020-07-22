library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--Description: package file that has functions to help the add_all entity
--compute values before run time.

package add_all_pkg is

  type int_arr is array (integer range <>) of integer;
  
  --Purpose: find # input to gate given total inputs and # of stages
  function root_func (
    constant num_tot_in : integer;
    constant num_stages : integer)
    return integer;
    
  --Purpose: return a num_comp vector given generics
  function fill_num_comp (
    constant num_tot_in : integer;
    constant num_stages : integer;
    constant num_in     : integer)
    return int_arr;
  
end package add_all_pkg;

package body add_all_pkg is
  
  function root_func (
    constant num_tot_in : integer;
    constant num_stages : integer)
    return integer is
    variable x : integer := 1;
  begin
    while (x**num_stages < num_tot_in) loop
      x := x + 1;
    end loop;
    return x;
  end root_func;
  
  function fill_num_comp (
    constant num_tot_in : integer;
    constant num_stages : integer;
    constant num_in     : integer)
    return int_arr is
    variable num_comp : int_arr(0 to num_stages) := (others => num_tot_in);
  begin  -- fill_num_comp
    
    for i  in 0 to num_stages loop
      num_comp(i) := (num_comp(i)+num_in**(i)-1)/(num_in**(i));
    end loop;
    return num_comp;
  end fill_num_comp;

end package body add_all_pkg;

