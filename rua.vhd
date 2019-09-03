library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rua IS 
	generic (
		--fclk2_in : natural := 25000000; -- frequencia para a placa
		fclk2_in : natural := 25; -- frequecia para simulacao
		tipoDisplay : natural := 1; -- Anodo comum
		--tipoDisplay : natural := 0; -- Catodo comum
		
		TPD_vd : natural := 1;   -- tempo verde pedestre
		TPU_vd : natural := 0; 	 -- tempo verde pedestre
		TPD_vm : natural := 4;	 -- tempo vermelho pedestre
		TPU_vm : natural := 5;   -- tempo vermelho pedestre
		
		TCD_vd : natural := 4;   -- tempo verde carro
		TCU_vd : natural := 0; 	 -- tempo verde carro
		TCD_vm : natural := 1;	 -- tempo vermelho carro
		TCU_vm : natural := 3;   -- tempo vermelho carro
		TCD_am : natural := 0;   -- tempo verde carro
		TCU_am : natural := 2);	 -- tempo amarelo carro
	port
	(
		clk50MHz :  in  std_logic;
		rst_in : in std_logic;
		clk_1seg : out std_logic;
		ssd_DP, ssd_DC :  out  std_logic_vector(0 TO 6);
		ssd_UP, ssd_UC :  out  std_logic_vector(0 TO 6);
		sensor, botao : in STD_LOGIC;
		LC_vm, LC_vd, LC_am, LP_vm, LP_vd, L_Faixa, L_botao : out std_logic
	);
end entity;


architecture ifsc_v1 of rua is

	component div_clk is
		generic (fclk2 : natural := 25);
		port (
			clk : in std_logic;
			rst : in std_logic;
			clk_out : out std_logic
		);
	end component;


	component count00_99 is
		port (
			clk : in std_logic;
			rstA, Load : in std_logic;
			clk_out : out std_logic;
			D, U : in natural range 0 to 9;
			bcd_U : out std_logic_vector(3 downto 0);
			bcd_D : out std_logic_vector(3 downto 0)
		);
	end component;


	component bin2ssd is
	--  generic (ac_ccn : natural := 1); -- Anodo comum
	  generic (ac_ccn : natural := 0); -- Catodo comum
	  port (
		 bin_in : in std_logic_vector(3 downto 0);
		 ssd_out : out std_logic_vector(0 to 6)
	  );
	end component;
	
	
	component sinaleiraPedestre is
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
		L_vm, L_vd, Faixa, L_botao: out STD_LOGIC);
	end component;
	
	component sinaleiraCarro is
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
	end component;
-------------------------------
	
	
	-- Declaraçoes de sinais internos
	signal bcd_U_tmpC, bcd_U_tmpP, bcd_D_tmpP, bcd_D_tmpC : std_logic_vector(3 downto 0);
	signal clk_1seg_tmp : std_logic;
	signal timerD_tmp_pedestre, timerU_tmp_pedestre, timerD_tmp_carro, timerU_tmp_carro : natural range 0 to 9;
	signal rst_in_N: std_logic;
	signal loadP, loadC : std_logic;
	signal dezenaP, unidadeC, dezenaC, unidadeP  : integer range 0 to 9;
	signal botao_tmp, sensorCarro_tmp : STD_LOGIC;
	
begin
		rst_in_N <= rst_in;
		botao_tmp <= not botao;
		sensorCarro_tmp <= not sensor;
		clk_1seg <= clk_1seg_tmp;
		
		-- Converte a saida BCD do contador do pedestre
		dezenaP <= to_integer(unsigned(bcd_D_tmpP));
		unidadeP <= to_integer(unsigned(bcd_U_tmpP));
		
		-- Converte a saida BCD do contador do carro
		dezenaC <= to_integer(unsigned(bcd_D_tmpC));
		unidadeC <= to_integer(unsigned(bcd_U_tmpC));

------ Instancias de componentes------------------------------
	
		-- DIVISOR DE CLOCK
		U1: component div_clk
		generic map(fclk2 => fclk2_in)
		port map(
			clk => clk50MHz,
			rst => rst_in_N,
			clk_out => clk_1seg_tmp
		);


		-- CONTADOR DO PEDESTRE
		U2: component count00_99 -- segundos para pedestres
		port map(
			D => timerD_tmp_pedestre,
			U => timerU_tmp_pedestre,
			clk => clk_1seg_tmp,
			Load => loadP,
			rstA => rst_in_N,
			clk_out => open,
			bcd_U => bcd_U_tmpP,
			bcd_D => bcd_D_tmpP
		);
		
		
		-- DISPLAY UNIDADE PEDESTRE
		U3: component bin2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
			bin_in => bcd_U_tmpP,
			ssd_out => ssd_UP
		);
  
		
		-- DISPLAY DEZENA PEDESTRE
		U4: component bin2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
			bin_in => bcd_D_tmpP,
			ssd_out => ssd_DP
		);
		
		
		-- MAQUINA DE ESTADO DO PEDESTRE
		U5: component sinaleiraPedestre
		generic map(
			TD_vd => TPD_vd,
			TU_vd => TPU_vd,
			TD_vm => TPD_vm,
			TU_vm => TPU_vm)
		
		port map(
			clk => clk_1seg_tmp,
			rst => rst_in_N,
			D => dezenaP,
			U => unidadeP,
			load => loadP,
			botao => botao_tmp,
			sensorCarro => sensorCarro_tmp,
			timerD => timerD_tmp_pedestre,
			timerU => timerU_tmp_pedestre, 
			L_vm => Lp_vm, 
			L_vd => Lp_vd, 
			L_botao => L_botao,
			Faixa => L_faixa
		);
		
		
		-- MAQUINA DE ESTADO DO CARRO
		U6: component sinaleiraCarro
		generic map(
			TD_vd => TCD_vd,
			TU_vd => TCU_vd,
			TD_vm => TCD_vm,
			TU_vm => TCU_vm,
			TD_am => TCD_am ,
			TU_am => TCU_am)
		
		port map(
			clk => clk_1seg_tmp,
			rst => rst_in_N,
			
			D => dezenaC,
			U => unidadeC,
			load => loadC,
			botao => botao_tmp, 
			sensorCarro => sensorCarro_tmp,
			timerD => timerD_tmp_carro,
			timerU => timerU_tmp_carro, 
			L_vm => LC_vm, 
			L_vd => LC_vd,
			L_am => LC_am	
		);
		
		
		-- CONTADOR DO CARRO
		U7: component count00_99 -- segundos para carro
		port map(
			D => timerD_tmp_carro,
			U => timerU_tmp_carro,
			clk => clk_1seg_tmp,
			Load => loadC,
			rstA => rst_in_N,
			clk_out => open,
			bcd_U => bcd_U_tmpC,
			bcd_D => bcd_D_tmpC
		);
		
		
		-- DISPLAY UNIDADE CARRO
		U8: component bin2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
			bin_in => bcd_U_tmpC,
			ssd_out => ssd_UC
		);
  
		
		-- DISPLAY DEZENA CARRO
		U9: component bin2ssd
		generic map(ac_ccn => tipoDisplay)
		port map(
			bin_in => bcd_D_tmpC,
			ssd_out => ssd_DC
		);
end architecture;
