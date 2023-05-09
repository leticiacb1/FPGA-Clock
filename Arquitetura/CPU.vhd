library ieee;
use ieee.std_logic_1164.all;

entity CPU is
	-- Total de bits das entradas e saidas
	generic ( 
		larguraDados : natural := 8; 
		larguraEnderecos : natural := 9; 
		tamanhoInstrucao : natural := 16;
		simulacao : boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
	);
	port(
		CLK          : in   std_logic;
		Wr           : out  std_logic;
		Rd           : out  std_logic;
		Reset        : in   std_logic;
		ROM_Address  : out  std_logic_vector(larguraEnderecos-1 downto 0);
		Instruction  : in   std_logic_vector(tamanhoInstrucao-1 downto 0);
		Data_IN      : in   std_logic_vector(larguraDados-1 downto 0);
		Data_OUT     : out  std_logic_vector(larguraDados-1 downto 0);
		Data_Address : out  std_logic_vector(larguraEnderecos-1 downto 0)
	);
end entity;


architecture arquitetura of CPU is
 
  signal Endereco : std_logic_vector (larguraEnderecos-1 downto 0);
  signal proxPC : std_logic_vector (larguraEnderecos-1 downto 0);
  signal saidaIncrementa : std_logic_vector (larguraEnderecos-1 downto 0);
  signal Sinais_Controle : std_logic_vector (11 downto 0);
  signal SelLogDesvio: std_logic_vector(1 downto 0);
  signal flag: std_logic;
  signal EndRetorno: std_logic_vector (larguraEnderecos-1 downto 0);
  
  -- SINAL SAÍDA DA ROM E SUAS REPARTIÇÕES ------------
  signal instrucao : std_logic_vector (tamanhoInstrucao-1 downto 0);
  -----------------------------------------------------
  
  -- SINAIS DE CONTROLE -------------------------------
  signal habEscritaRetorno : std_logic;
  signal JMP: std_logic;
  signal RET: std_logic;
  signal JSR: std_logic;
  signal JEQ: std_logic;
  signal SelMUX : std_logic;
  signal Habilita_A : std_logic;
  signal Operacao_ULA : std_logic_vector (1 downto 0);
  signal HabFlagIgual: std_logic;
  signal HabLeituraRAM: std_logic;
  signal HabEscritaRAM: std_logic;  
  -----------------------------------------------------
 
  -- SINAIS ULA, MUX, REGA ----------------------------
  signal MUX_EntradaB_ULA : std_logic_vector (larguraDados-1 downto 0);
  signal REG_EntradaA_ULA : std_logic_vector (larguraDados-1 downto 0);
  signal Saida_ULA : std_logic_vector (larguraDados-1 downto 0); 
  -----------------------------------------------------
  
  -- SINAIS RAM ---------------------------------------
  signal saida_dados_RAM: std_logic_vector (larguraDados-1 downto 0);
  signal entrada_dados_RAM: std_logic_vector (larguraDados-1 downto 0);
  -----------------------------------------------------
  
begin

-- MUX --
MUX1 :  entity work.muxGenerico2x1  generic map (larguraDados => larguraDados)
port map(entradaA_MUX => saida_dados_RAM,
		  entradaB_MUX =>  instrucao(7 downto 0),
		  seletor_MUX => SelMUX,
		  saida_MUX => MUX_EntradaB_ULA);
		  
			  
-- MUX JUMP --
MUXJMP :  entity work.muxGenerico4x1  generic map (larguraDados => larguraEnderecos)
port map(entradaA_MUX => saidaIncrementa,
		 entradaB_MUX =>  instrucao(8 downto 0),
		 entradaC_MUX =>  EndRetorno,
		 entradaD_MUX =>  "000000000",
		 seletor_MUX => SelLogDesvio,
		 saida_MUX => proxPC);
		 
		
-- Lógica de Desvio --		 
LOGDESVIO : entity work.LogicaDesvio
port map (flag => flag,
			 JEQ => JEQ,
			 JMP => JMP,
			 JSR => JSR,
			 RET => RET,
			 saida => SelLogDesvio);
			 
						 
-- Registrador A --
--REGA : entity work.registradorGenerico   generic map (larguraDados => larguraDados)
--	port map (
--		DIN => Saida_ULA,
--		DOUT => REG_EntradaA_ULA,
--		ENABLE => Habilita_A,
--		CLK => CLK,
--		RST => '0');
		
-- Banco de Registradores --
REGS : entity work.bancoRegistradoresArqRegMem  
generic map (larguraDados => larguraDados, larguraEndBancoRegs => 3)
port map ( 
	clk => CLK,
	endereco => instrucao(11 downto 9),
	dadoEscrita => Saida_ULA,
	habilitaEscrita => Habilita_A,
	saida  => REG_EntradaA_ULA);


-- Registrador de Retorno
REGRET : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecos)
	port map (
		DIN => saidaIncrementa,
		DOUT => EndRetorno,
		ENABLE => habEscritaRetorno,
		CLK => CLK,
		RST => '0');
			 
			 
-- Registrador Flag --
REGFLAG : entity work.registradorFlag
	port map (
		DIN => Saida_ULA,
	   DOUT => flag,
		ENABLE => HabFlagIgual,
		CLK => CLK,
		RST => '0');
			 
			 
-- Program Counter --
PC : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecos)
	port map (
		DIN => proxPC,
		DOUT => Endereco,
		ENABLE => '1',
		CLK => CLK,
		RST => '0');
		

-- Incrementa Program Counter --
incrementaPC :  entity work.somaConstante  generic map (larguraDados => larguraEnderecos, constante => 1)
	port map(
		entrada => Endereco,
		saida => saidaIncrementa);


-- ULA --
ULA1 : entity work.ULASomaSubPassa  generic map(larguraDados => larguraDados)
	port map (
		entradaA => REG_EntradaA_ULA,
		entradaB => MUX_EntradaB_ULA,
		saida => Saida_ULA,
		seletor => Operacao_ULA);
		

-- DECODER --
DECODER : entity work.decoderInstru
	port map (
		opcode => instrucao(15 downto 12),
		saida => Sinais_Controle);
			 


habEscritaRetorno <= Sinais_Controle(11);
JMP <= Sinais_Controle(10);
RET <= Sinais_Controle(9);			 
JSR <= Sinais_Controle(8);
JEQ <= Sinais_Controle(7);
selMUX <= Sinais_Controle(6);
Habilita_A <= Sinais_Controle(5);
Operacao_ULA <= Sinais_Controle(4 downto 3);
HabFlagIgual <= Sinais_Controle(2);
HabLeituraRAM <= Sinais_Controle(1);
HabEscritaRAM <= Sinais_Controle(0);


Wr              <= HabEscritaRAM;
Rd              <= HabLeituraRAM;
ROM_Address     <= Endereco;
instrucao       <= Instruction;
saida_dados_RAM <= Data_IN;
Data_OUT        <= REG_EntradaA_ULA;
Data_Address    <= instrucao(8 downto 0);


end architecture;