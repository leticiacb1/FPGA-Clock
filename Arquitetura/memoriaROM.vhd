library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 4;
          addrWidth: natural := 3
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is

  constant NOP  : std_logic_vector(3 downto 0) := "0000";
  constant LDA  : std_logic_vector(3 downto 0) := "0001";
  constant SOMA : std_logic_vector(3 downto 0) := "0010";
  constant SUB  : std_logic_vector(3 downto 0) := "0011";
  constant LDI  : std_logic_vector(3 downto 0) := "0100";
  constant STA  : std_logic_vector(3 downto 0) := "0101";
  constant JMP  : std_logic_vector(3 downto 0) := "0110";
  constant JEQ  : std_logic_vector(3 downto 0) := "0111";
  constant CEQ  : std_logic_vector(3 downto 0) := "1000";
  constant JSR  : std_logic_vector(3 downto 0) := "1001";
  constant RET  : std_logic_vector(3 downto 0) := "1010";
  constant OP_AND : std_logic_vector(3 downto 0) := "1011";
  
  constant R0 : std_logic_vector(2 downto 0) := "000";
  constant R1 : std_logic_vector(2 downto 0) := "001";
  constant R2 : std_logic_vector(2 downto 0) := "010";
  constant R3 : std_logic_vector(2 downto 0) := "011";
  constant R4 : std_logic_vector(2 downto 0) := "100";
  constant R5 : std_logic_vector(2 downto 0) := "101";
  constant R6 : std_logic_vector(2 downto 0) := "110";
  constant R7 : std_logic_vector(2 downto 0) := "111";
  
  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
	
-- INICIO
-- -----------------------------------------------------
-- CONFIGURAÇÕES
-- -----------------------------------------------------

-- ----- Limpa Displays
tmp(0) := LDI & R0 & '0' & x"00";	-- #LDI R0   $0	-- Reg[0] = 0
tmp(1) := STA & R0 & '1' & x"20";	-- #STA @288 R0	-- HEX0   = 0
tmp(2) := STA & R0 & '1' & x"21";	-- #STA @289 R0	-- HEX1   = 0
tmp(3) := STA & R0 & '1' & x"22";	-- #STA @290 R0	-- HEX2   = 0
tmp(4) := STA & R0 & '1' & x"23";	-- #STA @291 R0	-- HEX3   = 0
tmp(5) := STA & R0 & '1' & x"24";	-- #STA @292 R0	-- HEX4   = 0
tmp(6) := STA & R0 & '1' & x"25";	-- #STA @293 R0	-- HEX5   = 0

-- ----- Apaga Leds
tmp(7) := LDI & R0 & '0' & x"00";	-- #LDI R0   $0	-- Reg[0]  = 0
tmp(8) := STA & R0 & '1' & x"00";	-- #STA @256 R0	-- LEDR0-7 = 0
tmp(9) := STA & R0 & '1' & x"01";	-- #STA @257 R0	-- LEDR8   = 0
tmp(10) := STA & R0 & '1' & x"02";	-- #STA @258 R0	-- LEDR9   = 0

-- ----- Limpa FlipFlops Base de tempo
tmp(11) := STA & R0 & '1' & x"FC";	-- #STA @508 R0
tmp(12) := STA & R0 & '1' & x"FD";	-- #STA @509 R0

-- ----- Salva Constantes
-- Endereços de 0 a 9
tmp(13) := LDI & R0 & '0' & x"00";	-- #LDI R0 $0
tmp(14) := STA & R0 & '0' & x"00";	-- #STA @0 R0	-- MEM[0] = 0 (Constante)

tmp(15) := LDI & R0 & '0' & x"01";	-- #LDI R0 $1
tmp(16) := STA & R0 & '0' & x"01";	-- #STA @1 R0	-- MEM[1] = 1 (Constante)

tmp(17) := LDI & R0 & '0' & x"02";	-- #LDI R0 $2
tmp(18) := STA & R0 & '0' & x"02";	-- #STA @2 R0	-- MEM[2] = 2 (Constante)

tmp(19) := LDI & R0 & '0' & x"04";	-- #LDI R0 $4
tmp(20) := STA & R0 & '0' & x"04";	-- #STA @4 R0	-- MEM[4] = 4 (Constante)

tmp(21) := LDI & R0 & '0' & x"05";	-- #LDI R0 $5
tmp(22) := STA & R0 & '0' & x"05";	-- #STA @5 R0	-- MEM[5] = 5 (Constante)

tmp(23) := LDI & R0 & '0' & x"09";	-- #LDI R0 $9
tmp(24) := STA & R0 & '0' & x"09";	-- #STA @9 R0	-- MEM[9] = 9 (Constante)

-- ----- Valores , segundo , minuto e hora
-- Endereços de 10 a 19
-- Setado com valores padrões de inicio

tmp(25) := LDI & R0 & '0' & x"00";	-- #LDI R0 $0
tmp(26) := STA & R0 & '0' & x"0A";	-- #STA @10 R0	-- Segundos - UNIDADE
tmp(27) := STA & R0 & '0' & x"0B";	-- #STA @11 R0	-- Segundos - DEZENA
tmp(28) := STA & R0 & '0' & x"0C";	-- #STA @12 R0	-- Minuto   - UNIDADE
tmp(29) := STA & R0 & '0' & x"0D";	-- #STA @13 R0	-- Minuto   - DEZENA
tmp(30) := STA & R0 & '0' & x"0E";	-- #STA @14 R0	-- Hora     - UNIDADE
tmp(31) := STA & R0 & '0' & x"0F";	-- #STA @15 R0	-- Hora     - DEZENA

-- ----- Limpa Registradores
tmp(32) := LDI & R0 & '0' & x"00";	-- #LDI R0 $0	-- GERAL
tmp(33) := LDI & R1 & '0' & x"00";	-- #LDI R1 $0	-- Segundos - UNIDADE
tmp(34) := LDI & R2 & '0' & x"00";	-- #LDI R2 $0	-- Segundos - DEZENA
tmp(35) := LDI & R3 & '0' & x"00";	-- #LDI R3 $0	-- Minuto   - UNIDADE
tmp(36) := LDI & R4 & '0' & x"00";	-- #LDI R4 $0	-- Minuto   - DEZENA
tmp(37) := LDI & R5 & '0' & x"00";	-- #LDI R5 $0	-- Hora     - UNIDADE
tmp(38) := LDI & R6 & '0' & x"00";	-- #LDI R6 $0	-- Hora     - DEZENA
tmp(39) := LDI & R7 & '0' & x"00";	-- #LDI R7 $0	-- GERAL

tmp(40) := JMP & "000" & '1' & x"0F";	-- #JMP @271
tmp(41) := NOP & "000" & '0' & x"00";	-- #NOP

-- --------- LIMPA DISPLAYS | REGISTRADORES | MEMORIA -------- --

-- ----- Limpa Displays
tmp(42) := LDI & R0 & '0' & x"00";	-- #LDI R0   $0	-- Reg[0] = 0
tmp(43) := STA & R0 & '1' & x"20";	-- #STA @288 R0	-- HEX0   = 0
tmp(44) := STA & R0 & '1' & x"21";	-- #STA @289 R0	-- HEX1   = 0
tmp(45) := STA & R0 & '1' & x"22";	-- #STA @290 R0	-- HEX2   = 0
tmp(46) := STA & R0 & '1' & x"23";	-- #STA @291 R0	-- HEX3   = 0
tmp(47) := STA & R0 & '1' & x"24";	-- #STA @292 R0	-- HEX4   = 0
tmp(48) := STA & R0 & '1' & x"25";	-- #STA @293 R0	-- HEX5   = 0

-- ---- Registradores segundo , minuto , hora

tmp(49) := LDI & R1 & '0' & x"00";	-- #LDI R1 $0	-- Segundos - UNIDADE
tmp(50) := LDI & R2 & '0' & x"00";	-- #LDI R2 $0	-- Segundos - DEZENA
tmp(51) := LDI & R3 & '0' & x"00";	-- #LDI R3 $0	-- Minuto   - UNIDADE
tmp(52) := LDI & R4 & '0' & x"00";	-- #LDI R4 $0	-- Minuto   - DEZENA
tmp(53) := LDI & R5 & '0' & x"00";	-- #LDI R5 $0	-- Hora     - UNIDADE
tmp(54) := LDI & R6 & '0' & x"00";	-- #LDI R6 $0	-- Hora     - DEZENA

-- ----- Valores da memoria que guardam segundo , minuto e hora

tmp(55) := LDI & R0 & '0' & x"00";	-- #LDI R0 $0
tmp(56) := STA & R0 & '0' & x"0A";	-- #STA @10 R0	-- Segundos - UNIDADE
tmp(57) := STA & R0 & '0' & x"0B";	-- #STA @11 R0	-- Segundos - DEZENA
tmp(58) := STA & R0 & '0' & x"0C";	-- #STA @12 R0	-- Minuto   - UNIDADE
tmp(59) := STA & R0 & '0' & x"0D";	-- #STA @13 R0	-- Minuto   - DEZENA
tmp(60) := STA & R0 & '0' & x"0E";	-- #STA @14 R0	-- Hora     - UNIDADE
tmp(61) := STA & R0 & '0' & x"0F";	-- #STA @15 R0	-- Hora     - DEZENA

-- ----- Apaga Leds
tmp(62) := LDI & R0 & '0' & x"00";	-- #LDI R0   $0	-- Reg[0]  = 0
tmp(63) := STA & R0 & '1' & x"00";	-- #STA @256 R0	-- LEDR0-7 = 0
tmp(64) := STA & R0 & '1' & x"01";	-- #STA @257 R0	-- LEDR8   = 0
tmp(65) := STA & R0 & '1' & x"02";	-- #STA @258 R0	-- LEDR9   = 0

tmp(66) := JMP & "000" & '1' & x"0F";	-- #JMP @271
tmp(67) := NOP & "000" & '0' & x"00";	-- #NOP

-- --------- LIMPA para configuração ---------

-- ----- Limpa Displays
tmp(68) := LDI & R0 & '0' & x"00";	-- #LDI R0   $0	-- Reg[0] = 0
tmp(69) := STA & R0 & '1' & x"20";	-- #STA @288 R0	-- HEX0   = 0
tmp(70) := STA & R0 & '1' & x"21";	-- #STA @289 R0	-- HEX1   = 0
tmp(71) := STA & R0 & '1' & x"22";	-- #STA @290 R0	-- HEX2   = 0
tmp(72) := STA & R0 & '1' & x"23";	-- #STA @291 R0	-- HEX3   = 0
tmp(73) := STA & R0 & '1' & x"24";	-- #STA @292 R0	-- HEX4   = 0
tmp(74) := STA & R0 & '1' & x"25";	-- #STA @293 R0	-- HEX5   = 0

-- ---- Registradores segundo , minuto , hora

tmp(75) := LDI & R1 & '0' & x"00";	-- #LDI R1 $0	-- Segundos - UNIDADE
tmp(76) := LDI & R2 & '0' & x"00";	-- #LDI R2 $0	-- Segundos - DEZENA
tmp(77) := LDI & R3 & '0' & x"00";	-- #LDI R3 $0	-- Minuto   - UNIDADE
tmp(78) := LDI & R4 & '0' & x"00";	-- #LDI R4 $0	-- Minuto   - DEZENA
tmp(79) := LDI & R5 & '0' & x"00";	-- #LDI R5 $0	-- Hora     - UNIDADE
tmp(80) := LDI & R6 & '0' & x"00";	-- #LDI R6 $0	-- Hora     - DEZENA

tmp(81) := JMP & "000" & '0' & x"B3";	-- #JMP @179
tmp(82) := NOP & "000" & '0' & x"00";	-- #NOP

-- -----------------------------------------------------
-- INCREMENTA RELÓGIO
-- -----------------------------------------------------
-- ---------------- CONTA SEGUNDOS  ---------------- --

-- ---- UNIDADE - limitada ao número 9


tmp(83) := LDA & R1 & '0' & x"0A";	-- #LDA R1 @10	-- R1 = MEM[10]  ---> unidade segundo
tmp(84) := CEQ & R1 & '0' & x"09";	-- #CEQ R1 @9	-- Verifica se segundo-unidade = 9
tmp(85) := JEQ & "000" & '0' & x"5D";	-- #JEQ @93
tmp(86) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(87) := LDA & R1 & '0' & x"0A";	-- #LDA R1  @10	-- R1 = MEM[10]  ---> unidade segundo
tmp(88) := SOMA & R1 & '0' & x"01";	-- #SOMA R1 @1	-- R1 = R1 + 1   ---> Registrador R1 Contador  dos Segundos - UNIDADE
tmp(89) := STA & R1 & '1' & x"20";	-- #STA @288 R1	-- HEX0 = R1
tmp(90) := STA & R1 & '0' & x"0A";	-- #STA @10  R1
tmp(91) := RET & "000" & '0' & x"00";	-- #RET
tmp(92) := NOP & "000" & '0' & x"00";	-- #NOP

-- ---- DEZENA - limitada ao número 5

-- Limpa segundo-unidade
tmp(93) := LDI & R1 & '0' & x"00";	-- #LDI R1   $0
tmp(94) := STA & R1 & '0' & x"0A";	-- #STA @10  R1	-- R1 = MEM[10] = 0
tmp(95) := STA & R1 & '1' & x"20";	-- #STA @288 R1	-- HEX0 = 0

tmp(96) := LDA & R2 & '0' & x"0B";	-- #LDA R2 @11	-- R2 = MEM[11]  ---> dezena segundo
tmp(97) := CEQ & R2 & '0' & x"05";	-- #CEQ R2 @5
tmp(98) := JEQ & "000" & '0' & x"69";	-- #JEQ @105

tmp(99) := LDA & R2 & '0' & x"0B";	-- #LDA R2 @11	-- R2 = MEM[11]  ---> dezena segundo
tmp(100) := SOMA & R2 & '0' & x"01";	-- #SOMA R2 @1	-- R2 = R2 + 1   ---> Registrador R2 Contador  dos Segundos - DEZENA
tmp(101) := STA & R2 & '1' & x"21";	-- #STA @289 R2	-- HEX1 = R2
tmp(102) := STA & R2 & '0' & x"0B";	-- #STA @11  R2
tmp(103) := RET & "000" & '0' & x"00";	-- #RET
tmp(104) := NOP & "000" & '0' & x"00";	-- #NOP

-- ----------------- CONTA MINUTOS  ---------------- --

-- Limpa segundo-dezena
tmp(105) := LDI & R2 & '0' & x"00";	-- #LDI R2   $0
tmp(106) := STA & R2 & '0' & x"0B";	-- #STA @11  R2
tmp(107) := STA & R2 & '1' & x"21";	-- #STA @289 R2	-- HEX1 = 0

-- ---- UNIDADE - limitada ao número 9


tmp(108) := LDA & R3 & '0' & x"0C";	-- #LDA R3 @12	-- R3 = MEM[12]  ---> unidade minuto
tmp(109) := CEQ & R3 & '0' & x"09";	-- #CEQ R3 @9	-- Verifica se minuto-unidade = 9
tmp(110) := JEQ & "000" & '0' & x"76";	-- #JEQ @118
tmp(111) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(112) := LDA & R3 & '0' & x"0C";	-- #LDA R3 @12	-- R3 = MEM[12]  ---> unidade minuto
tmp(113) := SOMA & R3 & '0' & x"01";	-- #SOMA R3 @1	-- R3 = R3 + 1   ---> Registrador R3 Contador  dos Minuto - UNIDADE
tmp(114) := STA & R3 & '1' & x"22";	-- #STA @290 R3	-- HEX2 = R3
tmp(115) := STA & R3 & '0' & x"0C";	-- #STA @12  R3
tmp(116) := RET & "000" & '0' & x"00";	-- #RET
tmp(117) := NOP & "000" & '0' & x"00";	-- #NOP

-- ---- DEZENA - limitada ao número 5

-- Limpa unidade-minuto
tmp(118) := LDI & R3 & '0' & x"00";	-- #LDI R3   $0
tmp(119) := STA & R3 & '0' & x"0C";	-- #STA @12  R3
tmp(120) := STA & R3 & '1' & x"22";	-- #STA @290 R3	-- HEX2 = 0

tmp(121) := LDA & R4 & '0' & x"0D";	-- #LDA R4 @13	-- R4 = MEM[13]  ---> dezena minuto
tmp(122) := CEQ & R4 & '0' & x"05";	-- #CEQ R4 @5	-- Verifica se minuto-dezena = 5
tmp(123) := JEQ & "000" & '0' & x"83";	-- #JEQ @131
tmp(124) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(125) := LDA & R4 & '0' & x"0D";	-- #LDA R4 @13	-- R4 = MEM[13]  ---> dezena minuto
tmp(126) := SOMA & R4 & '0' & x"01";	-- #SOMA R4 @1	-- R4 = R4 + 1   ---> Registrador R4 Contador  dos Minuto - Dezena
tmp(127) := STA & R4 & '1' & x"23";	-- #STA @291 R4	-- HEX3 = R4
tmp(128) := STA & R4 & '0' & x"0D";	-- #STA @13  R4
tmp(129) := RET & "000" & '0' & x"00";	-- #RET
tmp(130) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------------------- CONTA HORAS  ---------------- --

-- Limpa hora-unidade
tmp(131) := LDI & R4 & '0' & x"00";	-- #LDI R4   $0
tmp(132) := STA & R4 & '0' & x"0D";	-- #STA @13  R4
tmp(133) := STA & R4 & '1' & x"23";	-- #STA @291 R4	-- HEX3 = 0

-- ---- UNIDADE - limitada ao número 9 ou 4/2 (24 horas | 12horas)

tmp(134) := LDA & R5 & '0' & x"0E";	-- #LDA R5 @14	-- R5 = MEM[14]  ---> unidade hora
tmp(135) := CEQ & R5 & '0' & x"09";	-- #CEQ R5 @9	-- Verifica se hora-unidade = 9
tmp(136) := JEQ & "000" & '0' & x"90";	-- #JEQ @144
tmp(137) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(138) := LDA & R5 & '0' & x"0E";	-- #LDA R5 @14	-- R5 = MEM[14]  ---> unidade hora
tmp(139) := SOMA & R5 & '0' & x"01";	-- #SOMA R5 @1	-- R5 = R5 + 1   ---> Registrador R5 Contador  dos Hora - Unidade
tmp(140) := STA & R5 & '1' & x"24";	-- #STA @292 R5	-- HEX4 = R5
tmp(141) := STA & R5 & '0' & x"0E";	-- #STA @14  R5
tmp(142) := JMP & "000" & '0' & x"9D";	-- #JMP @157
tmp(143) := NOP & "000" & '0' & x"00";	-- #NOP

-- ---- DEZENA - limitada a 2|1 a depender da configuração

-- Limpa hora-unidade
tmp(144) := LDI & R5 & '0' & x"00";	-- #LDI R5   $0
tmp(145) := STA & R5 & '0' & x"0E";	-- #STA @14  R5
tmp(146) := STA & R5 & '1' & x"24";	-- #STA @292 R5	-- HEX4 = 0

tmp(147) := LDA & R6 & '0' & x"0F";	-- #LDA R6 @15	-- R6 = MEM[15]  ---> dezena hora
tmp(148) := CEQ & R6 & '0' & x"02";	-- #CEQ R6 @2	-- Verifica se hora-dezena = 2
tmp(149) := JEQ & "000" & '0' & x"2A";	-- #JEQ @42
tmp(150) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(151) := LDA & R6 & '0' & x"0F";	-- #LDA R6 @15	-- R6 = MEM[15]  ---> dezena hora
tmp(152) := SOMA & R6 & '0' & x"01";	-- #SOMA R6 @1	-- R6 = R6 + 1   ---> Registrador R6 Contador  dos Hora - Unidade
tmp(153) := STA & R6 & '1' & x"25";	-- #STA @293 R6	-- HEX5 = R6
tmp(154) := STA & R6 & '0' & x"0F";	-- #STA @15  R6
tmp(155) := JMP & "000" & '0' & x"9D";	-- #JMP @157
tmp(156) := NOP & "000" & '0' & x"00";	-- #NOP

-- ----------------- VERIFICA HORA ----------------- --

-- ------ verifica unidade-hora

tmp(157) := LDA & R5 & '0' & x"0E";	-- #LDA R5 @14
tmp(158) := CEQ & R5 & '0' & x"04";	-- #CEQ R5 @4	-- Verifica se hora-unidade = 4
tmp(159) := JEQ & "000" & '0' & x"A3";	-- #JEQ @163
tmp(160) := NOP & "000" & '0' & x"00";	-- #NOP
tmp(161) := RET & "000" & '0' & x"00";	-- #RET
tmp(162) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------ verifica dezena-hora

tmp(163) := LDA & R6 & '0' & x"0F";	-- #LDA R6 @15
tmp(164) := CEQ & R6 & '0' & x"02";	-- #CEQ R6 @2	-- Verifica se hora-dezena = 2
tmp(165) := JEQ & "000" & '0' & x"2A";	-- #JEQ @42
tmp(166) := NOP & "000" & '0' & x"00";	-- #NOP
tmp(167) := RET & "000" & '0' & x"00";	-- #RET
tmp(168) := NOP & "000" & '0' & x"00";	-- #NOP

-- -----------------------------------------------------
-- CONFIGURA HORARIO ATUAL
-- -----------------------------------------------------


-- Caso chave SW8 ativa
tmp(169) := LDA & R7 & '1' & x"41";	-- #LDA R7 @321	-- SW8
tmp(170) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 @1
tmp(171) := JEQ & "000" & '0' & x"AF";	-- #JEQ @175	-- Set Unidade-segundos
tmp(172) := NOP & "000" & '0' & x"00";	-- #NOP
tmp(173) := JMP & "000" & '1' & x"05";	-- #JMP @261	-- Vai pro fim da configuração
tmp(174) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Inicia Configurações


tmp(175) := LDI & R7 & '0' & x"01";	-- #LDI R7   $1
tmp(176) := STA & R7 & '1' & x"01";	-- #STA @257 R7	-- LEDR8 : ativo - indicativo de configuração

-- ------- LIMPA
tmp(177) := JMP & "000" & '0' & x"44";	-- #JMP @68
tmp(178) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Configura Unidade-Segundos


tmp(179) := STA & "000" & '1' & x"FF";	-- #STA @511	-- Endereco 511 : Limpa Flag FlipFlop KEY0

tmp(180) := LDI & R7 & '0' & x"01";	-- #LDI R7   $1
tmp(181) := STA & R7 & '1' & x"00";	-- #STA @256 R7	-- LEDR0 : Configura unidade-segundo

-- Salva SW0-SW7 em config Unidade-Segundo
tmp(182) := LDA & R1 & '1' & x"40";	-- #LDA R1 @320	-- R1 = SW0-SW7
tmp(183) := STA & R1 & '0' & x"0A";	-- #STA @10  R1	-- Segundos - UNIDADE
tmp(184) := STA & R1 & '1' & x"20";	-- #STA @288 R1	-- HEX0

-- Verifica KEY0
tmp(185) := LDA & R7 & '1' & x"60";	-- #LDA R7 @352	-- KEY0
tmp(186) := OP_AND & R7 & '0' & x"01";	-- #OP_AND R7 @1	-- Limpa valores lixo
tmp(187) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 $1
tmp(188) := JEQ & "000" & '0' & x"C0";	-- #JEQ @192
tmp(189) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(190) := JMP & "000" & '0' & x"B3";	-- #JMP @179
tmp(191) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Configura Dezena-Segundos


tmp(192) := STA & "000" & '1' & x"FF";	-- #STA @511	-- Endereco 511 : Limpa Flag FlipFlop KEY0

tmp(193) := LDI & R7 & '0' & x"02";	-- #LDI R7   $2
tmp(194) := STA & R7 & '1' & x"00";	-- #STA @256 R7	-- LEDR1 : Configura dezena-segundo

-- Salva SW0-SW7 em config Dezena-segundo
tmp(195) := LDA & R2 & '1' & x"40";	-- #LDA R2 @320	-- R2 = SW0-SW7
tmp(196) := STA & R2 & '0' & x"0B";	-- #STA @11  R2	-- Segundos - DEZENA
tmp(197) := STA & R2 & '1' & x"21";	-- #STA @289 R2	-- HEX1

-- Verifica KEY0
tmp(198) := LDA & R7 & '1' & x"60";	-- #LDA R7 @352	-- KEY0
tmp(199) := OP_AND & R7 & '0' & x"01";	-- #OP_AND R7 @1	-- Limpa valores lixo
tmp(200) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 @1
tmp(201) := JEQ & "000" & '0' & x"CD";	-- #JEQ @205
tmp(202) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(203) := JMP & "000" & '0' & x"C0";	-- #JMP @192
tmp(204) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Configura Unidade-Minuto


tmp(205) := STA & "000" & '1' & x"FF";	-- #STA @511	-- Endereco 511 : Limpa Flag FlipFlop KEY0

tmp(206) := LDI & R7 & '0' & x"04";	-- #LDI R7   $4
tmp(207) := STA & R7 & '1' & x"00";	-- #STA @256 R7	-- LEDR2 : Configura unidade-minuto

-- Salva SW0-SW7 em config Unidade-Minuto
tmp(208) := LDA & R3 & '1' & x"40";	-- #LDA R3 @320	-- R3 = SW0-SW7
tmp(209) := STA & R3 & '0' & x"0C";	-- #STA @12  R3	-- Unidade - MINUTO
tmp(210) := STA & R3 & '1' & x"22";	-- #STA @290 R3	-- HEX2

-- Verifica KEY0
tmp(211) := LDA & R7 & '1' & x"60";	-- #LDA R7 @352	-- KEY0
tmp(212) := OP_AND & R7 & '0' & x"01";	-- #OP_AND R7 @1	-- Limpa valores lixo
tmp(213) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 @1
tmp(214) := JEQ & "000" & '0' & x"DA";	-- #JEQ @218
tmp(215) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(216) := JMP & "000" & '0' & x"CD";	-- #JMP @205
tmp(217) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Configura Dezena-Minuto


tmp(218) := STA & "000" & '1' & x"FF";	-- #STA @511	-- Endereco 511 : Limpa Flag FlipFlop KEY0

tmp(219) := LDI & R7 & '0' & x"08";	-- #LDI R7   $8
tmp(220) := STA & R7 & '1' & x"00";	-- #STA @256 R7	-- LEDR3 : Configura dezena-minuto

-- Salva SW0-SW7 em config Minuto-Dezena
tmp(221) := LDA & R4 & '1' & x"40";	-- #LDA R4 @320	-- R4 = SW0-SW7
tmp(222) := STA & R4 & '0' & x"0D";	-- #STA @13  R4	-- Minuto - DEZENA
tmp(223) := STA & R4 & '1' & x"23";	-- #STA @291 R4	-- HEX3

-- Verifica KEY0
tmp(224) := LDA & R7 & '1' & x"60";	-- #LDA R7 @352	-- KEY0
tmp(225) := OP_AND & R7 & '0' & x"01";	-- #OP_AND R7 @1	-- Limpa valores lixo
tmp(226) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 @1
tmp(227) := JEQ & "000" & '0' & x"E7";	-- #JEQ @231
tmp(228) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(229) := JMP & "000" & '0' & x"DA";	-- #JMP @218
tmp(230) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Configura Unidade-Hora


tmp(231) := STA & "000" & '1' & x"FF";	-- #STA @511	-- Endereco 511 : Limpa Flag FlipFlop KEY0

tmp(232) := LDI & R7 & '0' & x"10";	-- #LDI R7   $16
tmp(233) := STA & R7 & '1' & x"00";	-- #STA @256 R7	-- LEDR4 : Configura unidade-HORA

-- Salva SW0-SW7 em config Minuto-Dezena
tmp(234) := LDA & R5 & '1' & x"40";	-- #LDA R5 @320	-- R5 = SW0-SW7
tmp(235) := STA & R5 & '0' & x"0E";	-- #STA @14  R5	-- Hora - UNIDADE
tmp(236) := STA & R5 & '1' & x"24";	-- #STA @292 R5	-- HEX4

-- Verifica KEY0
tmp(237) := LDA & R7 & '1' & x"60";	-- #LDA R7 @352	-- KEY0
tmp(238) := OP_AND & R7 & '0' & x"01";	-- #OP_AND R7 @1	-- Limpa valores lixo
tmp(239) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 @1
tmp(240) := JEQ & "000" & '0' & x"F4";	-- #JEQ @244
tmp(241) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(242) := JMP & "000" & '0' & x"E7";	-- #JMP @231
tmp(243) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Configura Dezena-Hora


tmp(244) := STA & "000" & '1' & x"FF";	-- #STA @511	-- Endereco 511 : Limpa Flag FlipFlop KEY0

tmp(245) := LDI & R7 & '0' & x"20";	-- #LDI R7   $32
tmp(246) := STA & R7 & '1' & x"00";	-- #STA @256 R7	-- LEDR5 : Configura unidade-minuto

-- Salva SW0-SW7 em config Hora-Dezena
tmp(247) := LDA & R6 & '1' & x"40";	-- #LDA R6 @320	-- R6 = SW0-SW7
tmp(248) := STA & R6 & '0' & x"0F";	-- #STA @15  R6	-- Hora - DEZENA
tmp(249) := STA & R6 & '1' & x"25";	-- #STA @293 R6	-- HEX5

-- Verifica KEY0
tmp(250) := LDA & R7 & '1' & x"60";	-- #LDA R7 @352	-- KEY0
tmp(251) := OP_AND & R7 & '0' & x"01";	-- #OP_AND R7 @1	-- Limpa valores lixo
tmp(252) := CEQ & R7 & '0' & x"01";	-- #CEQ R7 @1
tmp(253) := JEQ & "000" & '1' & x"01";	-- #JEQ @257
tmp(254) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(255) := JMP & "000" & '0' & x"F4";	-- #JMP @244
tmp(256) := NOP & "000" & '0' & x"00";	-- #NOP

-- ------- Limpa Displays e LEDS

-- ----- Apaga Leds
tmp(257) := LDI & R0 & '0' & x"00";	-- #LDI R0   $0	-- Reg[0]  = 0
tmp(258) := STA & R0 & '1' & x"00";	-- #STA @256 R0	-- LEDR0-7 = 0
tmp(259) := STA & R0 & '1' & x"01";	-- #STA @257 R0	-- LEDR8   = 0
tmp(260) := STA & R0 & '1' & x"02";	-- #STA @258 R0	-- LEDR9   = 0

-- ------- Fim da configuração

tmp(261) := RET & "000" & '0' & x"00";	-- #RET
tmp(262) := NOP & "000" & '0' & x"00";	-- #NOP

-- -----------------------------------------------------
-- BASE DE TEMPO
-- -----------------------------------------------------


tmp(263) := LDA & R0 & '1' & x"65";	-- #LDA R0 @357	-- Ler endereço da Base de tempo
tmp(264) := OP_AND & R0 & '0' & x"01";	-- #OP_AND R0 @1	-- Limpa valores lixo

tmp(265) := CEQ & R0 & '0' & x"01";	-- #CEQ R0 @1	-- Se Reg0 = 1 -> Pula para subrotina
tmp(266) := STA & R0 & '1' & x"FD";	-- #STA @509 R0	-- MEM[509] = 0  ---> Limpa FlipFlop

tmp(267) := JEQ & "000" & '0' & x"53";	-- #JEQ @83
tmp(268) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(269) := RET & "000" & '0' & x"00";	-- #RET
tmp(270) := NOP & "000" & '0' & x"00";	-- #NOP

-- -----------------------------------------------------
-- ROTINA PRINCIPAL
-- -----------------------------------------------------


-- Subrotina de Base de Tempo
tmp(271) := JSR & "000" & '1' & x"07";	-- #JSR @263
tmp(272) := NOP & "000" & '0' & x"00";	-- #NOP

-- Subrotina de Configuração de Horario
tmp(273) := JSR & "000" & '0' & x"A9";	-- #JSR @169
tmp(274) := NOP & "000" & '0' & x"00";	-- #NOP

tmp(275) := JMP & "000" & '1' & x"0F";	-- #JMP @271
tmp(276) := NOP & "000" & '0' & x"00";	-- #NOP
-- FIM
        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;