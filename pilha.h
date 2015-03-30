typedef struct Variavel{
    char var[50];
    int nivel_lex;
    int deslocamento;
    char tipo[10];
    struct Variavel* proximo;
}ElementoTS;

typedef struct VariavelHeader {
    ElementoTS * inicio;
    int tamanho;
}PilhaTS;

typedef struct TipoVariavel{
    char tipo[10];
    struct TipoVariavel * proximo;
}ElementoTT;

typedef struct TipoVariavelHeader {
    ElementoTT * inicio;
    int tamanho;
}PilhaTT;

void iniciarTS (PilhaTS * tabela_simbolos);
void iniciarTT (PilhaTT * tabela_tipos);
void mostraTS (PilhaTS * tabela_simbolos);
void mostraTT (PilhaTT * tabela_tipos);
void empilhaTS (PilhaTS * tabela_simbolos, char var[50], int nivel_lex, int deslocamento, char tipo[10]);
void empilhaTipoTS(PilhaTS * tabela_simbolos, char tipo[10]);
void empilhaTT (PilhaTT * tabela_tipos, char tipo[10]);
int verificaVar(PilhaTS * tabela_simbolos, char var[50]);
ElementoTS * buscaTS (PilhaTS * tabela_simbolos, char var[10]);


