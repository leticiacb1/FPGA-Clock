library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HEX is
    port (
		CLK      :  in  std_logic;
      habilita :  in  std_logic;
      entrada  :  in  std_logic_vector(3 downto 0); 
      saida    :  out std_logic_vector(6 downto 0)
    );
end entity;

architecture comportamento of HEX is
   signal REG_DECOD : STD_LOGIC_VECTOR(3 downto 0);
	
	begin
	
	
REG : entity work.registradorGenerico   generic map (larguraDados => 4)
	port map (
	DIN => entrada,
	DOUT => REG_DECOD,
	ENABLE => habilita,
	CLK => CLK,
	RST => '0');

		
Hex7Seg : entity work.conversorHex7Seg
	port map(
	dadoHex => REG_DECOD,
	apaga =>  '0',
	negativo => '0',
	overFlow =>  '0',
	saida7seg => saida);
	
end architecture;