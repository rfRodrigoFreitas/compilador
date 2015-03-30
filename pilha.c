#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "pilha.h"

//Empilha variáveis na Tabela de Símbolos
void empilhaTS (PilhaTS * tabela_simbolos, char var[50], int nivel_lex, int deslocamento, char tipo[10]){
    ElementoTS * nodo;
    nodo = malloc(sizeof(ElementoTS));
    strcpy (nodo->var, var);
    strcpy (nodo->tipo, tipo);
    nodo->nivel_lex = nivel_lex;
    nodo->deslocamento = deslocamento;
    nodo->proximo = tabela_simbolos->inicio;
    tabela_simbolos->inicio = nodo;
    tabela_simbolos->tamanho++;
}

//Retorna na pilha empilhando os tipos
void empilhaTipoTS(PilhaTS * tabela_simbolos, char tipo[10]) {
    ElementoTS * nodo = tabela_simbolos->inicio;
    int tam = tabela_simbolos->tamanho;
    while(strcmp(nodo->tipo, "undefined") == 0) {
        strcpy(nodo->tipo, tipo);
        tam--;
        if(tam == 0) continue;
        nodo = nodo->proximo;

    }
}

//Empilha os tipos na pilha de tipos
void empilhaTT (PilhaTT * tabela_tipos, char tipo[10]){
    ElementoTT * nodo;
    nodo = malloc(sizeof(ElementoTT));
    strcpy (nodo->tipo, tipo);
    nodo->proximo = tabela_tipos->inicio;
    tabela_tipos->inicio = nodo;
    tabela_tipos->tamanho++;
}

//Desempilha, para usos relacionados ao bison
ElementoTS * buscaTS (PilhaTS * tabela_simbolos, char var[10]) {
    ElementoTS * nodo = tabela_simbolos->inicio;
    int tam = tabela_simbolos->tamanho;
    while(strcmp(nodo->var, var) != 0) {
        tam--;
        if(tam == 0) return NULL;
        nodo = nodo->proximo;
    }
    return nodo;
}

//Função inicializadora das pilhas
void iniciarTS (PilhaTS * tabela_simbolos) {
    tabela_simbolos->inicio = NULL;
    tabela_simbolos->tamanho = 0;
}

void iniciarTT (PilhaTT * tabela_tipos) {
    tabela_tipos->inicio = NULL;
    tabela_tipos->tamanho = 0;
}

//Percore e imprime a Tabela de Símbolos
void mostraTS(PilhaTS * tabela_simbolos){
    ElementoTS * nodo;
    int i;
    nodo = tabela_simbolos->inicio;
    for(i=0;i<tabela_simbolos->tamanho;++i){
        printf("%s ", nodo->var);
        printf("%s ", nodo->tipo);
        printf("%d ", nodo->nivel_lex);
        printf("%d\n", nodo->deslocamento);
        nodo = nodo->proximo;
    }
}

//Percorre e imprime a Pilha de Tipos
void mostraTT(PilhaTT * tabela_tipos){
    ElementoTT *nodo;
    int i;
    nodo = tabela_tipos->inicio;
    for(i=0;i<tabela_tipos->tamanho;++i){
        printf("%s \t", nodo->tipo);
        nodo = nodo->proximo;
    }
}

//Verifica se a variável que está sendo declarada não existe
int verificaVar(PilhaTS * tabela_simbolos, char var[50]){
    ElementoTS * nodo = tabela_simbolos->inicio;
    int tam = tabela_simbolos->tamanho;
    if(tam == 0) return 0;
    while(strcmp(nodo->var, var) != 0) {
        tam--;
        if(tam == 0) return 0;
        nodo = nodo->proximo;
    }
    return 1;
}

//Checa tipo para as expressões
int checaTipo(PilhaTT * tabela_tipos, char tipo_esperado[10]){
    ElementoTT * topo = tabela_tipos->inicio;
    ElementoTT * aux;
    char tipo1[10];
    char tipo2[10];
    strcpy(tipo1, topo->tipo);
    aux = topo;
    topo = topo->proximo;
    tabela_tipos->inicio = topo;
    free(aux);
    tabela_tipos->tamanho--;
    strcpy(tipo2, topo->tipo);
    if((strcmp(tipo1, tipo2) == 0) && (strcmp(tipo2, tipo_esperado) == 0)){
        return 1;
    }
    else  {
        return 0;
    }
    
}

//void main() {
//	PilhaTS * tabela_simbolos = malloc(sizeof(PilhaTS));	
//	PilhaTT * tabela_tipos = malloc(sizeof(PilhaTT));
//    empilhaTT(tabela_tipos, "int");
//    empilhaTT(tabela_tipos, "bol");
//    empilhaTT(tabela_tipos, "char");
//    empilhaTT(tabela_tipos, "bol");
//    mostraTT(tabela_tipos);
//}
