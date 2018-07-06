function codificadora= huffEncode(matrix, nome_arquivo, offset)

%  nome_arquivo='Teste.txt';
% % %% Abre o matrix 
%  matrix_id=fopen(nome_arquivo,'rb','n', 'ISO-8859-1');
%  matrix=fread(matrix_id, inf, 'uint8');
%  fclose(matrix_id);

%% Lê do matrix

N=length(matrix);
elementos=unique(matrix);
Frequencia = containers.Map;

for i=1:length(elementos)
    Frequencia(char(elementos(i)))=sum(matrix==elementos(i));
end

%% Registra em um mapa quantas vezes cada símbolo aparece e com qual frequência 

entradas=cat(3,keys(Frequencia), values(Frequencia));
dimensao=size(entradas);
entradas=reshape(entradas,[dimensao(2),2]);

%% Transforma o mapa em um vetor bi-dimensional de chaves e frequência de ocorrência

entradas=sortrows(entradas, -2);
entradas_nb=entradas;

%% Ordena o vetor de entradas e cria uma cópia, entradas_nb, que será modificada
%% ao longo do processo de associação

index=0;
etapa=containers.Map;

while length(entradas_nb)>2
 step=strcat('V_',num2str(index));
 temp=cell2mat(entradas_nb(length(entradas_nb),2))+cell2mat(entradas_nb(length(entradas_nb)-1,2));
 elemento_menor=char(entradas_nb(length(entradas_nb),1));
 elemento_maior=char(entradas_nb(length(entradas_nb)-1,1));
 etapa(elemento_menor)=step;
 etapa(elemento_maior)=step;
 index=index+1;
 entradas_nb(length(entradas_nb),:)=[];
 entradas_nb(length(entradas_nb),1)=cellstr(step);
 entradas_nb(length(entradas_nb),2)=num2cell(temp);
 entradas_nb=sortrows(entradas_nb, -2);
end


% Enquanto o vetor tiver mais de dois elementos, associa os dois elementos
% menos frequentes, indicando os elementos associados no mapa etapa e
% reordenando o vetor. Cada nova associação recebe um novo nome próprio

etapa(char(entradas_nb(1,1)))='END';
etapa(char(entradas_nb(2,1)))='END';

% Indica que os dois elementos [associados ou não] do mapa encerraram a
% rotina, ao invés de terem sido (re-)associados

tamanho=containers.Map;
% Cria um mapa para fazer a correspondência entre cada caractere e seu
% número  de bits 

L=length(entradas);


for i=1:L
    numero_bits=1;
    chave=cellstr(entradas(i,1));
    while(~strcmp(etapa(char(chave)), 'END'))       
            numero_bits=numero_bits+1;
        chave=etapa(char(chave));
    end
    tamanho(char(entradas(i)))=numero_bits;
end

% Verifica o número de bits de cada caractere de entrada verificando
% quantas vezes esse caractere foi associado e quantas vezes as associações
% que o incluem foram novamente associadas.

tamanho_vetor=cat(3,keys(tamanho), values(tamanho));
dimensao=size(tamanho_vetor);
tamanho_vetor=reshape(tamanho_vetor,[dimensao(2),2]);
tamanho_vetor=sortrows(tamanho_vetor, [2,1]);

%% Cria um vetor com o número de bits que o código de cada entrada terá 

codigo=0;
codewords=containers.Map;

for i=1:length(tamanho_vetor)-1
    N_atual=cell2mat(tamanho_vetor(i, 2));
    N_next=cell2mat(tamanho_vetor(i+1,2));
    valor_codigo=dec2bin(codigo, N_atual);
    codewords(char(tamanho_vetor(i,1)))=valor_codigo;
    codigo=(codigo+1);
    codigo=codigo*2^(N_next-N_atual);
end
valor_codigo=dec2bin(codigo, N_atual);
codewords(char(tamanho_vetor(length(tamanho_vetor), 1)))=valor_codigo;

%% Gera um código de Huffman Canônico para cada entrada

bitstream=encode(cell2mat(keys(codewords)), values(codewords), matrix);
tamanho_bitstream=length(bitstream);
byte_number=ceil(tamanho_bitstream/8);
extra_zeros=8*byte_number-tamanho_bitstream; 
for i=1:extra_zeros
    bitstream(end+1)=0;
end

%% Recebe, enviando o dicionário, os códigos e a mensagem, o bitstream e 
%% depois prepara o bitstream para escrever em bytes, não em bits

bitstream_saida=[];
c=1;
for i=1:8:8*byte_number
    bitstream_saida(c)=bin2dec(bitstream(i:i+7));
    c=c+1;
end
    
%% Separa o bitstream em conjuntos de 8 bits e converte seu valor para char
nome_saida=strrep(nome_arquivo, '.', '_comprimido.');
saida_id=fopen(nome_saida,'wb','n','ISO-8859-1');
count=fwrite(saida_id, bitstream_saida, 'uint8');

%% Escreve totalmente o matrix codificado

buffer_tamanhos='';
for i=0:255
   if isKey(tamanho, char(i))
       buffer_tamanhos=strcat(buffer_tamanhos, num2str(tamanho(char(i))));
   else
       buffer_tamanhos=strcat(buffer_tamanhos,'0');
   end
   if i~=255
    buffer_tamanhos=strcat(buffer_tamanhos,','); 
   end
end

%% Gera o buffer de saída com o tamanho do código de cada símbolo (Huffman Canônico)

nome_cabecalho=strrep(nome_arquivo,'.','_header.');
cabecalho_id=fopen(nome_cabecalho,'wb','n','ISO-8859-1');
count=fwrite(cabecalho_id, [num2str(N) char(10)], 'uint8');
count=fwrite(cabecalho_id, [num2str(tamanho_bitstream) char(10)], 'uint8');
count=fwrite(cabecalho_id, num2str(offset), 'uint8');
count=fwrite(cabecalho_id, [char(10) buffer_tamanhos], 'uint8');

%% Escreve o matrix com as informações do matrix codificado
fclose(saida_id);
fclose(cabecalho_id);
end