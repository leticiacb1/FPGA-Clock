LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity divisorGenerico_e_Interface is
   port(
		clk             : in std_logic;
		selMux          : in std_logic;
      habilitaLeitura : in std_logic;
      limpaLeitura    : in std_logic;
      leitura         : out std_logic
   );
end entity;

architecture interface of divisorGenerico_e_Interface is
  signal saidaclk_regAcelerado : std_logic;
  signal saidaclk_reg1seg      : std_logic;
  signal sinalSaida            : std_logic;
  signal saidaMux              : std_logic;
begin



---- MUX ----
MUX_BASE_TEMPO :  entity work.muxBinario
port map(entradaA_MUX => saidaclk_reg1seg,
		  entradaB_MUX => saidaclk_regAcelerado,
		  seletor_MUX => selMux,
		  saida_MUX => saidaMux);


---- BASE TEMPO ACELERADO ----		  
baseTempoAcelerado: entity work.divisorGenerico
           generic map (divisor => 250000)   -- divide por 500.000
           port map (clk => clk, saida_clk => saidaclk_regAcelerado);

---- BASE TEMPO COMUM ----	
baseTempo: entity work.divisorGenerico
           generic map (divisor => 25000000)   -- divide por 50.000.000
           port map (clk => clk, saida_clk => saidaclk_reg1seg);

---- REGISTRADOR
registraUmSegundo: entity work.flipflop
   port map (DIN => '1', DOUT => sinalSaida,
         ENABLE => '1', CLK => saidaMux,
         RST => limpaLeitura);
			  
-- Faz o tristate de saida:
leitura <= sinalSaida when habilitaLeitura = '1' else 'Z';

end architecture interface;