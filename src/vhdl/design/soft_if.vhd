library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mat_ctrl_pkg.all;

--Description: soft_if serves as the interface between the the mat_ctrl
--hardware and Vivado-generated AXI IP. Vivado's IP will communicate with
--soft_if by sending vector data, sending matrix rows, initiate computation,
--and read computation results. As a response, soft_if will take these commands
--and talk to the mat_ctrl (configuring mat_ctrl's vector, configuring
--mat_ctrl's BRAM rows, starting computation... etc.).

entity soft_if is
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

    --for debug
    mat_ctrl_out_debug : out std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0));
end soft_if;

architecture rtl of soft_if is
  
  component  mat_ctrl is
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      bram_en    : in  std_logic;
      bram_wr_en : in  std_logic_vector(MAT_ROW-1 downto 0);
      bram_addr  : in  std_logic_vector(ADDR_SIZE-1 downto 0);
      bram_data  : in  std_logic_vector(RAM_WIDTH-1 downto 0);
      set_vec    : in  std_logic;
      vec_init   : in  std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
      start_mult : in  std_logic;
      output     : out std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0));
  end component;

  --counters to track clocking in software data
  signal soft_cnt_pop_vec : integer;
  signal soft_cnt_pop_ele : integer;
  signal soft_cnt_pop_ram_row : integer;
  signal soft_cnt_pop_mat_row : integer;
  signal soft_cnt_cycles : integer;

  --reg used to delay first configuring of bram row.
  signal first_delay : std_logic;
  signal soft_start_mult_reg : std_logic;
  signal mult_active : std_logic;

  --mat_ctrl interface
  signal bram_en : std_logic;
  signal bram_wr_en : std_logic_vector(MAT_ROW-1 downto 0);
  signal bram_addr : std_logic_vector(ADDR_SIZE-1 downto 0);
  signal bram_data : std_logic_vector(RAM_WIDTH-1 downto 0);
  signal set_vec : std_logic;
  signal vec_init : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
  signal start_mult : std_logic;
  signal mat_ctrl_out : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
  
begin  -- rtl

  u_mat_ctrl : mat_ctrl
    port map (
      clk        => clk,
      reset      => reset,
      bram_en    => bram_en,
      bram_wr_en => bram_wr_en,
      bram_addr  => bram_addr,
      bram_data  => bram_data,
      set_vec    => set_vec,
      vec_init   => vec_init,
      start_mult => start_mult,
      output     => mat_ctrl_out);

  run_interface : process(clk)
    begin
      if(rising_edge(clk)) then
        if(reset = '1') then
          bram_en <= '0';
          bram_wr_en <= (others => '0');
          bram_wr_en(0) <= '1';
          bram_addr <= (others => '0');
          bram_data <= (others => '0');
          set_vec <= '0';
          vec_init <= (others => '0');
          soft_start_mult_reg <= '0';
          start_mult <= '0';
          mult_active <= '0';
          comp_result <= (others => '0');
          first_delay <= '0';

          soft_cnt_pop_vec <= 0;
          soft_cnt_pop_ele <= 0;
          soft_cnt_pop_ram_row <= 0;
          soft_cnt_pop_mat_row <= 0;
          soft_cnt_cycles <= 0;
          
        else

          soft_start_mult_reg <= soft_start_mult;
          
          --logic to clock in values from software and populate vec_init until
          --it completely fills up. After it does, configure mat_ctrl unit
          --with vec_init and reset count. 
          if(soft_set_vec = '1' and soft_vec_data_av = '1') then
            vec_init(SOFT_REG_WIDTH*(soft_cnt_pop_vec+1)-1 downto SOFT_REG_WIDTH*(soft_cnt_pop_vec)) <= soft_vec_init;
            if(soft_cnt_pop_vec = SOFT_NUM_POP_VEC-1) then
              soft_cnt_pop_vec <= 0;
              set_vec <= '1';
            else
              soft_cnt_pop_vec <= soft_cnt_pop_vec + 1;
            end if;
          end if;
          if(soft_cnt_pop_vec = 0) then
            set_vec <= '0';
          end if;

          --logic to clock in values from software and populate bram stored in
          --mat_ctrl. 
          if(soft_set_rows = '1' and soft_bram_data_av = '1') then
            bram_en <= '0';
            bram_data(SOFT_REG_WIDTH*(soft_cnt_pop_ele+1)-1 downto SOFT_REG_WIDTH*(soft_cnt_pop_ele)) <= soft_bram_data;
            --done filling up bram row. Send bram data.
            if(soft_cnt_pop_ele = SOFT_NUM_POP_ELE-1) then
              soft_cnt_pop_ele <= 0;
              bram_en <= '1';
              --done filling up 1 bram.
              if(soft_cnt_pop_ram_row = VEC_SEG-1) then
                soft_cnt_pop_ram_row <= 0;
                bram_addr <= (others => '0');
                --done filling up all brams.
                --note: actually won't get into this if, because when we are at
                --MAT_ROW-1, all available data has came in already.
                if(soft_cnt_pop_mat_row = MAT_ROW-1) then
                  soft_cnt_pop_mat_row <= 0;
                  bram_addr <= (others => '0');
                  bram_en <= '0';
                  bram_wr_en <= (others => '0');
                  bram_wr_en(0) <= '1';
                  first_delay <= '0';
                else
                  soft_cnt_pop_mat_row <= soft_cnt_pop_mat_row + 1;
                  bram_wr_en <= bram_wr_en(MAT_ROW-2 downto 0) & '0';
                end if;
              else
                if(bram_wr_en(0) = '1' and to_integer(unsigned(bram_addr)) = 0) then
                  first_delay <= '1';
                end if;
                if(first_delay = '1') then                  
                  bram_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(bram_addr))+1,bram_addr'length));
                  soft_cnt_pop_ram_row <= soft_cnt_pop_ram_row + 1;
                end if;
              end if;
            else
              soft_cnt_pop_ele <= soft_cnt_pop_ele + 1;
              bram_en <= '0';
            end if;
          --When there are no available data to write, turn bram enable off.
          --When not even in bram configuring mode, reset all data. 
          else
            bram_en <= '0';
            if(soft_set_rows = '0') then
              soft_cnt_pop_ele <= 0;
              soft_cnt_pop_mat_row <= 0;
              soft_cnt_pop_ram_row <= 0;
              bram_addr <= (others => '0');
              bram_en <= '0';
              bram_wr_en <= (others => '0');
              bram_wr_en(0) <= '1';
              first_delay <= '0';
            end if;
          end if;

          --if software triggers start of computation, then start the
          --computation for mat_ctrl. After, certain amount of computation
          --cycles, turn off everything and clock output of the computation.
          if(soft_start_mult = '1') then
            if(mult_active = '1' or soft_start_mult_reg /= soft_start_mult) then
              mult_active <= '1';
              start_mult <= '1';
              if(soft_cnt_cycles = (TOT_STAGES + 2)*to_integer(unsigned(soft_num_comp))) then
                soft_cnt_cycles <= 0;
                start_mult <= '0';
                mult_active <= '0';
                comp_result <= mat_ctrl_out;
              else
                soft_cnt_cycles <= soft_cnt_cycles + 1;
              end if;
            end if;
          end if;
          
        end if;  
      end if;
    end process;

    --for debug
    mat_ctrl_out_debug <= mat_ctrl_out;
end rtl;
