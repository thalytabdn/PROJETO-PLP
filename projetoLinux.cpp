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

    ofstream ofs;

    // limpando arquivo base de disciplina
    ofs.open("BancoDados/disciplinas.txt", std::ofstream::out | std::ofstream::trunc);

    // informando a quantidade de disciplinas cadastradas
    ofs << 0;
    ofs.close();
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

            // lendo informacoes basicas disciplinas
            ifs >> d.nome;
            ifs >> d.sala;
            ifs >> d.professor;

            // lendo quantidade de notas da disciplina
            int tam;
            ifs >> tam;

            // para cada nota da disciplina
            for (int i = 0; i < tam; i++){

                nota n;

                // lendo informacoes basicas de nota
                ifs >> n.peso;
                ifs >> n.nota;
                ifs >> n.nomeNota;
                ifs >> n.dadoUsavel;
                d.notas.push_back(n);
            }

            // inserindo disciplina no vector de disciplinas
            bancoDados.push_back(d);
        }
    }
}

// funcao de interacao com o usuario para modificar o valor de um dado da estrutura de nota
double alteraValor(){

    double novoValor;

    cout << endl;
    cout << "Por favor digite o novo valor" << endl;
    cin >> novoValor;

    return novoValor;
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
            cout << "Voce ja esta aprovado" << endl;
        }
        else{

            double nFinal = getNotaMinimaFinal(media);
            if (media < mediaMinimaFinal){

                cout << "Voce ja esta reprovado" << endl;
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

// interage com o usuario, para confirmar a parada de execução do codigo
int confirmaFechamento(){

    system("clear");

    char resposta;

    cout << "Digite (s) para encerrar a execucao ou (w) para voltar para o menu" << endl;
    cin >> resposta;

    // caso o usuario confirme digitando s envia -1 simbolizando o fim da execução
    if (resposta == 's' || resposta == 'S'){

        system("clear");
        cout << "Ate mais";
        return -1;
    }else{
		return 1;
	}

    return 1;
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

        if (int(keyPressed) == int('s'))
		{
			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % bancoDados[indice].notas.size();
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

		if (int(keyPressed) == int('a'))
		{
            if(posX == 0){
                return 1;
            }

            posX -= 1;
		}

		if (int(keyPressed) == int('d')){

            posX = (posX + 1) % 4;
		}

		if (int(keyPressed) == int('g') && posX != 0){

            if (posX == 1){
                bancoDados[indice].notas[posIndicador].nota = alteraValor();
            }
            if (posX == 2){
                bancoDados[indice].notas[posIndicador].peso = alteraValor();
            }
            if (posX == 3){
                bancoDados[indice].notas[posIndicador].dadoUsavel = !bancoDados[indice].notas[posIndicador].dadoUsavel;
            }
		}
    }
}

int excluiDisciplina(int a){

	bancoDados.erase(bancoDados.begin()+a);

	return 1;
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

        	    if (excluiDisciplina(posIndicador) == -1){
            	    return -1;
            	}
			}
		}
		if (parametro == 'n' && lista.size() != 0){
			if (int(keyPressed) == int('d')){

        	    if (manipularDisciplina(posIndicador) == -1){
            	    return -1;
            	}
			}
		}
	}

}

vector<nota> cadastraNota(){
	vector<nota> notas;
	string resposta;
	cout << "\nDeseja sistema de notas padrão? (Y/n) \n";
	getline(cin, resposta);
	if(resposta == "y" || resposta == "Y"){
		nota nota1;
		nota1.nomeNota = "\nPrimeira Nota: ";
		nota1.nota = 0;
		nota1.peso = 1.0/3.0;
		nota1.dadoUsavel = false;
		notas.push_back(nota1);
		nota1.nomeNota = "\nSegunda Nota: ";
		notas.push_back(nota1);
		nota1.nomeNota = "\nTerceira Nota: ";
		notas.push_back(nota1);
	}else{
		int numNotas;
		string newNota;
		double pesoNota;
		nota novaNota;
		cout << "\nQual o numero de notas que vc deseja cadastrar: \n";
		cin >> numNotas;

		for (int i = 0; i < numNotas; i++)
		{
			cout << "\nQual o nome da Nota " << i+1 << ": " << endl;

			cin.ignore();
			getline(cin, newNota);

			cout << "\nQual o peso da Nota " << i+1 << ": " << endl;
			cin >> pesoNota;
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

	cout << "\nDigite o nome da disciplina: \n";
	getline(cin, nomeDisciplina);
	newDisciplina.nome = nomeDisciplina;

	cout << "\nDigite o nome do professor: \n";
	getline(cin, professor);
	newDisciplina.professor = professor;

	cout << "\nDigite o numero da sala: \n";
	getline(cin, sala);
	newDisciplina.sala = sala;

	newDisciplina.notas = cadastraNota();
	bancoDados.push_back(newDisciplina);


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

			else if (posIndicador == 2){
				exibeDisciplinas('e');
			}
			return 1;
		}
		else if(int(keyPressed) == int('a')){

			return 1;
		}

	}
}

int exibeTutorial()
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
		cout << "Tutorial do App de Gerenciamento: " << endl << endl;
		cout << "Para se Locomover no aplicativo utilize as teclas {W,A,S,D}" << endl;
		cout << "-----------------------------------------------------------" << endl;
		cout << "W - Faz com que o curso se mova para cima" << endl;
		cout << "A - Volta para a pagina anterio"<<endl;
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

	while (1)
	{
        system("clear");
		cout << lista[0] << " Disciplinas" << endl;
		cout << lista[1] << " Configuracoes" << endl;
		cout << lista[2] << " Tutorial" << endl;
		
		keyPressed = getch();
		cout << keyPressed << endl;
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
				if (exibeDisciplinas('n') == -1)
				{
					return;
				}
			}
			else if (posIndicador == 1)
			{
				if (exibeConfiguracoes() == -1)
				{
					return;
				}
			}else{
				if(exibeTutorial() == -1){
					return;
				}	
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
    carregaBancoDados();
	run();
	limpaBancoDados();
	salvaBancoDados();
	return 1;
}


