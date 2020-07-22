library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.add_all_pkg.all;

--Description: Takes in a vector which represents x elements and sums those
--elements up in a pipelined design. Pipeline depends on user-defined
--parameters. Also calls functions: root_func & fill_num_comp to calculate
--number of handles (how many elements we take per add) and number of
--computations per stage (how many adds we do per stage) during pre-runtime. 

entity add_all is
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
end add_all;

architecture rtl of add_all is
  
  constant NUM_HAND : integer := root_func(ELEMENTS, STAGES);
  constant NUM_COMP : int_arr := fill_num_comp(ELEMENTS, STAGES, NUM_HAND);

  --concurrent signal architecture
  type hand_sig is array (0 to NUM_HAND-1) of signed(ELE_WIDTH-1 downto 0);
  type comp_hand_sig is array (0 to NUM_COMP(1)-1) of hand_sig;
  type stg_comp_hand_sig is array (0 to STAGES-1) of comp_hand_sig;

  signal conc_sigs : stg_comp_hand_sig;

  --registered signal architecture
  type el_sig is array (0 to ELEMENTS-1) of signed(ELE_WIDTH-1 downto 0);
  type reg_el_sig is array (0 to STAGES) of el_sig;

  signal reg_sigs : reg_el_sig;
  
begin  -- rtl

  --update registered signals
  update_reg : process(clk)
  begin
    if(rising_edge(clk)) then
      if(reset = '1' or clear = '1') then
        reg_sigs <= (others => (others => (others => '0')));
      else  
        --clock in the input values into the stage 0 registers
        Update_First_Reg: for n in 0 to ELEMENTS-1 loop
          reg_sigs(0)(n) <= signed(input((n+1)*ELE_WIDTH-1 downto n*ELE_WIDTH));
        end loop;

        --clock in the computed values into the later stage registers
        Update_Regs: for n in 1 to STAGES loop
          Update_Elements: for i in 0 to NUM_COMP(n)-1 loop
            reg_sigs(n)(i) <= conc_sigs(n-1)(i)(NUM_HAND-1);
          end loop;
        end loop;
      end if;
    end if;
  end process;

  --update concurrent signals
  Update_Conc_Sigs: for n in 0 to STAGES-1 generate
    test: for j in 0 to NUM_COMP(n+1)-1 generate
      test2: for i in 0 to NUM_HAND-1 generate

        --Per handle (add), the first concurrent signal will just take from the
        --corresponding register
        first_handle: if i=0 generate
          conc_sigs(n)(j)(i) <= reg_sigs(n)(NUM_HAND*j+i);
        end generate;

        --Non-first concurrent signals will also take from the corresponding registers
        --but add the previous signal to it.
        middle_handles: if i/=0 and (NUM_HAND*j+i <= NUM_COMP(n)-1) generate
          conc_sigs(n)(j)(i) <= reg_sigs(n)(NUM_HAND*j+i) + conc_sigs(n)(j)(i-1);
        end generate;

        -- If the signal corresponds to a register that is out of index range
        -- (happens when # inputs isn't divisible by the number of
        -- computation), then this signal will just take from the previous signal.
        last_handle: if i/=0 and (NUM_HAND*j+i > NUM_COMP(n)-1) generate
          conc_sigs(n)(j)(i) <= conc_sigs(n)(j)(i-1);
        end generate;
          
      end generate;
    end generate;
  end generate;

  output <= std_logic_vector(reg_sigs(STAGES)(0)); 

end rtl;
