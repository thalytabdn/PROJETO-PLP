#include <iostream>

#include <termios.h>
#include <unistd.h>
#include <stdio.h>

#include <stdlib.h>
#include <string>
#include <vector>


using namespace std;


struct nota
{
	double peso;
	double nota;
	string nomeNota;
	bool dadoUsavel;
};


struct disciplina
{
	vector<nota> notas;
	string nome;
	string sala;
	string professor;
};

double mediaAprovacaoPadrao = 7.0;
double mediaAprovacaoFinal = 5.0;
double mediaMinimaFinal = 4.0;
double valorProvaFinal = 0.4;

string indicador = "->";
string indicadorVazio = "  ";

vector<disciplina> bancoDados;

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

double alteraValor(){

    double novoValor;
    cout << endl;
    cout << "Por favor digite o novo valor" << endl;
    cin >> novoValor;

    return novoValor;
}

double getNotaMaximaFinal(double media){

    double valorMedia = (1 - valorProvaFinal);

    return (valorMedia*media) + (valorProvaFinal*10);
}

double getNotaMinimaFinal(double media){

    double valorMedia = (1 - valorProvaFinal);

    return (mediaAprovacaoFinal - (valorMedia*(media)))/valorProvaFinal;
}

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
            cout << "Parabens voce esta aprovado com media: " << media << ",caso voce tire 0 nas proximas notas" << endl;
            cout << "Caso voce tire 100% nas proximas provas, sua media sera: " << media + maximoFaltante << endl;
        }
        else if ((media + maximoFaltante) >= mediaAprovacaoPadrao){
            cout << "Voce ainda nao foi aprovado, entretanto voce tem que acumular no minimo: " << mediaAprovacaoPadrao - media << ", para ser aprovado." << endl;
            cout << "Podendo ter no maximo a media de: " << maximoFaltante + media << endl;
        }

        else{

            if (media+maximoFaltante < mediaAprovacaoFinal){

                cout << "Voce ja esta reprovado" << endl;
            }
            else{

                cout << "Voce ja esta na final" << endl;
            }
        }

    }
}

int confirmaFechamento(){

    system("clear");

    char resposta;

    cout << "Digite (s) para encerrar a execucao" << endl;
    cin >> resposta;

    if (resposta == 's'){

        system("clear");
        cout << "Ate mais";
        return -1;
    }

    return 1;
}

int manipularDisciplina(int indice){

    char keyPressed;
    vector<string> lista;
    int posIndicador = 0;

    lista.push_back(indicador);
    for (int i = 1; i < bancoDados[indice].notas.size(); i++){

        lista.push_back(indicadorVazio);
    }

    string coluna[4];
    int posX = 0;


    while(1){
        system("clear");


        cout << "Disciplina: " << bancoDados[indice].nome << endl;
        cout << "Sala: " << bancoDados[indice].sala <<  " | Professor: " << bancoDados[indice].professor << endl;

        cout << "Avaliacao - nota - peso -|- Usar dado:" << endl;
        cout << endl;

        double somaValoresConsiderados = 0;
        double somaValoresDesconsiderados = 0;
        double pesoConsiderado = 0;
        double pesoDesconsiderado = 0;

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

	lista[0] = indicador;
	posIndicador = 0;

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

		if (int(keyPressed) == int('s'))
		{

			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % lista.size();
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
			return 1;
		}
		
		if (parametro == 'e'){
			if (int(keyPressed) == int('r')){

        	    if (excluiDisciplina(posIndicador) == -1){
            	    return -1;
            	}
			}
		}
		if (parametro == 'n'){
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
	cout << "Deseja sistema de notas padrão? (Y/n) ";
	getline(cin, resposta);
	if(resposta == "y" || resposta == "Y"){
		nota nota1;
		nota1.nomeNota = "Primeira Nota: ";
		nota1.nota = 0;
		nota1.peso = 1.0/3.0;
		nota1.dadoUsavel = false;
		notas.push_back(nota1);
		nota1.nomeNota = "Segunda Nota: ";
		notas.push_back(nota1);
		nota1.nomeNota = "Terceira Nota: ";
		notas.push_back(nota1);
	}else{
		int numNotas;
		string newNota;
		double pesoNota;
		nota novaNota;
		cout << "Qual o numero de notas: \n";
		cin >> numNotas;
		
		for (int i = 0; i < numNotas; i++)
		{
			cout << "Qual o nome da Nota " << i+1 << ": " << endl;
			
			cin.ignore();
			getline(cin, newNota);
			
			cout << "Qual o peso da Nota " << i+1 << ": " << endl;
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

	cout << "Digite o nome da disciplina: \n";
	getline(cin, nomeDisciplina);
	newDisciplina.nome = nomeDisciplina;

	cout << "Digite o nome do professor: \n";
	getline(cin, professor);
	newDisciplina.professor = professor;
	
	cout << "Digite o nome da sala: \n";
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

void run()
{

	char keyPressed;
	vector<string> lista;
	int posIndicador = 0;
	lista.push_back(indicador);
	lista.push_back(indicadorVazio);


	while (1)
	{
        system("clear");
		cout << lista[0] << " Disciplinas" << endl;
		cout << lista[1] << " Configuracoes" << endl;

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
			else
			{
				if (exibeConfiguracoes() == -1)
				{
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

	disciplina dis;
	dis.nome = "ahahah";
	dis.professor = "ffff";
	dis.sala = "hell";

	nota n;
	n.nomeNota = "oal";
	n.nota = 7;
	n.peso = 25;
	n.dadoUsavel = false;

	dis.notas.push_back(n);
    dis.notas.push_back(n);
    dis.notas.push_back(n);
    dis.notas.push_back(n);

	bancoDados.push_back(dis);
	bancoDados.push_back(dis);

	run();
	return 1;
}

