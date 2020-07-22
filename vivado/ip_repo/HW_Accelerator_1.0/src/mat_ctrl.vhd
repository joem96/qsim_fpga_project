library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.mat_ctrl_pkg.all;

--Description: mat_ctrl holds all the BRAMS that store each matrix row and
--holds all the row_vec_mult, which computes the vector and matrix
--multiplication for each matrix row. It also has logic to send the
--BRAM data + input vector to the row_vec_mult, wait for computations to
--be done, and feed the results back to the input vector. Additional, it has an
--interface that talks to external modules - external modules can therefore
--set the input vector, set the matrix rows, start the computation, and read
--the results.

entity mat_ctrl is
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
end mat_ctrl;

architecture rtl of mat_ctrl is
  
  --read-side interface with BRAM'S
  signal addr : std_logic_vector(ADDR_SIZE-1 downto 0);
  signal enB  : std_logic;
  signal row_out : ram_out;

  --interface with row_vec_mult components
  signal vec : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH*VEC_SEG-1 downto 0);
    
    --:= fill_vec(NUM_ELEMENTS*VEC_SEG, ELE_WIDTH);

  signal vec_in : std_logic_vector(NUM_ELEMENTS*ELE_WIDTH-1 downto 0);
  signal vec_result : result;
  --clear resets the registers of row_vec_mult component. Set this to 1 when we
  --are about to start a new matrix computation.
  signal clear : std_logic;

  --internal signals
  --ptr will dictate which row we want to read from.
  signal ptr : integer range 0 to VEC_SEG;
  --counter to track which stage we're at in the multiplication
  signal stage_cnt : integer range 0 to TOT_STAGES;
  --reg signal of start_mult to track when it changes.
  signal start_mult_reg : std_logic;
 
  component bram
    generic (
      WIDTH     : integer;
      DEPTH     : integer;
      ADDR_SIZE : integer;
      FOR_TEST  : integer);
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
  end component;

  component row_vec_mult
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
  end component;
  
begin  -- rtl

  gen_mem: for i in 0 to MAT_ROW-1 generate
    mem : bram
      generic map (
        WIDTH     => RAM_WIDTH,
        DEPTH     => RAM_DEPTH,
        ADDR_SIZE => ADDR_SIZE,
        FOR_TEST  => i)
      port map (
        clk   => clk,
        enA   => bram_en,
        enB   => enB,
        wenA  => bram_wr_en(i),
        addrA => bram_addr,
        addrB => addr,
        dinA  => bram_data,
        doutA => open,
        doutB => row_out(i));
  end generate gen_mem;

  gen_mult: for i in 0 to MAT_ROW-1  generate
    mult: row_vec_mult
      generic map (
        ELEMENTS   => NUM_ELEMENTS,
        ELE_WIDTH  => ELE_WIDTH,
        ADD_STAGES => ADD_STAGES)
      port map (
        clk    => clk,
        reset  => reset,
        clear  => clear,
        row    => row_out(i),
        vec    => vec_in,
        output => vec_result(i));
  end generate gen_mult;

  operate_comp : process(clk)
    begin
      if(rising_edge(clk)) then
        
        --reset
        if(reset = '1') then
          enB <= '0';
          vec_in <= (others => '0');
          clear <= '1';
          ptr <= 0;
          stage_cnt <= 0;
          start_mult_reg <= '0';
          
        --vec input gets initial values externally
        elsif set_vec = '1' then
          vec <= vec_init;

        --when computation is turned off, set everything to reset levels except
        --vec
        elsif start_mult = '0' then
          enB <= '0';
          clear <= '1';
          ptr <= 0;
          stage_cnt <= 0;
          start_mult_reg <= '0';
          
        --external signal triggers the start of the computations
        elsif start_mult = '1' then

          --default signals
          enB <= '1';
          vec_in <= (others => '0');
          clear <= '1';
          start_mult_reg <= start_mult;

          --this if makes sure we have 1 cycle at the start to send a ptr = 0.
          if(start_mult = start_mult_reg) then
            clear <= '0';

            --ptr increments and points to bram row until all rows are reached.
            --Then, wait for stage_cnt. 
            if(ptr /= VEC_SEG) then
              ptr <= ptr + 1;
              vec_in <= vec(RAM_WIDTH*(ptr+1)-1 downto RAM_WIDTH*(ptr));
            end if;

            --stage_cnt increments until reaches max. Then, reset both ptr and
            --stage_cnt and feed the result of current computation as the input
            --vec of next computation.
            if(stage_cnt /= TOT_STAGES-1) then
              stage_cnt <= stage_cnt + 1;
            else
              ptr <= 0;
              stage_cnt <= 0;

              --debugging uses unsigned integer computation. real implementation uses
              --quantum computation (signed fractions).
              if (COMP_TYPE = "INT") then
                for i in 0 to MAT_ROW-1 loop
                  vec(ELE_WIDTH*(i+1)-1 downto ELE_WIDTH*(i))
                    <= std_logic_vector(to_signed(to_integer(signed(vec_result(i))),ELE_WIDTH));
                end loop;
              elsif (COMP_TYPE = "QUANTUM") then
                for i in 0 to MAT_ROW-1 loop
                  vec(ELE_WIDTH*(i+1)-1 downto ELE_WIDTH*(i))
                    <= vec_result(i)(2*ELE_WIDTH-1) & vec_result(i)(2*(ELE_WIDTH-2) downto 2*(ELE_WIDTH-2)-(ELE_WIDTH-2));
                end loop;
              end if;
              
              clear <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;

    addr <= std_logic_vector(to_unsigned(ptr, addr'length));
    output <= vec; 
end rtl;
