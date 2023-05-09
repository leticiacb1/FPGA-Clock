'''
Formato das instruçoes a serem recebidas

    > Add  R1 @12      # R[1] = R[1] + Mem[0x1FF].

    > LDA R1 @12      # R[1] = Mem[0x1FF].

    > STA @12 R1     # Mem[0x1FF] = R[1].

Possiveis registradores : 
R0 ... R7

'''
import re

def  converteArroba(line):
    '''
    > Exemplo de instrução:
    
    Recebe :
        JMP @2
    Retorna : 
        & '0' & x"02"
    
    '''

    opcode = defineOpCode(line)
    line = line.split('@')
    
    # Tratando para a condição : STA @12 R1
    if (opcode.strip() == 'STA') : 
        number_after = re.split("\s+", line[1])
        number_after = number_after[0] 
    else:
        number_after = line[-1]

    if(int(number_after.strip()) > 255 ):
        number = str(int(number_after) - 256)
        number_plus = '1'
    else:
        number = number_after
        number_plus = '0'

    hex_number = hex(int(number))[2:].upper().zfill(2)
    number_format = " & " + "\'" + number_plus + "\'" +" & x\"" + hex_number + "\""

    return number_format
  
def  converteCifrao(line):
    '''
    > Exemplo de instrução:
    
    1 . LDI R0  $5 
    
    '''

    line = line.split('$')
    if(int(line[-1].strip()) > 255 ):
        number = str(int(line[-1]) - 256)
        number_plus = '1'
    else:
        number = line[-1]
        number_plus = '0'

    hex_number = hex(int(number))[2:].upper().zfill(2)
    number_format = " & " + "\'" + number_plus + "\'" +" & x\"" + hex_number + "\""
    
    return number_format

def defineRegistrador(line):
    '''
    Input : 
        LDI R0 $5

    Retorno :
        R0
    '''

    lista_registradores = ['R0','R1','R2','R3','R4','R5','R6','R7']
    result = re.split("\s+", line)

    for registrador in result:
        if(registrador in lista_registradores):
            return registrador
    return None


def defineComentario(line):
    '''

    > Definição de comentário:
    
    1 . JSR @14 #comentario1
    
    '''
    if '#' in line:
        line = line.split('#')
        comentario = line[1].strip()
        return comentario
    else:
        return None

def defineInstrucao(line):
    '''
    Retorna apenas a instrução:

    JSR @14 #comentario1  -> JSR @14

    '''

    line = line.split('#')
    line = line[0]
    return line

def defineOpCode(line):
    '''
    Recebe : JSR @14 ou  LDI R0 , $5

    Retorna : JSR    ou  LDI
    
    '''
    line = re.split("\s+", line)
    opcode = line[0].strip()
    return opcode

def tableLabel(lines):
    '''
    Cria tabela hash de correspondência : LABEL -> linha
    '''

    hash_table = {}
    count = 0

    for line in lines:
        if(line.startswith('.')):

            label = line.replace('.' , '')
            label = label.strip()

            hash_table[label] = count
        
        if((line.startswith('#')) or (line.startswith('\n')) or (line.startswith('.'))):
            pass
        else:
            count+=1
            
    return hash_table

def carregaArquivo(filename):
    with open(filename, "r") as f: 
        data = f.readlines() 

    return data

def write_ROM(fileBIN , pathfileROM):
    '''
    Escreve linhas na memoriaROM
    '''
    old_file_content = carregaArquivo(pathfileROM)
    new_data = carregaArquivo(fileBIN)

    footer = []
    add_footer = False
    for i in old_file_content:
        if ("FIM" in i): 
            add_footer = True
        if add_footer:
            footer.append(i)

    # Posiciona novo conteúdo no local correto do arquio, indicado por : "INICIO"
    with open(pathfileROM, "w+") as f:     
        for line in old_file_content:
            if ("INICIO" in line): 
                f.write(line)
                for content in new_data:
                    f.write(content)
                for footer_data in footer:
                    f.write(footer_data)
                break
            else:
                f.write(line)

def main(fileASM , fileBIN , pathfileROM):
    '''
    Tranforma o código em Assembly em código de máquina (entendido pela memória ROM).
    
    > Entrada :
        JSR @14 #comentario1
    
    > Saída :
        tmp(0) := JSR & '0' & x"0E";	-- JSR @14 	#comentario1
    
    '''

    # Contagem de linhas
    count = 0

    # Abre arquivo
    with open(fileBIN, "w+") as f: 

        # Carrega dados
        lines  = carregaArquivo(fileASM)

        # Lables
        dict_labels = tableLabel(lines)

        for line in lines:        
            
            line = line.strip()
            comentario = defineComentario(line)
            if(comentario != None):                                         
                comentario = defineComentario(line).replace("\n","")     # Ex( JSR @14 #comentario1 ) :  comentario1
            
            instrucao  = defineInstrucao(line).replace("\n","")          # Ex( JSR @14 #comentario1 ) :  JSR @14
            instrucao = instrucao.strip()
            registrador = defineRegistrador(instrucao)
            opcode      = defineOpCode(instrucao)                        # Ex( JSR @14 #comentario1 ) :  JSR

            if '@' in instrucao: 
                number_hex_format = converteArroba(instrucao)            # Ex(JSR @14) : & '0' & x"0E"

            elif '$' in instrucao:
                number_hex_format = converteCifrao(instrucao)            # Ex(LDI $5)  : & '0' & x"05"

            elif (not(line.startswith('.')) and ('.' in instrucao)):     # Trata operações do tipo : JMP .LABEL
               
                label = instrucao.split('.')[-1].strip()
                number_line = dict_labels[label]

                if(number_line > 255):
                    number_line_hex = hex(int(number_line - 256))[2:].upper().zfill(2)
                    number_hex_format =  " & '1' & x\"" + number_line_hex + "\""
                else:
                    number_line_hex = hex(int(number_line))[2:].upper().zfill(2)
                    number_hex_format =  " & '0' & x\"" + number_line_hex + "\""
        
                instrucao = opcode + " @" + str(number_line)
                
            elif ('RET' in instrucao) or ('NOP' in instrucao):
                number_hex_format =  " & " + "\'0\' & " + "x\"00" + "\""
            
            else:
                
                if(line.startswith('#')):
                    # Linha de comentário
                    line = '-- ' + comentario + '\n'
                    f.write(line)
                else:
                    # Quebra de linha :  manter quebra de linha no arquivo:
                    f.write('\n')

                continue

            # Remove a quebra de linha
            instrucao = instrucao.replace("\n", "") 

            # Formata
            if(comentario == None):
                # Caso nao possua comentário
                if(registrador != None):
                    line = 'tmp(' + str(count) + ') := ' + opcode + " & " + registrador + number_hex_format + ';\t-- #' + instrucao + '\n'
                else:
                    line = 'tmp(' + str(count) + ') := ' + opcode + " & " + "\"000\"" + number_hex_format + ';\t-- #' + instrucao + '\n'

            else:
                if(registrador != None):
                    line = 'tmp(' + str(count) + ') := ' + opcode + " & " + registrador + number_hex_format + ';\t-- #' + instrucao + '\t-- ' + comentario + '\n'
                else:
                    line = 'tmp(' + str(count) + ') := ' + opcode + " & " + "\"000\"" + number_hex_format + ';\t-- #' + instrucao + '\t-- ' + comentario + '\n'

            count+=1 
            f.write(line)
        
    # Escreve na ROM:
    write_ROM(fileBIN , pathfileROM)

if __name__ == "__main__":
    
    # Arquivo com Assembly
    inputASM = 'ASM.txt'  

    #Arquivo com Binário VHDL    
    outputBIN = 'BIN.txt'    
    
    # Arquivo ROM
    pathfileROM = '../Arquitetura/memoriaROM.vhd'

    main(inputASM , outputBIN, pathfileROM)