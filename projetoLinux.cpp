#include <iostream>

// biblioteca para getchar
#include <termios.h>
#include <unistd.h>
#include <stdio.h>

// biblioteca para clear
#include <stdlib.h>

// biblioteca para armazenamento em arquivos
#include <fstream>

// bibliotecas gerais
#include <string>
#include <vector>



using namespace std;

// estrutura de representacao para nota
struct nota
{
	double peso;
	double nota;
	string nomeNota;
	bool dadoUsavel;
};


// estrutura de representacao de disciplina
struct disciplina
{
	string nome;
	string sala;
	string professor;
	vector<nota> notas;
};

struct compromisso {
	string titulo;
	string detalhe;
	string prioridade;
	string status;
};

// valores padrao para analise de aprovacao|final

// media aprovacao direta
double mediaAprovacaoPadrao = 7.0;

// media aprovacoa em prova final
double mediaAprovacaoFinal = 5.0;

// media para se qualificar para final
double mediaMinimaFinal = 4.0;

// peso da prova final para media da prova final
double valorProvaFinal = 0.4;

// caracteres relacionados ao cursor

// presenca de cursor
string indicador = "->";

// ausencia de cursor
string indicadorVazio = "  ";

// estrutura base de dados de informações relacionadas a disciplinas
vector<disciplina> bancoDados;

vector<compromisso> bancoDadosCompromisso;


// funcao responsavel por ler o movimento do cursor, janelas e acoes do usuario
char getch(){

    termios velho, novo;
    int x;

    tcgetattr( STDIN_FILENO, &velho);
    novo = velho;

    novo.c_lflag &= ~( ICANON | ECHO);
    tcsetattr( STDIN_FILENO,TCSANOW, &novo);

    x = getchar();

    tcsetattr( STDIN_FILENO,TCSANOW, &velho);

    return x;
}

// limpa a estrutura de armazenamento de disciplinas
void limpaBancoDados(){

    ofstream ofs, ofs1;

    // limpando arquivo base de disciplina
    ofs.open("BancoDados/disciplinas.txt", std::ofstream::out | std::ofstream::trunc);

    // informando a quantidade de disciplinas cadastradas
    ofs.close();

    ofs1.open("BancoDados/compromissos.txt", std::ofstream::out | std::ofstream::trunc);

    ofs1.close();
}

void salvaBancoDados(){

    ofstream ofs;

    ofs.open("BancoDados/disciplinas.txt", ofstream::app);

    // inserindo a quantidade de disciplinas a serem cadastradas
    ofs << bancoDados.size() << endl;

    // inserindo informacoes no arquivo de forma ordenada
    for (int i = 0; i < bancoDados.size(); i++){

        // inserindo informacoes basicas de disciplina
        ofs << bancoDados[i].nome << endl;
        ofs << bancoDados[i].sala << endl;
        ofs << bancoDados[i].professor << endl;

        // lendo quantidade de notas a serem cadastradas
        int tam = bancoDados[i].notas.size();

        // inserindo quantidade de notas a serem cadastradas
        ofs << tam << endl;

        // inserindo informacoes de notas
        for (int j = 0; j < tam; j++){

            ofs << bancoDados[i].notas[j].peso << endl;
            ofs << bancoDados[i].notas[j].nota << endl;
            ofs << bancoDados[i].notas[j].nomeNota << endl;
            ofs << bancoDados[i].notas[j].dadoUsavel << endl;
         }
    }

    ofs.close();
}

// carregando dados do arquivo caso exista
void carregaBancoDados(){

    ifstream ifs ("BancoDados/disciplinas.txt");

    // caso arquivo possa ser acessado
    if (ifs.good()){

        int n;
        // lendo numero de disciplinas cadastradas
        ifs >> n;

        // para cada disciplina arquivada
        for (int j = 0; j < n; j++){

            disciplina d;

            ifs.ignore();
            // lendo informacoes basicas disciplinas
            getline(ifs, d.nome);
            getline(ifs, d.sala);
            getline(ifs, d.professor);


            // lendo quantidade de notas da disciplina
            int tam;
            ifs >> tam;

            // para cada nota da disciplina
            for (int i = 0; i < tam; i++){

                nota n;

                // lendo informacoes basicas de nota
                ifs >> n.peso;
                ifs >> n.nota;
                ifs.ignore();
                getline(ifs, n.nomeNota);
                ifs >> n.dadoUsavel;
                d.notas.push_back(n);
            }

            // inserindo disciplina no vector de disciplinas
            bancoDados.push_back(d);
        }
    }
}

void salvaBancoDadosCompromisso(){

    ofstream ofs;

    ofs.open("BancoDados/compromissos.txt", ofstream::app);

    ofs << bancoDadosCompromisso.size() << endl;

    // inserindo informacoes no arquivo de forma ordenada
    for (int i = 0; i < bancoDadosCompromisso.size(); i++){

        ofs << bancoDadosCompromisso[i].titulo << endl;
        ofs << bancoDadosCompromisso[i].detalhe << endl;
        ofs << bancoDadosCompromisso[i].prioridade << endl;
        ofs << bancoDadosCompromisso[i].status << endl;
    }

    ofs.close();
}

// carregando dados do arquivo caso exista
void carregaBancoDadosCompromisso(){

    ifstream ifs ("BancoDados/compromissos.txt");

    // caso arquivo possa ser acessado
    if (ifs.good()){

        int n;
        ifs >> n;

        for (int j = 0; j < n; j++){

            compromisso c;

            ifs.ignore();
            getline(ifs, c.titulo);
            getline(ifs, c.detalhe);
            getline(ifs, c.prioridade);
            getline(ifs, c.status);

            bancoDadosCompromisso.push_back(c);
        }
    }
}

void resetarSistema(){

    limpaBancoDados();
    salvaBancoDados();
    salvaBancoDadosCompromisso();

    vector<disciplina> vd;
    vector<compromisso> vc;

    bancoDados = vd;
    bancoDadosCompromisso = vc;
}

bool confirmaAtoExclusorio(string msg){

    string resposta;
    system("clear");
    cout << "Se voce realmente deseja " << msg << ", então digite (r), caso contrario digite (outra tecla)." << endl;

    cin >> resposta;

    if (resposta == "r"){

        return true;
    }

    return false;
}

// interage com o usuario, para confirmar a parada de execução do codigo
int confirmaFechamento(){

    system("clear");

    char resposta;

    cout << "Digite (s) para encerrar a execucao ou (Outra tecla) para voltar para o menu" << endl;
    cin >> resposta;

    // caso o usuario confirme digitando s envia -1 simbolizando o fim da execução
    if (resposta == 's' || resposta == 'S'){

        system("clear");
        cout << "Ate mais";
        return -1;
    }

    return 1;
}

string limitadorBinarioEscolha(string a, string  b, string msg){

    string resposta;
    getline(cin, resposta);

    while (resposta != a && resposta != b){
        cout << endl;
        cout << "Por favor responda apenas: " << msg;
        getline(cin, resposta);
    }

    return resposta;

}

double confirmacaoLeituraDouble(){

    string str;

    cin >> str;

    bool condicao = true;
    for (int i = 0; i < str.size(); i++){

        if (!isdigit(str[i]) && str[i] != '.'){
            condicao = false;
            break;
        }
    }

    while(!condicao){

        cout << endl;
        cout << "Escreva apenas um numero positivo" << endl;
        cin.ignore();
        cin >> str;

        condicao = true;
        for (int i = 0; i < str.size(); i++){

            if (!isdigit(str[i]) && str[i] != '.'){
                condicao = false;
                break;
            }
        }
    }

    return stod(str);
}

int confirmacaoLeituraInt(){

    string str;

    cin >> str;

    bool condicao = true;
    for (int i = 0; i < str.size(); i++){

        if (!isdigit(str[i])){
            condicao = false;
            break;
        }
    }

    while(!condicao){

        cout << endl;
        cout << "Escreva apenas um numero natural" << endl;
        cin.ignore();
        cin >> str;

        condicao = true;
        for (int i = 0; i < str.size(); i++){

            if (!isdigit(str[i])){
                condicao = false;
                break;
            }
        }
    }

    return stoi(str);
}

string lerString(){

    string resposta;

    cout << endl << "Digite o novo valor" << endl;
    cin.ignore();
    getline(cin, resposta);

    return resposta;
}

// retorna o valor maximo que alguem pode ter na media fazendo final dado sua media padrao
double getNotaMaximaFinal(double media){

    double valorMedia = (1 - valorProvaFinal);

    return (valorMedia*media) + (valorProvaFinal*10);
}

// retorna o valor media que alguem pode ter na media fazendo final dado sua media padrao, sendo aprovado
double getNotaMinimaFinal(double media){

    double valorMedia = (1 - valorProvaFinal);

    return (mediaAprovacaoFinal - (valorMedia*(media)))/valorProvaFinal;
}

// exibe um relatorio para o usuario de sua situacao academica, dado os valores das notas que o usuario pede para serem considerados
void exibeRelatorioNotas(int indice, double somaValoresConsiderados, double somaValoresDesconsiderados,  double pesoConsiderado, double pesoDesconsiderado){

    if (pesoConsiderado + pesoDesconsiderado != 100){

        cout << endl;
        cout << "O relatorio de notas necessita de peso total 100% para ser exibido." << endl;
        return;
    }

    cout << endl;
    cout << "Relatorio de notas:" << endl;
    cout << endl;


    int qtdNotasUsaveis = 0;
    int qtdNotas = bancoDados[indice].notas.size();

    for (int i = 0; i < qtdNotas; i++){

        if (bancoDados[indice].notas[i].dadoUsavel){
            qtdNotasUsaveis++;
        }
    }

    if (qtdNotas == qtdNotasUsaveis){

        double media = somaValoresConsiderados / pesoConsiderado;

        if (media >= mediaAprovacaoPadrao){
            cout << "'Parabens' :D voce esta aprovado" << endl;
        }
        else{

            double nFinal = getNotaMinimaFinal(media);
            if (media < mediaMinimaFinal){

                cout << "VISHI!! :( Voce ja esta 'Reprovado'" << endl;
            }
            else{
                double nFinalMaxima = getNotaMaximaFinal(media);
                cout << "Voce esta na final precisando de: " << nFinal << " para ser aprovado." << endl;
                cout << endl;
                cout << "Podendo ter media maxima de: " << nFinalMaxima << " caso tire 10 na final" << endl;
            }

        }
    }

    else{

        double media = somaValoresConsiderados / (pesoConsiderado + pesoDesconsiderado);
        double maximoFaltante = ((pesoDesconsiderado *10)/(pesoConsiderado+pesoDesconsiderado));

        if (media >= mediaAprovacaoPadrao){
            cout << "'Parabens' :D voce esta aprovado com media: " << media << ",caso voce tire 0 nas proximas notas" << endl;
            cout << "Caso voce tire 100% nas proximas provas, sua media sera: " << media + maximoFaltante << endl;
        }
        else if ((media + maximoFaltante) >= mediaAprovacaoPadrao){
            cout << "Voce ainda nao foi 'aprovado', entretanto voce tem que acumular no minimo: " << mediaAprovacaoPadrao - media << ", para ser aprovado." << endl;
            cout << "Podendo ter no maximo a media de: " << maximoFaltante + media << endl;
        }

        else{

            if (media+maximoFaltante < mediaAprovacaoFinal){

                cout << "VISHI!! :( Voce ja esta 'Reprovado'" << endl;
            }
            else{

                cout << "CUIDADO!! :O Voce ja esta na 'Final'" << endl;
            }
        }

    }
}


// funcao de interacao com o usuario para modificar o valor de um dado da estrutura de nota
double alteraValorNota(){

    double novoValor = 11;

    cout << endl;

    cout << "Por favor digite o novo valor da nota" << endl;

    while(novoValor > 10){
        novoValor = confirmacaoLeituraDouble();

        if (novoValor > 10){

            cout << endl;
            cout << "O valor da nota nao pode ultrapassar 10.0" << endl;
        }
    }

    return novoValor;
}

double alteraValorPeso(){

    double novoValor;

    cout << endl;

    cout << "Por favor digite o novo valor do peso" << endl;

    novoValor = confirmacaoLeituraDouble();

    return novoValor;
}

// exibe a s informacoes de uma disciplina identificada por seu indice e permite a manipulacao de suas notas
int manipularDisciplina(int indice){

    // tecla pressionada pelo usuario
    char keyPressed;

    // lista representando os opcoes verticais que o cursor pode acessar, armazena o cursor ou sua ausencia
    vector<string> lista;

    // indica a posicao que o cursor ocupa na lista
    int posIndicador = 0;

    // inicializa as opcoes
    if (bancoDados[indice].notas.size() != 0){
        lista.push_back(indicador);
    }
    for (int i = 1; i < bancoDados[indice].notas.size(); i++){

        lista.push_back(indicadorVazio);
    }

    // lista representando as opcoes verticais que se pode acessar, indica em qual coluna esta
    string coluna[4];

    // indica a posicao em que a lista oucupa horizontalmente
    int posX = 0;

    // enquanto o usuario n desejar a janela sera exibida
    while(1){
        system("clear");


        cout << endl << "|| Aperte (a) ou (d) para mover o cursor horizontalmente ||" << endl;
        cout << "|| Aperte (w) ou (s) para mover o cursor verticalmente ||" << endl;
        cout << "|| Aperte (g) para mudar o valor do atributo de nota ||" << endl;
        cout << "|| (Usar dado) indica se o codigo deve ou nao analisar a nota no relatorio (1)->sim (0)->nao, alterna-se com (g)!! ||" << endl << endl;

        // exibe dados disciplina
        cout << "Disciplina: " << bancoDados[indice].nome << endl;
        cout << "Sala: " << bancoDados[indice].sala <<  " | Professor: " << bancoDados[indice].professor << endl;

        cout << "Avaliacao - nota - peso -|- Usar dado:" << endl;
        cout << endl;

        // dados estatisticos
        // soma doa valores a serem considerados no calculo de situacao
        double somaValoresConsiderados = 0;
        // soma dos valores desconsiderados
        double somaValoresDesconsiderados = 0;
        // peso na nota dos valores considerados no calculo de situacao
        double pesoConsiderado = 0;
        // peso na nota dos valores desconsiderados
        double pesoDesconsiderado = 0;

        // para cada nota exibe sua representacao e acumular dados estatisticos
        for (int i = 0; i < bancoDados[indice].notas.size(); i++){

            if (bancoDados[indice].notas[i].dadoUsavel){

                somaValoresConsiderados += (bancoDados[indice].notas[i].nota*bancoDados[indice].notas[i].peso);
                pesoConsiderado += bancoDados[indice].notas[i].peso;
            }
            else{

                somaValoresDesconsiderados += (bancoDados[indice].notas[i].nota*bancoDados[indice].notas[i].peso);
                pesoDesconsiderado += bancoDados[indice].notas[i].peso;
            }

            cout.precision(4);

            coluna[posX] = lista[i];
            cout << coluna[0] << bancoDados[indice].notas[i].nomeNota << " - " <<
            coluna[1] << bancoDados[indice].notas[i].nota << " - " <<
            coluna[2] << bancoDados[indice].notas[i].peso << " % -|- " <<
            coluna[3] << bancoDados[indice].notas[i].dadoUsavel << endl;
            coluna[posX] = "";
        }

        cout << endl;
        double media = (somaValoresConsiderados + somaValoresDesconsiderados) / (pesoConsiderado + pesoDesconsiderado);

        cout << "Media Acumulada: " << media << endl;

        exibeRelatorioNotas(indice, somaValoresConsiderados, somaValoresDesconsiderados, pesoConsiderado, pesoDesconsiderado);

        keyPressed = getch();

        if (int(keyPressed) == int('s') && bancoDados[indice].notas.size() != 0)
		{
			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % bancoDados[indice].notas.size();
			lista[posIndicador] = indicador;
		}

        if (int(keyPressed) == int('w') && bancoDados[indice].notas.size() != 0)
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('a'))
		{
            if(posX == 0){
                return 1;
            }

            posX -= 1;
		}

		if (int(keyPressed) == int('d') && bancoDados[indice].notas.size() != 0){

            posX = (posX + 1) % 4;
		}

		if (int(keyPressed) == int('g')){

            if (posX == 0){
                bancoDados[indice].notas[posIndicador].nomeNota = lerString();
            }
            if (posX == 1){
                bancoDados[indice].notas[posIndicador].nota = alteraValorNota();
            }
            if (posX == 2){
                bancoDados[indice].notas[posIndicador].peso = alteraValorPeso();
            }
            if (posX == 3){
                bancoDados[indice].notas[posIndicador].dadoUsavel = !bancoDados[indice].notas[posIndicador].dadoUsavel;
            }
		}
    }
}

// remove uma disciplina identificada pelo indice das disciplinas cadastradas
int excluiDisciplina(int a){

	bancoDados.erase(bancoDados.begin()+a);

	return 1;
}

int atualizaDisciplina(int indice){

    char keyPressed;
	vector<string> lista;
	int posIndicador = 0;

	lista.push_back(indicador);

	for(int i = 1; i < 4; i++) {
		lista.push_back(indicadorVazio);
	}

	while(1) {
		system("clear");

		cout << endl << "|| Aperte (d) para escolher qual atributo modificar ||" << endl;
		cout << "| Selecione um campo para altera-lo |" << endl;
		cout << endl;
		cout << lista[0] << " Nome    : " << bancoDados[indice].nome << endl;
		cout << lista[1] << " Professor   : " << bancoDados[indice].professor <<  endl;
		cout << lista[2] << " Sala: " << bancoDados[indice].sala << endl;
		cout << lista[3] << " Quantidade de Notas    : " << bancoDados[indice].notas.size() << endl;


		keyPressed = getch();

		if (int(keyPressed) == int('s')) {
			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % 4;
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('w'))
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('a')) {
			return 1;
		}

		if (int(keyPressed) == int('d')) {

			if (posIndicador == 0) {
				bancoDados[indice].nome = lerString();
			}
			if (posIndicador == 1) {
				bancoDados[indice].professor = lerString();
			}
			if (posIndicador == 2) {
				bancoDados[indice].sala= lerString();
            }
			if (posIndicador == 3) {

                cout << endl << "Informe o numero de disciplinas" << endl;
				int n = confirmacaoLeituraInt();

				if (n > bancoDados[indice].notas.size()){

                    nota a;
                    a.dadoUsavel = 0;
                    a.nota = 0;
                    a.peso = 0;
                    a.nomeNota = "Nº Nota";
                    for (int i = bancoDados[indice].notas.size(); i < n; i++){

                        bancoDados[indice].notas.push_back(a);
                    }
				}
				if (n < bancoDados[indice].notas.size()){

                    for (int i = bancoDados[indice].notas.size()-1; i >= n; i--){

                        bancoDados[indice].notas.erase(bancoDados[indice].notas.begin()+i);
                    }
				}
			}

		}
	}

}

int exibeDisciplinas(char parametro)
{

	char keyPressed;

	vector<string> lista;
	int posIndicador;

	for (int i = 0; i < bancoDados.size(); i++)
	{
		lista.push_back(indicadorVazio);
	}

    if (lista.size() != 0){

        lista[0] = indicador;
        posIndicador = 0;
    }

	while(1)
	{
		system("clear");
		cout << endl << "|| Aperte (d) para escolher qual disciplina";
		if (parametro == 'a'){
            cout << " editar ||" << endl;
		}

		if (parametro == 'n'){
            cout << " acessar ||" << endl;
		}

		if (parametro == 'e'){
            cout << " excluir ||" << endl;
		}

		if (bancoDados.size() == 0)
		{
			cout << "Nenhuma disciplina cadastrada";
		}
		if (bancoDados.size() != 0)
		{

			for (int i = 0; i < bancoDados.size(); i++)
			{

				cout << lista[i] << bancoDados[i].nome << endl;
			}
		}

		keyPressed = getch();

		if (int(keyPressed) == int('s') && lista.size() != 0)
		{

			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % lista.size();
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('w') && lista.size() != 0)
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('a'))
		{
			return 1;
		}

		if (parametro == 'e' && lista.size() != 0){
			if (int(keyPressed) == int('r')){

        	    if(confirmaAtoExclusorio("deletar esta disciplina")){
                    excluiDisciplina(posIndicador);
        	    }

			}
		}
		if (parametro == 'n' && lista.size() != 0){
			if (int(keyPressed) == int('d')){

                manipularDisciplina(posIndicador);
			}
		}

		if (parametro == 'a' && lista.size() != 0){
			if (int(keyPressed) == int('d')){

                atualizaDisciplina(posIndicador);
			}
		}
	}

}

vector<nota> cadastraNota(){

    vector<nota> notas;

	string resposta;

    cout <<  endl << "Deseja sistema de notas padrão? (sim/nao) ";


    resposta = limitadorBinarioEscolha("sim", "nao", "(sim/nao)");


	if (resposta == "sim" || resposta == "SIM"){

		nota nota;

		nota.nomeNota = "1º Nota:";
		nota.nota = 0;
		nota.peso = 100.0/3.0;
		nota.dadoUsavel = false;
		notas.push_back(nota);

		nota.nomeNota = "2º Nota:";
		notas.push_back(nota);

		nota.nomeNota = "3º Nota:";
		notas.push_back(nota);
	}
	else{

		int numNotas;
		string newNota;
		double pesoNota;
		nota novaNota;

		cout << endl << "Qual o numero de notas: \n";
		numNotas = confirmacaoLeituraInt();

		for (int i = 0; i < numNotas; i++)
		{
			cout << endl << "Qual o nome da Nota " << i+1 << ": " << endl;

			cin.ignore();
			getline(cin, newNota);

			cout << endl << "Qual o peso da Nota " << i+1 << ": " << endl;
			pesoNota = confirmacaoLeituraDouble();

			novaNota.nomeNota = newNota;
			novaNota.peso = pesoNota;
			novaNota.nota = 0;
			novaNota.dadoUsavel = false;

			notas.push_back(novaNota);
		}

	}

	return notas;
}

void cadastraDisciplina(){

	string nomeDisciplina;
	string professor;
	string sala;

	disciplina newDisciplina;

	cout << endl << "Digite o nome da disciplina: " << endl;
	getline(cin, nomeDisciplina);
	newDisciplina.nome = nomeDisciplina;

	cout << endl << "Digite o nome do professor: " << endl;
	getline(cin, professor);
	newDisciplina.professor = professor;

	cout << endl << "Digite o nome da sala: " << endl;
	getline(cin, sala);
	newDisciplina.sala = sala;

	newDisciplina.notas = cadastraNota();
	bancoDados.push_back(newDisciplina);


}


void cadastraCompromisso() {

	system("clear");

	compromisso novoCompromisso;

	cout << "Digite o titulo: ";
	cin.ignore();
  	getline(cin, novoCompromisso.titulo);

	cout << "Digite a descrição: ";
  	cin.ignore();
  	getline(cin, novoCompromisso.detalhe);

	cout << "Digite oa prioridade: ";
  	cin.ignore();
  	getline(cin, novoCompromisso.prioridade);

  	novoCompromisso.status = "Em andamento";

	bancoDadosCompromisso.push_back(novoCompromisso);

}

string editaInfoComp(string valor) {
	string novoValor;

	cout << endl << endl << "|| Por favor digite o novo valor: ";
	getline(cin, novoValor);

	if (novoValor != "=") {
		return novoValor;
	} else {
		return valor;
	}
}

int manipularCompromisso(int indice) {
	char keyPressed;
	vector<string> lista;
	int posIndicador = 0;

	lista.push_back(indicador);

	for(int i = 1; i < 5; i++) {
		lista.push_back(indicadorVazio);
	}

	while(1) {
		system("clear");

        cout << endl << "|| Aperte (d) para alterar os campos ou para excluir o compromisso||" << endl ;
		cout << "| Selecione um campo para altera-lo |" << endl;
		cout << "|Digite \"=\" para cacelar a alteracao|" << endl;
		cout << endl;
		cout << lista[0] << " Titulo    : " << bancoDadosCompromisso[indice].titulo << endl;
		cout << lista[1] << " Detalhe   : " << bancoDadosCompromisso[indice].detalhe <<  endl;
		cout << lista[2] << " Prioridade: " << bancoDadosCompromisso[indice].prioridade << endl;
		cout << lista[3] << " Status    : " << bancoDadosCompromisso[indice].status << endl;
		cout << endl;
		cout << lista[4] << " REMOVER COMPROMISSO";

		keyPressed = getch();

		if (int(keyPressed) == int('s')) {
			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % 5;
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('w'))
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('a')) {
			return 1;
		}

		if (int(keyPressed) == int('d')) {

			if (posIndicador == 0) {
				bancoDadosCompromisso[indice].titulo = editaInfoComp(bancoDadosCompromisso[indice].titulo);
			}
			if (posIndicador == 1) {
				bancoDadosCompromisso[indice].detalhe = editaInfoComp(bancoDadosCompromisso[indice].detalhe);
			}
			if (posIndicador == 2) {
				bancoDadosCompromisso[indice].prioridade = editaInfoComp(bancoDadosCompromisso[indice].prioridade);
			}
			if (posIndicador == 3) {
				bancoDadosCompromisso[indice].status = editaInfoComp(bancoDadosCompromisso[indice].status);
			}
			if (posIndicador == 4) {
                if (confirmaAtoExclusorio("excluir este compromisso")){
                    bancoDadosCompromisso.erase(bancoDadosCompromisso.begin()+indice);
                    return 1;
                }
			}

		}
	}
}

int exibeCompromissos() {

	char keyPressed;

	vector<string> lista;
	int posIndicador = 0;

	lista.push_back(indicador);

	for (int i = 0; i < bancoDadosCompromisso.size(); i++) {
		lista.push_back(indicadorVazio);
	}

	while(1) {

		system("clear");

        cout << endl << "|| Aperte (d) para criar compromissos, ou acessa-los ||" << endl;


		if (bancoDadosCompromisso.size() == 0) {
			cout << "Nenhum compromisso cadastrado!" << endl;
			cout << endl;
        }

        cout << lista[0] << " CADASTRAR COMPROMISSO" << endl << endl;

        for (int i = 0; i < bancoDadosCompromisso.size(); i++) {

            cout << lista[i+1] << " Titulo    : " << bancoDadosCompromisso[i].titulo << endl;
            cout << indicadorVazio << " Status    : " << bancoDadosCompromisso[i].status << endl;
            cout << endl;

        }

        keyPressed = getch();

        if (int(keyPressed) == int('s') && bancoDadosCompromisso.size() != 0) {
            lista[posIndicador] = indicadorVazio;
            posIndicador = (posIndicador + 1) % (bancoDadosCompromisso.size()+1);
            lista[posIndicador] = indicador;
        }

        if (int(keyPressed) == int('w') && bancoDadosCompromisso.size() != 0)
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}


        if (int(keyPressed) == int('a')) {
            return 1;
        }

        if (int(keyPressed) == int('d')) {
            if (posIndicador == 0) {
                cadastraCompromisso();
                lista.push_back(indicadorVazio);
            } else {
                manipularCompromisso(posIndicador-1);
            }
        }

	}
}

int exibeConfiguracoes()
{

	cout << "configuracoes" << endl;

	char keyPressed;


	vector<string> lista;
	int posIndicador = 0;

	lista.push_back(indicador);
	int i = 0;

	for(i = 1; i < 4; i ++)
	{
		lista.push_back(indicadorVazio);
	}

	while(1){

		system("clear");
        cout << endl << "|| Aperte (d) para acessar as opcoes ||" << endl;
        cout << lista[0] << "Cadastrar disciplina" << endl;
		cout << lista[1] << "Atualizar disciplina" << endl;
		cout << lista[2] << "Remover disciplina" << endl;
		cout << lista[3] << "Reset" << endl;

		keyPressed = getch();

		if(int(keyPressed) == int('s'))
		{
			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % 4;
			lista[posIndicador] = indicador;
		}

		else if (int(keyPressed) == int('w'))
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}

		else if(int(keyPressed) == int('d'))
		{
			if (posIndicador == 0){
				cadastraDisciplina();
			}

			else if (posIndicador == 1){
				exibeDisciplinas('a');
			}

			else if (posIndicador == 2){
				exibeDisciplinas('e');
			}

			else if (posIndicador == 3){

                if (confirmaAtoExclusorio("resetar os dados do sistema")){
                    resetarSistema();
                    return 1;
                }
			}
		}
		else if(int(keyPressed) == int('a')){

			return 1;
		}

	}
}

int exibeTutorialGeral()
{

    char keyPressed;

	vector<string> lista;

	int posIndicador;

	lista.push_back(indicadorVazio);

    if (lista.size() != 0){

        lista[0] = indicador;
        posIndicador = 0;
    }

	while(1)
	{
		system("clear");
		cout << "Tutorial Geral do App de Gerenciamento: " << endl << endl;
		cout << "Para se Locomover no aplicativo utilize as teclas {W,A,S,D}" << endl;
		cout << "-----------------------------------------------------------" << endl;
		cout << "W - Faz com que o curso se mova para cima" << endl;
		cout << "A - Volta para a pagina anterior"<<endl;
		cout << "S - Faz com que o curso se mova para baixo" << endl;
		cout << "D - Passa para a proxima Pagina" << endl;
		cout << "-----------------------------------------------------------" << endl << endl;
		cout << "Disciplina: " << endl;
		cout << "-----------------------------------------------------------" << endl;
		cout << "Ao acessar a pagina Disciplina você será direcionado para o local onde\nficará amazenado todas as suas Disciplinas e para acessá-las basta com as\nteclas selecionadas escolher qual Disciplina você deseja vizualizar e clicar 'D',\ndentro da disciplina selecionada você pode cadastrar as notas e o programa lhe\ndirar sua situcação na disciplina." << endl;
		cout << "-----------------------------------------------------------" << endl<<endl;
		cout << "Configurações: " << endl;
		cout << "-----------------------------------------------------------" << endl;
		cout << "Ao acessar a pagina de Configuraçoes, você será direcionado para 4 opções\nde configuraçoes onde podera cadastrar, atualizar ou remover a disciplina\n\nCadastrar Disciplina: Ao selecionar a opção de castrar disciplina\nserá peguntados informações basicas sobre a disciplina.\n\nAtualizar Disciplina: Caso deseja que a disciplina já cadastrada mude alguma\ninformação basta atualizala\n\nRemover Disciplina: Remove uma Disciplina já cadastrada\n\nReset: Irá resetar todo o programa."<<endl;
		cout << "-----------------------------------------------------------" << endl << endl;
		cout << "Então você já estar preparado para se organizar durante seu período?\nEntão vamos lá, basta apenas clicar 'A' para voltar a pagina inicial e cadastrar suas disciplinas." << endl;
		keyPressed = getch();

		if (int(keyPressed) == int('a'))
		{
			return 1;
		}

	}

}

void run()
{

	char keyPressed;

	vector<string> lista;
	int posIndicador = 0;

	lista.push_back(indicador);
	lista.push_back(indicadorVazio);
	lista.push_back(indicadorVazio);
	lista.push_back(indicadorVazio);


	while (1)
	{

        system("clear");

        cout << endl << "|| Aperte (d) para entrar nas opcoes ||" << endl;
		cout << lista[0] << " Disciplinas" << endl;
		cout << lista[1] << " Compromissos" << endl;
		cout << lista[2] << " Configuracoes" << endl;
        cout << lista[3] << " Tutorial" << endl;


		keyPressed = getch();

		if (int(keyPressed) == int('s'))
		{

			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % lista.size();
			lista[posIndicador] = indicador;
		}

		else if (int(keyPressed) == int('w'))
		{

			lista[posIndicador] = indicadorVazio;

			posIndicador = (posIndicador - 1);

			if (posIndicador < 0){

                posIndicador = lista.size()-1;
			}
			lista[posIndicador] = indicador;
		}

		else if (int(keyPressed) == int('d'))
		{

			if (posIndicador == 0)
			{

				exibeDisciplinas('n');
			}

			if (posIndicador == 1) {

				exibeCompromissos();
			}

			if (posIndicador == 2) {

				exibeConfiguracoes();
			}
			if (posIndicador == 3) {

				exibeTutorialGeral();
			}
		}

		else if (int(keyPressed) == int('a'))
		{
            if (confirmaFechamento() == -1){
                return;
            }
		}
	}
}

int main()
{
    carregaBancoDadosCompromisso();
    carregaBancoDados();
	run();
	limpaBancoDados();
	salvaBancoDados();
	salvaBancoDadosCompromisso();
	return 1;
}


