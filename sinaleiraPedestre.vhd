----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------
entity sinaleiraPedestre is
	generic (
		TD_vd :  natural := 3; 
		TU_vd :  natural := 5;
		
		TD_vm :  natural := 4; 
		TU_vm :  natural := 0);
		
	port (
		D, U: in integer range 0 to 9;
		clk, rst : in STD_LOGIC;
		botao, sensorCarro : in STD_LOGIC;
		load : out std_logic;
		timerU, timerD : out natural range 0 to 9;
		L_vm, L_vd, Faixa, L_botao : out STD_LOGIC);
	end entity;
----------------------------------------------------------


architecture ifsc_v1 of sinaleiraPedestre is 
	type state is (semPedestre, pedestreEsperando, pedestrePassando, waitSP, carregarTempoEspera, carregarTempoPassagem);
	signal pr_state, nx_state : state;
	attribute enum_encoding : string; --optional attribute
	--attribute enum_encoding of state : type is "sequential";
	attribute enum_encoding of state : type is "onehot";
begin

	PROCESS (clk, rst, pr_state)
	BEGIN
		IF (rst = '1') THEN
			pr_state <= semPedestre;		
		ELSIF (clk'EVENT AND clk = '1') THEN
			pr_state <= nx_state;
		END IF;
		
	END PROCESS;
	
	
	----Upper section of FSM:-----------
	process (pr_state, botao, sensorCarro, D, U)
	begin
	
		L_vm <= '0';
		L_vd <= '0';
		Faixa <= '0';
		timerU <= 0;
		timerD <= 0;
		load <= '0';
		L_botao <= '0';
		
		case pr_state IS
		
			-- Nenhum pedestre pressionou o botao
			when semPedestre =>
				L_vm <= '1';
				load <= '1';
				if (botao = '1') then
					nx_state <= waitSP;
				else
					nx_state <= semPedestre;
				end if;
			
			
			-- Aguarda o pedestre soltar o botao
			when waitSP =>
				L_vm <= '1';
				L_botao <= '1';
				if (botao = '0') then
					nx_state <= carregarTempoEspera;
				else
					nx_state <= waitSP;
				end if;
			
			
			-- Load do tempo de vermelho/atraso 
			when carregarTempoEspera =>
				L_vm <= '1';
				if (sensorCarro = '1') then
					timerU <= TU_vm;
					timerD <= TD_vm;
					
				else 
					timerD <= 0;
					timerU <= 2;
				end if;
				load <= '1';
				nx_state <= pedestreEsperando;
				
			
			-- Pedestre aguarda momento de travessia
			when pedestreEsperando =>
				Faixa <= '1';
				L_vm <= '1';
				
				if (sensorCarro = '1' and D = 0 and U = 0) then
					nx_state <= carregarTempoPassagem;
				elsif(sensorCarro = '0' ) then
					nx_state <= carregarTempoPassagem;
				else 
					nx_state <= pedestreEsperando;
				end if;
			
			
			-- Load do tempo de verde 
			when carregarTempoPassagem =>
					L_vd <= '1';
					timerU <= TU_vd;
					timerD <= TD_vd;
					load <= '1';
					nx_state <= pedestrePassando;
				
			
			-- Sinaleira do pedestre em verde
			when pedestrePassando => 
				L_vd <= '1';
				Faixa <= '1';

				if (D = 0 and U = 0) then
					nx_state <= semPedestre;
				else 
					nx_state <= pedestrePassando;
				end if;
				
		end case;
	end process;
end architecture;
----------------------------------------------------------