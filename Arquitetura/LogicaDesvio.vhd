library ieee;
use ieee.std_logic_1164.all;

entity LogicaDesvio is
  port ( flag  : in std_logic;
			JEQ   : in std_logic;
			JMP   : in std_logic;
			JSR   : in std_logic;
			RET   : in std_logic;
         saida : out std_logic_vector(1 downto 0)
  );
end entity;

architecture comportamento of LogicaDesvio is
  begin
	saida(0) <= (JMP or JSR or (flag and JEQ));
	saida(1) <= RET;
	
end architecture;