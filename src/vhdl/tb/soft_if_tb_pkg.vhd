library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mat_ctrl_pkg.all;

--Description: package that contains functions that help soft_if_tb. 

package soft_if_tb_pkg is

  procedure config_vec (
    constant clk_period : in time;
    signal   soft_set_vec : out std_logic;
    signal   soft_vec_data_av : out std_logic;
    signal   soft_vec_init : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_vecq (
    constant clk_period : in time;
    signal   soft_set_vec : out std_logic;
    signal   soft_vec_data_av : out std_logic;
    signal   soft_vec_init : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rows (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rows2 (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rows3b (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rows4b (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rowsq (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rams (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rams2 (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_rams2b (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));

  procedure config_ramsq (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0));
  
end soft_if_tb_pkg;

package body soft_if_tb_pkg is

  procedure config_vec (
    constant clk_period : in time;
    signal   soft_set_vec : out std_logic;
    signal   soft_vec_data_av : out std_logic;
    signal   soft_vec_init : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_set_vec <= '1';
      wait for clk_period;
      wait for 0 ns;

      soft_vec_data_av <= '1';
      soft_vec_init <= x"00010001";
      wait for clk_period*(14);
      wait for 0 ns;

      soft_vec_init <= x"00010003";
      wait for clk_period;
      wait for 0 ns;

      soft_vec_init <= x"00010001";
      wait for clk_period;
      wait for 0 ns;

      soft_vec_data_av <= '0';
      wait for clk_period;
      wait for 0 ns;
      
    end config_vec;

  procedure config_vecq (
    constant clk_period : in time;
    signal   soft_set_vec : out std_logic;
    signal   soft_vec_data_av : out std_logic;
    signal   soft_vec_init : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_set_vec <= '1';
      wait for clk_period;
      wait for 0 ns;

      soft_vec_data_av <= '1';
      -- 0.0025 & -0.03
      soft_vec_init <= x"FE150028";     
      wait for clk_period*(16);
      wait for 0 ns;

      soft_vec_data_av <= '0';
      wait for clk_period;
      wait for 0 ns;
      
    end config_vecq;

  procedure config_rows (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_bram_data_av <= '1';
      soft_bram_data <= x"00020001";
      wait for clk_period*2;
      wait for 0 ns;

      soft_bram_data <= x"00040003";
      wait for clk_period*((NUM_ELEMENTS*VEC_SEG)/2-4);
      wait for 0 ns;

      --testing to see if pausing breaks logic
      soft_bram_data_av <= '0';
      wait for 2 us;
      wait for 0 ns;
      soft_bram_data_av <= '1';

      soft_bram_data <= x"000B000A";
      wait for clk_period*2;
      wait for 0 ns;
    end config_rows;

  procedure config_rows2 (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_bram_data_av <= '1';
      soft_bram_data <= x"00000000";
      wait for clk_period;
      wait for 0 ns;

      soft_bram_data <= x"00080000";
      wait for clk_period;
      wait for 0 ns;

      soft_bram_data <= x"00000007";
      wait for clk_period;
      wait for 0 ns;

      soft_bram_data <= x"00000000";
      wait for clk_period*4;
      wait for 0 ns;

      soft_bram_data <= x"000C000C";
      wait for clk_period*3;
      wait for 0 ns;

      --testing to see if pausing breaks logic
      soft_bram_data_av <= '0';
      wait for 2 us;
      wait for 0 ns;
      
      soft_bram_data_av <= '1';
      soft_bram_data <= x"00000000";
      wait for clk_period*6;
      wait for 0 ns;
    end config_rows2;
    
  procedure config_rows3b (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_bram_data_av <= '1';
      soft_bram_data <= x"00000000";
      wait for clk_period*16;
      wait for 0 ns;
    end config_rows3b;

  procedure config_rows4b (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_bram_data_av <= '1';
      soft_bram_data <= x"00000000";
      wait for clk_period*14;
      wait for 0 ns;
      
      soft_bram_data <= x"00010000";
      wait for clk_period;
      wait for 0 ns;
      
      soft_bram_data <= x"00010001";
      wait for clk_period;
      wait for 0 ns;
    end config_rows4b;
    
  procedure config_rowsq (
    constant clk_period        : in  time;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_bram_data_av <= '1';
      soft_bram_data <= x"0B4F0B4F";    --0.1768
      wait for clk_period*16;
      wait for 0 ns;
    end config_rowsq;
    
  procedure config_rams (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_set_rows <= '1';
      wait for clk_period;
      wait for 0 ns;

      --config 32 rows
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);

      --testing to see if pausing breaks logic
      soft_bram_data_av <= '0';
      wait for 20 us;
      wait for 0 ns;
      soft_bram_data_av <= '1';
      
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      
      soft_bram_data_av <= '0';
      soft_set_rows <= '0';

    end config_rams;

  procedure config_rams2 (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_set_rows <= '1';
      wait for clk_period;
      wait for 0 ns;

      --config 32 rows
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);

      --testing to see if pausing breaks logic
      soft_bram_data_av <= '0';
      wait for 20 us;
      wait for 0 ns;
      soft_bram_data_av <= '1';
      
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      
      soft_bram_data_av <= '0';
      soft_set_rows <= '0';

    end config_rams2;

 procedure config_rams2b (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_set_rows <= '1';
      wait for clk_period;
      wait for 0 ns;

      --config 32 rows
      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);

      config_rows(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows2(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows3b(clk_period, soft_bram_data_av, soft_bram_data);
      config_rows4b(clk_period, soft_bram_data_av, soft_bram_data);
      
      soft_bram_data_av <= '0';
      soft_set_rows <= '0';

    end config_rams2b;

     procedure config_ramsq (
    constant clk_period        : in  time;
    signal   soft_set_rows     : out std_logic;
    signal   soft_bram_data_av : out std_logic;
    signal   soft_bram_data    : out std_logic_vector(SOFT_REG_WIDTH-1 downto 0)) is
    begin
      soft_set_rows <= '1';
      wait for clk_period;
      wait for 0 ns;

      --config 32 rows
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);

      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      config_rowsq(clk_period, soft_bram_data_av, soft_bram_data);
      
      soft_bram_data_av <= '0';
      soft_set_rows <= '0';

    end config_ramsq;
    
      
end soft_if_tb_pkg;
