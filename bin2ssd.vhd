library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2ssd is
--  generic (ac_ccn : natural := 1); -- Anodo comum
  generic (ac_ccn : natural := 0); -- Catodo comum
  port (
    bin_in : in std_logic_vector(3 downto 0);
    ssd_out : out std_logic_vector(0 to 6)
  );
end entity;

architecture ifsc_v1 of bin2ssd is
	signal SSD_Dseg : std_logic_vector(0 to 6);
	
begin
	  process (bin_in)
        variable count : integer range 0  to 10;
     begin
     count := to_integer(unsigned(bin_in));
     case count  is
        when 0 => SSD_Dseg <="0000001";  -- '0'
        when 1 => SSD_Dseg <="1001111";  -- '1'
        when 2 => SSD_Dseg <="0010010";  -- '2'
        when 3 => SSD_Dseg <="0000110";  -- '3'
        when 4 => SSD_Dseg <="1001100";  -- '4'
        when 5 => SSD_Dseg <="0100100";  -- '5'
        when 6 => SSD_Dseg <="0100000";  -- '6'
        when 7 => SSD_Dseg <="0001111";  -- '7'
        when 8 => SSD_Dseg <="0000000";  -- '8'
        when 9 => SSD_Dseg <="0000100";  -- '9'
        --nothing is displayed when a number more than 9 is given as input.
        when others=> SSD_Dseg <="1111111";
     end case;
    end process;
	 
	 ssd_out <= SSD_Dseg when ac_ccn = 1 else (not SSD_Dseg);

end architecture;
