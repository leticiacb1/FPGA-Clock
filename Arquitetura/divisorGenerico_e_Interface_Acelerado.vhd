LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity divisorGenerico_e_Interface_Acelerado is
   port(clk      :   in std_logic;
      habilitaLeitura : in std_logic;
      limpaLeitura : in std_logic;
      leituraAcelerada :   out std_logic
   );
end entity;

architecture interface of divisorGenerico_e_Interface_Acelerado is
  signal sinalAcelerado : std_logic;
  signal saidaclk_regAcelerado : std_logic;
begin

baseTempoAcelerado: entity work.divisorGenerico
           generic map (divisor => 250000)   -- divide por 500.000
           port map (clk => clk, saida_clk => saidaclk_regAcelerado);

registradorAcelerado: entity work.flipflop
   port map (DIN => '1', DOUT => sinalAcelerado,
         ENABLE => '1', CLK => saidaclk_regAcelerado,
         RST => limpaLeitura);

-- Faz o tristate de saida:
leituraAcelerada <= sinalAcelerado when habilitaLeitura = '1' else 'Z';

end architecture interface;