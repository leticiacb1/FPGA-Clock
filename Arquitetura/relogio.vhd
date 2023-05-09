library ieee;
use ieee.std_logic_1164.all;

entity relogio is
	-- Total de bits das entradas e saidas
	generic ( 
		larguraDados     : natural := 8; 
		larguraEnderecos : natural := 9; 
		tamanhoInstrucao : natural := 16;
		simulacao        : boolean := FALSE -- para gravar na placa, altere de TRUE para FALSE
	);
	port(
		CLOCK_50 : in  std_logic;
		KEY      : in  std_logic_vector(3 downto 0);
		FPGA_RESET_N : in std_logic;
		SW       : in  std_logic_vector(9 downto 0);
		LEDR     : out std_logic_vector(9 downto 0);
		HEX0     : out std_logic_vector(6 downto 0);
		HEX1     : out std_logic_vector(6 downto 0);
		HEX2     : out std_logic_vector(6 downto 0);
		HEX3     : out std_logic_vector(6 downto 0);	
		HEX4     : out std_logic_vector(6 downto 0);
		HEX5     : out std_logic_vector(6 downto 0)
	);
end entity;


architecture arquitetura of relogio is
	signal CLK               :   std_logic;
	signal Wr                :   std_logic;
	signal Rd                :   std_logic;
	signal Reset             :   std_logic;
	signal ROM_Address       :   std_logic_vector(larguraEnderecos-1 downto 0);
	signal Instruction       :   std_logic_vector(tamanhoInstrucao-1 downto 0);
	signal Data_IN           :   std_logic_vector(larguraDados-1 downto 0);
	signal Data_OUT          :   std_logic_vector(larguraDados-1 downto 0);
	signal Data_Address      :   std_logic_vector(larguraEnderecos-1 downto 0);
	
	signal Saida_Decoder3x8Bloco     :   std_logic_vector(7 downto 0);
	signal Saida_Decoder3x8Endereco  :   std_logic_vector(7 downto 0);
	
	signal saida_edgeDetector_key0   : std_logic;
	signal saida_edgeDetector_key1   : std_logic;
	signal saida_flipflop_key0       : std_logic;
	signal saida_flipflop_key1       : std_logic;
	signal limpaLeitura_key0         : std_logic;
	signal limpaLeitura_key1         : std_logic;
	
	signal limpaLeitura_BaseTempo    : std_logic;
	signal limpaLeitura_BaseTempo_acelerada : std_logic;
	
	signal selMuxBaseTempo           : std_logic; 

  
begin

----------------- BASE DE TEMPO -------------------
CLK <= CLOCK_50;

-- Limpa base de tempo: Endereco 509
-- Endereço para letura dessa base de tempo: Endereco 357
limpaLeitura_BaseTempo <= (Wr and Data_Address(8) and Data_Address(7) and Data_Address(6) and Data_Address(5) and Data_Address(4) and Data_Address(3) and Data_Address(2) and not(Data_Address(1)) and Data_Address(0));

-- Seleciona qual base de tempo deve ser utilizada.
SW9 :  entity work.buffer_3_state_1portas
port map(
	entrada => SW(9),
	habilita => (Saida_Decoder3x8Endereco(2) and not(Data_Address(5)) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => selMuxBaseTempo
);

interfaceBaseTempo : entity work.divisorGenerico_e_Interface
port map (
	clk => CLK,
	selMux => selMuxBaseTempo,
	habilitaLeitura => (Saida_Decoder3x8Endereco(5) and Data_Address(5) and Saida_Decoder3x8Bloco(5) and Rd), 
	limpaLeitura => limpaLeitura_BaseTempo,
	leitura      => Data_IN(0)
);

---------------------- LEDS ----------------------
-- LED de 8 bits
LEDR07 : entity work.registradorGenerico  generic map (larguraDados => 8)
	port map(
		DIN => Data_OUT,
		DOUT => LEDR(7 downto 0),
		ENABLE => (Wr and Saida_Decoder3x8Endereco(0) and Saida_Decoder3x8Bloco(4) and not(Data_Address(5))),
		CLK => CLK,
		RST => '0'
	);
	
-- LED correspondente ao bit 1 do decodificador 3x8 de endereço
LED8 : entity work.flipflop
	port map(
		DIN => Data_OUT(0),
		DOUT => LEDR(8),
		ENABLE => (Wr and Saida_Decoder3x8Endereco(1) and Saida_Decoder3x8Bloco(4) and not(Data_Address(5))),
		CLK => CLK,
		RST => '0'
	);
	
-- LED correspondente ao bit 2 do decodificador 3x8 de endereço
LED9 : entity work.flipflop
	port map(
		DIN => Data_OUT(0),
		DOUT => LEDR(9),
		ENABLE => (Wr and Saida_Decoder3x8Endereco(2) and Saida_Decoder3x8Bloco(4) and not(Data_Address(5))),
		CLK => CLK,
		RST => '0'
	);
--------------------------------------------------

	
---------------------- HEX ----------------------
HEX_0 : entity work.HEX
	port map(
		CLK      => CLK,
      habilita => (Saida_Decoder3x8Endereco(0) and Data_Address(5) and Saida_Decoder3x8Bloco(4) and Wr),
      entrada  => Data_OUT(3 downto 0),
      saida    => HEX0
	);
	
HEX_1 : entity work.HEX
	port map(
		CLK      => CLK,
      habilita => (Saida_Decoder3x8Endereco(1) and Data_Address(5) and Saida_Decoder3x8Bloco(4) and Wr),
      entrada  => Data_OUT(3 downto 0),
      saida    => HEX1
	);
	
HEX_2 : entity work.HEX
	port map(
		CLK      => CLK,
      habilita => (Saida_Decoder3x8Endereco(2) and Data_Address(5) and Saida_Decoder3x8Bloco(4) and Wr),
      entrada  => Data_OUT(3 downto 0), 
      saida    => HEX2
	);
	
HEX_3 : entity work.HEX
	port map(
		CLK      => CLK,
      habilita => (Saida_Decoder3x8Endereco(3) and Data_Address(5) and Saida_Decoder3x8Bloco(4) and Wr),
      entrada  => Data_OUT(3 downto 0), 
      saida    => HEX3
	);
	
HEX_4 : entity work.HEX
	port map(
		CLK      => CLK,
      habilita => (Saida_Decoder3x8Endereco(4) and Data_Address(5) and Saida_Decoder3x8Bloco(4) and Wr),
      entrada  => Data_OUT(3 downto 0), 
      saida    => HEX4
	);
	
HEX_5 : entity work.HEX
	port map(
		CLK      => CLK,
      habilita => (Saida_Decoder3x8Endereco(5) and Data_Address(5) and Saida_Decoder3x8Bloco(4) and Wr),
      entrada  => Data_OUT(3 downto 0), 
      saida    => HEX5
	);
	
-------------------------------------------------

---------------------- SW -----------------------
SW07 :  entity work.buffer_3_state_8portas
	port map(
		entrada => SW(7 downto 0),
		habilita => (Saida_Decoder3x8Endereco(0) and not(Data_Address(5)) and Saida_Decoder3x8Bloco(5) and Rd),
		saida => Data_IN
	);

SW8 :  entity work.buffer_3_state_1portas
port map(
	entrada => SW(8),
	habilita => (Saida_Decoder3x8Endereco(1) and not(Data_Address(5)) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => Data_IN(0)
);

--SW9 :  entity work.buffer_3_state_1portas
--port map(
--	entrada => SW(9),
--	habilita => (Saida_Decoder3x8Endereco(2) and not(Data_Address(5)) and Saida_Decoder3x8Bloco(5) and Rd),
--	saida => Data_IN(0)
--);
-------------------------------------------------


---------------------- KEY ----------------------

-- KEY0 --
edgeDetector0 : entity work.edgeDetector(bordaSubida)
port map(
	clk => CLK,
   entrada => not KEY(0),
   saida => saida_edgeDetector_key0
);

-- Endereço 511
limpaLeitura_key0 <= Wr and Data_Address(8) and Data_Address(7) and Data_Address(6) and Data_Address(5) and Data_Address(4) and Data_Address(3) and Data_Address(2) and Data_Address(1) and Data_Address(0);

flipflopkey0 : entity work.flipflop
port map(
	DIN     => '1',
	DOUT    => saida_flipflop_key0,
	ENABLE  => '1',
	CLK     => saida_edgeDetector_key0,
	RST     => limpaLeitura_key0
);

KEY0 :  entity work.buffer_3_state_1portas
port map(
	entrada => saida_flipflop_key0,
	habilita => (Saida_Decoder3x8Endereco(0) and Data_Address(5) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => Data_IN(0)
);
------ 

-- KEY1 --
edgeDetector1 : entity work.edgeDetector(bordaSubida)
port map(
	clk => CLK,
   entrada => not KEY(1),
   saida => saida_edgeDetector_key1
);

-- Endereço 510
limpaLeitura_key1 <= Wr and Data_Address(8) and Data_Address(7) and Data_Address(6) and Data_Address(5) and Data_Address(4) and Data_Address(3) and Data_Address(2) and Data_Address(1) and not(Data_Address(0));

flipflopkey1 : entity work.flipflop
port map(
	DIN     => '1',
	DOUT    => saida_flipflop_key1,
	ENABLE  => '1',
	CLK     => saida_edgeDetector_key1,
	RST     => limpaLeitura_key1
);

KEY1 :  entity work.buffer_3_state_1portas
port map(
	entrada => saida_flipflop_key1,
	habilita => (Saida_Decoder3x8Endereco(1) and Data_Address(5) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => Data_IN(0)
);
------


KEY2 :  entity work.buffer_3_state_1portas
port map(
	entrada => KEY(2),
	habilita => (Saida_Decoder3x8Endereco(2) and Data_Address(5) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => Data_IN(0)
);

KEY3 :  entity work.buffer_3_state_1portas
port map(
	entrada => KEY(3),
	habilita => (Saida_Decoder3x8Endereco(3) and Data_Address(5) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => Data_IN(0)
);

FPGA_RESET :  entity work.buffer_3_state_1portas
port map(
	entrada => FPGA_RESET_N,
	habilita => (Saida_Decoder3x8Endereco(4) and Data_Address(5) and Saida_Decoder3x8Bloco(5) and Rd),
	saida => Data_IN(0)
);
-------------------------------------------------


-- DECODER BLOCO --
DECODER3X8Bloco : entity work.decoder3x8
	port map(
	entrada => Data_Address(8 downto 6),
	saida => Saida_Decoder3x8Bloco
	);
	
	
-- DECODER ENDEREÇO --
DECODER3X8Endereco : entity work.decoder3x8
	port map(
	entrada => Data_Address(2 downto 0),
	saida => Saida_Decoder3x8Endereco
	);

	
-- ROM --
ROM1 : entity work.memoriaROM   generic map (dataWidth => tamanhoInstrucao, addrWidth => larguraEnderecos)
	port map(
	Endereco => ROM_Address,
	Dado => Instruction
	);

	
-- RAM --			 
RAM : entity work.memoriaRAM   generic map (dataWidth => larguraDados, addrWidth => 6)
	port map (
	addr => Data_Address(5 downto 0),
	we => Wr,
	re => Rd,
	habilita  => Saida_Decoder3x8Bloco(0),
	dado_in => Data_OUT,
	dado_out => Data_IN,
	clk => CLK
	);
	
-- CPU --
CPU : entity work.CPU 
	port map(
	CLK          => CLK,
	Wr           => Wr,
	Rd           => Rd,
	Reset        => '0',
	ROM_Address  => ROM_Address,
	Instruction  => Instruction,
	Data_IN      => Data_IN,
	Data_OUT     => Data_OUT,
	Data_Address => Data_Address
	);
		

end architecture;