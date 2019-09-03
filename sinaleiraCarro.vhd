----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------------------------------------------

entity sinaleiraCarro is
	generic (
		TD_vd :  natural := 3; 
		TU_vd :  natural := 5;
		
		TD_am :  natural := 0; 
		TU_am :  natural := 2;
		
		TD_vm :  natural := 4; 
		TU_vm :  natural := 0);
		
	port (
		D, U : in integer range 0 to 9;
		clk, rst : in STD_LOGIC;
		botao, sensorCarro : in STD_LOGIC;
		load : out std_logic;
		timerU, timerD : out natural range 0 to 9;
		L_vm, L_am, L_vd : out STD_LOGIC);
	end entity;
----------------------------------------------------------


architecture ifsc_v1 of sinaleiraCarro is 

	type state is (amarelo, verde, vermelho, apagado, waitSP, carregarTempoVerde, 
	carregarTempoAmarelo, carregarTempoVermelho);
	
	signal pr_state, nx_state : state;
	attribute enum_encoding : string; --optional attribute
	--attribute enum_encoding of state : type is "sequential";
	attribute enum_encoding of state : type is "onehot";
begin

	PROCESS (clk, rst, pr_state)
	BEGIN
		IF (rst = '1') THEN
			pr_state <= apagado;		
		ELSIF (clk'EVENT AND clk = '1') THEN
			pr_state <= nx_state;
		END IF;
		
	END PROCESS;
	
	
	----Upper section of FSM:-----------
	process (pr_state, botao, sensorCarro, D, U)
	begin
	
		L_vm <= '0';
		L_am <= '0';
		L_vd <= '0';
		timerU <= 0;
		timerD <= 0;
		load <= '0';
		
		case pr_state IS
		
			-- Sinaleira carro esta apagada
			when apagado =>
				load <= '1';
				if (botao = '1') then
					nx_state <= waitSP;
				else
					nx_state <= apagado;
				end if;
			
			-- Aguarda botao de pedestre ser solto
			when waitSP =>
				if (botao = '0') then
					nx_state <= carregarTempoVerde;
				else
					nx_state <= waitSP;
				end if;
			
			
			-- Load do tempo de verde/amarelo do carro
			when carregarTempoVerde =>
				
				if (sensorCarro = '1') then
					timerU <= TU_vd;
					timerD <= TD_vd;
					nx_state <= verde;
					
				else 
					timerD <= 0;
					timerU <= 2;
					nx_state <= amarelo;
				end if;
				load <= '1';
				
			
			-- Aguarda tempo de verde terminar ou sai quando nao ha carros
			when verde =>
				L_vd <= '1';
				if (sensorCarro = '1' and D = 0 and U = 0) then
					nx_state <= carregarTempoAmarelo;
				elsif(sensorCarro = '0') then
					nx_state <= carregarTempoAmarelo;
				else 
					nx_state <= verde;
				end if;
				
				
			-- Load do tempo de amarelo do carro
			when carregarTempoAmarelo =>
				L_am <= '1';
				timerU <= TU_am;
				timerD <= TD_am;
				load <= '1';
				nx_state <= amarelo;
			
			
			-- Aguarda tempo de amarelo terminar
			when amarelo =>
				L_am <= '1';
				if (sensorCarro = '1' and D = 0 and U = 0) then
					nx_state <= carregarTempoVermelho;
				elsif(sensorCarro = '0' and D = 0 and U = 0) then
					nx_state <= carregarTempoVermelho;
				else 
					nx_state <= amarelo;
				end if;
			
			
			-- Load do tempo de vermelho do carro
			when carregarTempoVermelho =>
					L_vm <= '1';
					timerU <= TU_vm;
					timerD <= TD_vm;
					load <= '1';
					nx_state <= vermelho;
				
				
			-- Aguarda tempo de vermelho terminar
			when vermelho => 
				L_vm <= '1';
				if (D = 0 and U = 0) then
					nx_state <= apagado;
				else 
					nx_state <= vermelho;
				end if;
				
		end case;
	end process;
end architecture;
----------------------------------------------------------