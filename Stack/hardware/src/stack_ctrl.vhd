library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity stack_ctrl is
   generic(ADDR_WIDTH : natural := 4);
   port(
      clk, reset  : in  std_logic;
      rd, wr      : in  std_logic;
      empty, full : out std_logic;
      w_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      r_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      w_count     : out std_logic_vector(ADDR_WIDTH downto 0);
      almost_full: out std_logic;
      almost_empty: out std_logic
   );
end stack_ctrl;

architecture arch of stack_ctrl is
   signal sp_reg : std_logic_vector(ADDR_WIDTH-1 downto 0);
   signal sp_next : std_logic_vector(ADDR_WIDTH-1 downto 0);
   signal sp_succ : std_logic_vector(ADDR_WIDTH-1 downto 0);
   signal sp_prev : std_logic_vector(ADDR_WIDTH-1 downto 0);
   
   signal full_reg   : std_logic;
   signal full_next  : std_logic;
   signal empty_reg  : std_logic;
   signal empty_next : std_logic;
   signal wr_op      : std_logic_vector(1 downto 0);
   
   constant STACK_DEPTH : integer := 2**ADDR_WIDTH;
   constant ALMOST_EMPTY_SIZE: integer := (1 * STACK_DEPTH)/4;
   constant ALMOST_FULL_SIZE: integer := (3 * STACK_DEPTH)/4;
    
   signal almost_empty_reg  : std_logic;
   signal almost_full_reg   : std_logic;
   
   subtype count_range is integer range 0 to STACK_DEPTH; 
   signal word_count : count_range;
   signal fill_status: std_logic_vector(3 downto 0);

begin
   -- register for read and write pointers
   process(clk, reset)
   begin
      if (reset = '1') then
         sp_reg <= (others => '0');
         
         full_reg  <= '0';
         empty_reg <= '1';
         almost_full_reg <= '0';
         almost_empty_reg <= '0';
         word_count <= 0;
         
      elsif (clk'event and clk = '1') then
         sp_reg <= sp_next;
        
         full_reg  <= full_next;
         empty_reg <= empty_next;
        
         if empty_next = '1' then
            word_count <= 0;
         elsif full_next = '1' then
            word_count <= STACK_DEPTH;
         else    
            word_count <= to_integer(unsigned(sp_next));
         end if;
      
     
      end if;
   end process;

   -- successive pointer values
   sp_succ <= std_logic_vector(unsigned(sp_reg) + 1);
   sp_prev <= std_logic_vector(unsigned(sp_reg) - 1);
   
  w_count <= std_logic_vector (to_unsigned(word_count, ADDR_WIDTH+1)); 
   -- next-state logic for read and write pointers
   wr_op <= wr & rd;
   process(wr_op, sp_reg, sp_next, sp_succ,sp_prev, empty_reg, full_reg)
   begin
      sp_next <= sp_reg;
      full_next  <= full_reg;
      empty_next <= empty_reg;
      case wr_op is
         when "00" =>                   -- no op
         when "01" =>                   -- read
            if (empty_reg /= '1') then  -- not empty
               sp_next <= sp_prev;
               full_next  <= '0';
               if (unsigned(sp_prev) = to_unsigned(0, ADDR_WIDTH)) then
                  empty_next <= '1';
               else
               end if;
            end if;
         when "10" =>                   -- write
            if (full_reg /= '1') then   -- not full
               sp_next <= sp_succ;
               empty_next <= '0';
               if (unsigned(sp_succ) = to_unsigned(STACK_DEPTH, ADDR_WIDTH)) then
                  full_next <= '1';
                else
                end if;
            end if;
         when others =>                 -- write/read;
            sp_next <= sp_next;
         end case;
   end process;

    -- Bit order: full, almost full, almost empty, empty
    fill_status <= "1000" when full_reg = '1' else
                   "0100" when word_count >= ALMOST_FULL_SIZE and word_count < STACK_DEPTH else
                   "0010" when word_count >= ALMOST_EMPTY_SIZE and word_count < ALMOST_FULL_SIZE else
                   "0000"; --when empty_reg = '1'
                   
                   
                   
   -- output
   w_addr <= sp_reg;
   r_addr <= sp_reg;
   
   empty  <= fill_status(0);
   almost_empty <= fill_status(1);
   almost_full <= fill_status(2);
   full   <= fill_status(3);

end arch;
