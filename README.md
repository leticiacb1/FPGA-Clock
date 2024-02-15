## ⏰️ FPGA-Clock

* Placa utilizada no projeto : [DE0-CV Board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=921)

* Software utilizado na programação do projeto : [Quartus Prime Lite, versão 20.1](https://www.intel.com/content/www/us/en/collections/products/fpga/software/downloads.html?s=Newest&edition=lite&f:guidetmD240C377263B4C70A4EA0E452D0182CA=%5BIntel%C2%AE%20Quartus%C2%AE%20Prime%20Design%20Software%3BIntel%C2%AE%20Quartus%C2%AE%20Prime%20Lite%20Edition%5D)

<div align="center">
  <img alt="fpga" src="Img/fpga.png" width="500rm" \>
</div>

O objetivo do projeto é a implementação de um processador juntamente com um montador Assembler, que será utilizado em um relógio com as seguintes características :

* Indica horas, minutos e segundos.

* O horário deverá ser mostrado através do display de sete segmentos.
  
* Possui um sistema para acertar o horário.

Para entender mais sobre o projeto, confira o arquivo `Relogio.pdf`.

Clique [aqui](https://youtu.be/K1QLyN4HzFs?si=zYU1Ws6WwycHXnDx) e veja o relógio funcionando! 

### 👩‍💻️ Características do Processador

* Arquitetura Harvard;

* Barramento de dados : 8 bits.

* Barramento de endereços : 16 bits;

* Topologia `Registrador-Memória`.

### 📊️ Diagramas

`Arquitetura do Processador`

<div align="center">
  <img alt="fpga" src="Img/arq_processador.png" width="500rm" \>
</div>

`Base de Tempo`

<div align="center">
  <img alt="fpga" src="Img/base_de_tempo.png" width="500rm" \>
</div>

`Leds e Chaves`

<div align="center">
  <img alt="fpga" src="Img/leds_e_chaves.png" width="500rm" \>
</div>

`Botão`

<div align="center">
  <img alt="fpga" src="Img/botao.png" width="500rm" \>
</div>

<br>
@2023, Insper. Sexto Semestre, Engenharia da Computação.
