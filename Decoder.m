function decoder=decodifica(nome_do_arquivo)

nome_arquivo=strrep(nome_do_arquivo,'.','_comprimido.');
arquivo_id=fopen(nome_arquivo, 'rb','n','ISO-8859-1');
arquivo=fread(arquivo_id, inf, 'uint8');
fclose(arquivo_id);

%% Abre o arquivo com conteúdo

nome_cabecalho=strrep(nome_do_arquivo,'.','_header.');
cabecalho_id=fopen(nome_cabecalho, 'rb');
bits_enviados=fgetl(cabecalho_id);
bits_por_simbolo=fgetl(cabecalho_id);
bits_por_simbolo=strsplit(char(bits_por_simbolo), ',');
bits_por_simbolo=str2num(char(bits_por_simbolo));
%% Lê e separa o cabeçalho, recebendo a quantidade de bits enviados e o tamanho do código de cada símbolo

bits_recebidos=8*ceil(str2num(bits_enviados)/8);
bits_descartados=bits_recebidos-str2num(bits_enviados);
texto_codificado = dec2bin(arquivo);
texto_codificado = reshape(texto_codificado',[1 size(texto_codificado,1)*size(texto_codificado,2)]);
texto_codificado(end-bits_descartados+1:end) = [];
%% Prepara o texto recebido, transformando os valores recebidos de char para
%% um bitstream binário e lendo apenas os bits enviados, ignorando os bits 
%% adicionados na mensagem apenas para completar o resto do byte e permitir
%% a escrita 

elementos=containers.Map;
for i=1:length(bits_por_simbolo)
    if  bits_por_simbolo(i)~=0
        elementos(char(i-1))=bits_por_simbolo(i);
    end
end

%% Identifica todos os elementos presentes na mensagem por meio do número de
%% bits que representam cada símbolo

tabela_bps=horzcat(keys(elementos).', values(elementos).');
tabela_bps=sortrows(tabela_bps, [2,1]);

%% Constrói uma tabela que relaciona cada símbolo com o número de bits de seu código

codigo=0;
for i=1:length(tabela_bps)-1
    N_atual=cell2mat(tabela_bps(i, 2));
    N_next=cell2mat(tabela_bps(i+1,2));
    codigo_fi=dec2bin(codigo, N_atual);
    tabela_bps(i,3)=cellstr(codigo_fi);
    codigo=(codigo+1);
    codigo=codigo*2^(N_next-N_atual);
end
codigo_fi=dec2bin(codigo,N_atual);
tabela_bps(length(tabela_bps),3)=cellstr(codigo_fi);

%% Resgata os códigos enviados por meio de processo análogo ao de codificação

ranges=cell(length(tabela_bps),2);
for i=1:length(tabela_bps)
    ranges(i,1)=num2cell(bin2dec(tabela_bps(i,3))*2^( cell2mat(tabela_bps(end, 2))-cell2mat(tabela_bps(i,2)) ));
    ranges(i,2)=num2cell(cell2mat(ranges(i,1))+2^(cell2mat(tabela_bps(end,2))-cell2mat(tabela_bps(i,2)))-1);
end
range_table=table(cell2mat(ranges(:,1)), cell2mat(ranges(:,2)), tabela_bps(:,1), tabela_bps(:,2));
range_table=table2cell(range_table);

%% Gera uma tabela que contém os intervalos (decimais) de início e de final da
%% representação de cada símbolo na Look-Up table, bem como o símbolo
%% e o número de bits com o qual é representado

ponteiro=1;
buffer_size=cell2mat(tabela_bps(end,2));
texto_decodificado='';

while ponteiro<length(texto_codificado)
    if ponteiro+double(buffer_size)-1>length(texto_codificado)
        bitstream=texto_codificado(ponteiro:end);
    else
       bitstream=texto_codificado(ponteiro:ponteiro+double(buffer_size)-1);
    end
    bitstream=bin2dec(bitstream);
    index=find(bitstream>=cell2mat(ranges(:,1)) & bitstream<=cell2mat(ranges(:,2)));
    texto_decodificado=strcat(texto_decodificado, range_table(index, 3));
    ponteiro=ponteiro+double(cell2mat(range_table(index, 4)));
end

%% Decodifica o texto por meio de sucessivas consultas à look-up table 

nome_saida=strrep(nome_do_arquivo,'.','_descomprimido.');
saida_id=fopen(nome_saida, 'wb','n','ISO-8859-1');
count=fwrite(saida_id, char(texto_decodificado), 'uint8');

%% Escreve o texto decodificado na saída