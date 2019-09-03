library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count00_99 is
	--generic (D : natural := 3; 	U : natural := 0);
	port (
		clk : in std_logic;
		rstA, Load : in std_logic;
		clk_out : out std_logic;
		D, U : in natural range 0 to 9;
		bcd_U : out std_logic_vector(3 downto 0);
		bcd_D : out std_logic_vector(3 downto 0)
	);
end entity;


architecture ifsc_v1 of count00_99 is

	component div_clk is
		generic (fclk2 : natural := 50);       -- frequecia para simulacao
		port (
			clk : in std_logic;
			rst : in std_logic;
			clk_out : out std_logic
		);
	end component;

begin

		U1: component div_clk
		generic map(fclk2 => 50000000)
		port map(
			clk => clk,
			rst => rstA,
			clk_out => clk_out
		);

p1:	 PROCESS(clk, rstA, D, U)
		 VARIABLE tempU: natural RANGE 0 TO 10;
		 VARIABLE tempD: natural range 0 to 10;
    BEGIN
	 
	 if(rstA = '1') then
		tempD := D;
      tempU := U;
		
    elsif (rising_edge(clk)) THEN
	 	 if (Load = '1') then
				tempD := D;
				tempU := U;
		 elsif (tempU = 0 and tempD = 0) then
				tempD := 0;
				tempU := 0;
				
       elsif (tempU = 0) then
				tempU := 9;
				if (tempD > 0) then
					tempD := tempD - 1;
				end if;
			else
					tempU := tempU - 1;
         end if;
    END IF;
    bcd_D <= std_logic_vector(to_unsigned(tempD,4));
    bcd_U <= std_logic_vector(to_unsigned(tempU,4));
    end process;

end architecture;
