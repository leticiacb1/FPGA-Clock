library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULASomaSubPassa is
    generic ( larguraDados : natural := 8 ); -- Mudamos a largura de dados de 4 para 8, agora nosso processador consegue realizar operações com 8 bits
    port (
      entradaA, entradaB:  in STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      seletor:  in STD_LOGIC_VECTOR(1 downto 0); -- Agora o seletor possui 2 bits para representar as 3 operações possíveis (soma, sub, passa)
      saida:    out STD_LOGIC_VECTOR((larguraDados-1) downto 0)
    );
end entity;

architecture comportamento of ULASomaSubPassa is
   signal soma      : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
   signal subtracao : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal passa     : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal op_and    : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
    begin
      soma      <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
      subtracao <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));
		passa     <= entradaB;
		op_and    <= STD_LOGIC_VECTOR(entradaA and entradaB);
		
      saida <= passa  when (seletor = "11") else
					op_and when (seletor = "10") else
					soma   when (seletor = "01") else
					subtracao;
end architecture;