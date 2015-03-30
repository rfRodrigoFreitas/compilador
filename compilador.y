
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "pilha.h"

int num_vars = 0;
int num_vars_total = 0;
int nivel_lexico = 0;
int desloc = 0;
char str[6];
PilhaTS * tabela_simbolos;
PilhaTT * tabela_tipos;
ElementoTS * variavel;
ElementoTS * simb_esq;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token NOT CONJ MAIORIGUAL MENORIGUAL DIFERENTE DO
%token WHILE ELSE THEN IF GOTO OF ARRAY NUMERO
%token TYPE LABEL PROCEDURE FUNCTION DIV IGUAL
%token MULT SUBTRACAO ADICAO MENOR MAIOR DISJ TRUE FALSE


%%

programa:			    { geraCodigo (NULL, "INPP"); }
			     	    PROGRAM IDENT 
			     	    ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
			    	    bloco PONTO 
				        { sprintf(str, "DMEM %d", num_vars_total); geraCodigo (NULL, str);
			     	    geraCodigo (NULL, "PARA");
			     	    mostraTS(tabela_simbolos); 
                        mostraTT(tabela_tipos);
                        printf("###########################################################");
                        }
;

bloco: 				    parte_declara_vars
			      	    comando_composto
;


parte_declara_vars:  	var 
;


var: 				    { } VAR declara_vars
            			|
;

declara_vars: 			declara_vars declara_var 
            			| declara_var 
;

declara_var: 			{ } 
              			lista_id_var DOIS_PONTOS 
              			tipo 
              			{ sprintf(str, "AMEM %d", num_vars); geraCodigo(NULL, str); num_vars = 0; }
              			PONTO_E_VIRGULA
;

tipo: 				    IDENT { empilhaTipoTS(tabela_simbolos, token); }
;

lista_id_var: 			lista_id_var VIRGULA IDENT  
            			{ num_vars++; num_vars_total++;
            			if(verificaVar(tabela_simbolos, token) == 0)
                		    empilhaTS(tabela_simbolos, token, nivel_lexico, desloc, "undefined");
                        else
                            return yyerror("syntax error");
            			desloc++;}
            			| IDENT 
            			{ num_vars++; num_vars_total++; 
            			if(verificaVar(tabela_simbolos, token) == 0)
                		    empilhaTS(tabela_simbolos, token, nivel_lexico, desloc, "undefined");
                        else
                            return yyerror("syntax error");
            			desloc++; }
;

lista_idents: 			lista_idents VIRGULA IDENT  
            			| IDENT 
;


comando_composto: 		T_BEGIN comandos T_END
;

comandos: 			    comandos PONTO_E_VIRGULA comando 
                        | comando
;

comando: 			    comando_composto | comando_sem_rotulo
;

comando_sem_rotulo: 	atribuicao 
;

atribuicao: 			IDENT { simb_esq = buscaTS(tabela_simbolos, token); } ATRIBUICAO expressao { mostraTT(tabela_tipos); empilhaTT(tabela_tipos, simb_esq->tipo); mostraTT(tabela_tipos); sprintf(str, "ARMZ %d,%d", simb_esq->nivel_lex, simb_esq->deslocamento); if(checaTipo(tabela_tipos, simb_esq->tipo)) geraCodigo(NULL, str); else return yyerror("syntax error"); }
;

expressao: 			    expressao_simples MAIOR expressao_simples { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "CMMA"); else return yyerror("syntax error"); } |
         			    expressao_simples MENOR  expressao_simples { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "CMME"); else return yyerror("syntax error"); } | 
        			    expressao_simples MAIORIGUAL  expressao_simples { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "CMAG"); else return yyerror("syntax error"); } |
         			    expressao_simples MENORIGUAL  expressao_simples { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "CMEG"); else return yyerror("syntax error"); } |
         			    expressao_simples IGUAL  expressao_simples { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "CMIG"); else return yyerror("syntax error"); } |
         			    expressao_simples DIFERENTE  expressao_simples { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "CMDG"); else return yyerror("syntax error"); } |
           			    expressao_simples
;

expressao_simples: 		expressao_simples ADICAO termo { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "SOMA"); else return yyerror("syntax error"); } 
            			| expressao_simples SUBTRACAO termo { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo(NULL, "SUBT"); else return yyerror("syntax error"); } 
            			| expressao_simples DISJ termo  { if(checaTipo(tabela_tipos, "boolean") == 1) geraCodigo(NULL, "DISJ"); else return yyerror("syntax error"); }
            			| termo
;

termo:                  fator MULT  fator { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo (NULL, "MULT"); else return yyerror("syntax error"); } 
                        | fator DIV  fator { if(checaTipo(tabela_tipos, "integer") == 1) geraCodigo (NULL, "DIVI"); else return yyerror("syntax error"); } 
                        | fator CONJ  fator { if(checaTipo(tabela_tipos, "boolean") == 1) geraCodigo (NULL, "CONJ"); else return yyerror("syntax error"); }
            			| fator
;

fator: 				    ABRE_PARENTESES expressao FECHA_PARENTESES
            			| IDENT { variavel = buscaTS(tabela_simbolos, token); sprintf(str, "ARMZ %d,%d", variavel->nivel_lex, variavel->deslocamento); geraCodigo(NULL, str); empilhaTT(tabela_tipos, variavel->tipo);} 
            			| NUMERO  { sprintf (str, "CRCT %d", atoi(token)); geraCodigo (NULL, str); empilhaTT(tabela_tipos, "integer"); }
            			| TRUE    { geraCodigo (NULL, "CRCT 1"); empilhaTT(tabela_tipos, "boolean"); }
            			| FALSE   { geraCodigo (NULL, "CRCT 0"); empilhaTT(tabela_tipos, "boolean"); }
;
%%

main (int argc, char** argv) {
    FILE* fp;
    extern FILE* yyin;
    
    if (argc<2 || argc>2) {
        printf("usage compilador <arq>a %d\n", argc);
        return(-1);
    }

    fp=fopen (argv[1], "r");
    if (fp == NULL) {
        printf("usage compilador <arq>b\n");
        return(-1);
    }
    tabela_simbolos = malloc(sizeof(PilhaTS));
    tabela_tipos = malloc(sizeof(PilhaTT));
    iniciarTS(tabela_simbolos);
    iniciarTT(tabela_tipos);
/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */

    yyin=fp;
    yyparse();

    return 0;
}






