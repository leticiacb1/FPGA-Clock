LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity divisorGenerico_e_Interface_Segundo is
   port(clk      :   in std_logic;
      habilitaLeitura : in std_logic;
      limpaLeitura : in std_logic;
      leituraUmSegundo :   out std_logic
   );
end entity;

architecture interface of divisorGenerico_e_Interface_Segundo is
  signal sinalUmSegundo : std_logic;
  signal saidaclk_reg1seg : std_logic;
begin

baseTempo: entity work.divisorGenerico
           generic map (divisor => 25000000)   -- divide por 50.000.000
           port map (clk => clk, saida_clk => saidaclk_reg1seg);

registraUmSegundo: entity work.flipflop
   port map (DIN => '1', DOUT => sinalUmSegundo,
         ENABLE => '1', CLK => saidaclk_reg1seg,
         RST => limpaLeitura);

-- Faz o tristate de saida:
leituraUmSegundo <= sinalUmSegundo when habilitaLeitura = '1' else 'Z';

end architecture interface;