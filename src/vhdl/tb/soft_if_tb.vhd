library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mat_ctrl_pkg.all;
use work.soft_if_tb_pkg.all;

--Description: testbench to verify soft_if and indirectly verify mat_ctrl.

entity soft_if_tb is  
end soft_if_tb;

architecture rtl of soft_if_tb is
  
  component soft_if is
    port (
      clk   : in std_logic;
      reset : in std_logic;
      soft_set_vec : in std_logic;
      soft_vec_data_av : in std_logic;
      soft_vec_init : in std_logic_vector(SOFT_REG_WIDTH-1 downto 0);
      soft_set_rows : in std_logic;
      soft_bram_data_av : in std_logic;
      soft_bram_data : in std_logic_vector(SOFT_REG_WIDTH-1 downto 0);
      soft_num_comp : in std_logic_vector(SOFT_REG_WIDTH-1 downto 0);
      soft_start_mult : in std_logic;
      comp_result : out std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
      mat_ctrl_out_debug : out std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0));
  end component;

  signal clk : std_logic := '0';
  signal reset : std_logic;
  signal soft_set_vec : std_logic;
  signal soft_vec_data_av : std_logic;
  signal soft_vec_init : std_logic_vector(SOFT_REG_WIDTH-1 downto 0);
  signal soft_set_rows : std_logic;
  signal soft_bram_data_av : std_logic;
  signal soft_bram_data : std_logic_vector(SOFT_REG_WIDTH-1 downto 0);
  signal soft_num_comp : std_logic_vector(SOFT_REG_WIDTH-1 downto 0);
  signal soft_start_mult : std_logic;
  signal comp_result : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
  signal mat_ctrl_out_debug : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);

  constant clk_period : time := 100 ns;
  
begin  -- rtl

  uut_soft_if : soft_if
    port map (
      clk               => clk,
      reset             => reset,
      soft_set_vec      => soft_set_vec,
      soft_vec_data_av  => soft_vec_data_av,
      soft_vec_init     => soft_vec_init,
      soft_set_rows     => soft_set_rows,
      soft_bram_data_av => soft_bram_data_av,
      soft_bram_data    => soft_bram_data,
      soft_num_comp     => soft_num_comp,
      soft_start_mult   => soft_start_mult,
      comp_result       => comp_result,
      mat_ctrl_out_debug => mat_ctrl_out_debug);
  
  run_clk : process
    begin
      clk <= not clk;
      wait for clk_period/2;
    end process;

  test: process
    begin
      wait for clk_period;
      wait for 0 ns;

      reset <= '1';
      wait for clk_period;
      wait for 0 ns;
      
      reset <= '0';
      wait for clk_period;
      wait for 0 ns;
      
      config_vecq(clk_period, soft_set_vec, soft_vec_data_av, soft_vec_init);

      config_ramsq(clk_period, soft_set_rows, soft_bram_data_av, soft_bram_data);

      soft_set_rows <= '0';
      wait for clk_period;
      wait for 0 ns;

      soft_start_mult <= '1';
      soft_num_comp <= x"00000001";

      wait for 100 us;
      soft_start_mult <= '0';
      wait for clk_period;
      wait for 0 ns;

      config_rams2b(clk_period, soft_set_rows, soft_bram_data_av, soft_bram_data);

      soft_start_mult <= '1';

      wait for 50 us;
      soft_start_mult <= '1';
      
      wait;
    end process;
      

end rtl;
