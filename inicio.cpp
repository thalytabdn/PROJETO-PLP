#include <iostream>
#include <conio.h>
#include <stdlib.h>
#include <string>
#include <vector>

using namespace std;


struct nota
{

	double peso;
	double nota;
	string nomeNota;
};


struct disciplina
{
    int qtdNotasCadastradas;
	vector<nota> notas;
	string nome;
	string sala;
	string professor;
};

string indicador = "->";
string indicadorVazio = "  ";

vector<disciplina> bancoDados;

double alteraValor(){

    double novoValor;
    cout << endl;
    cout << "Por favor digite o novo valor" << endl;
    cin >> novoValor;

    return novoValor;
}

int manipularDisciplina(int indice){

    char keyPressed;
    vector<string> lista;
    int posIndicador = 0;

    lista.push_back(indicador);
    for (int i = 1; i < bancoDados[indice].notas.size(); i++){

        lista.push_back(indicadorVazio);
    }

    string coluna[3];
    int posX = 0;


    while(1){
        system("CLS");


        cout << "Disciplina: " << bancoDados[indice].nome << endl;
        cout << "Sala: " << bancoDados[indice].sala <<  " | Professor: " << bancoDados[indice].professor << endl;
        cout << endl;
        cout << "Relatorio de notas:" << endl;
        if (bancoDados[indice].qtdNotasCadastradas == 0){
            cout << "Ainda nao posssui notas cadastradas, por favor cadastre abaixo ^-^" << endl;
        }

        cout << endl;
        cout << "Avaliacao - nota - peso:" << endl;
        cout << endl;

        double media = 0;
        double pesoTotal = 0;
        for (int i = 0; i < bancoDados[indice].notas.size(); i++){

            media = media + (bancoDados[indice].notas[i].nota*bancoDados[indice].notas[i].peso);
            pesoTotal = pesoTotal + bancoDados[indice].notas[i].peso;

            coluna[posX] = lista[i];
            cout << coluna[0] << bancoDados[indice].notas[i].nomeNota << " - " <<
            coluna[1] << bancoDados[indice].notas[i].nota << " - " << coluna[2] << bancoDados[indice].notas[i].peso <<endl;
            coluna[posX] = "";
        }

        cout << endl;
        media = media /pesoTotal;

        cout << "Media Acumulada: " << media << endl;

        keyPressed = getch();

        if (int(keyPressed) == int('s'))
		{
			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % bancoDados[indice].notas.size();
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('a'))
		{
			return 1;
		}

		if (int(keyPressed) == int('d')){

            posX = (posX + 1) % 3;
		}

		if (int(keyPressed) == int('g') && posX != 0){

            if (posX == 1){
                bancoDados[indice].notas[posIndicador].nota = alteraValor();
            }
            if (posX == 2){
                bancoDados[indice].notas[posIndicador].peso = alteraValor();
            }
		}
    }
}

int exibeDisciplinas()
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

		system("CLS");
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
			posIndicador = (posIndicador + 1) % 2;
			lista[posIndicador] = indicador;
		}

		if (int(keyPressed) == int('a'))
		{
			return 1;
		}

		if (int(keyPressed) == int('d')){

            if (manipularDisciplina(posIndicador) == -1){
                return -1;
            }
		}
	}
}


int exibeConfiguracoes()
{

	cout << "configuracoes" << endl;
	char keyPressed;
	string lista[4];
	int posIndicador = 0;
	lista[0] = indicador;
	int i = 0;

	for(i = 1; i < 4; i ++)
	{
		lista[i] = indicadorVazio;
	}

	while(1){
		system("CLS");
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
		else if(int(keyPressed) == int('d'))
		{
			if (posIndicador == 0)
			{

			return 1;
			}
			else{

					return 1;
				}

		}
		else if(int(keyPressed) == int('a')){
			return 1;
		}

	}
}




void run()
{

	char keyPressed;
	string lista[2];
	int posIndicador = 0;
	lista[0] = indicador;
	lista[1] = indicadorVazio;


	while (1)
	{
		system("CLS");
		cout << lista[0] << " Disciplinas" << endl;
		cout << lista[1] << " Configuracoes" << endl;

		keyPressed = getch();
		if (int(keyPressed) == int('s'))
		{

			lista[posIndicador] = indicadorVazio;
			posIndicador = (posIndicador + 1) % 2;
			lista[posIndicador] = indicador;
		}

		else if (int(keyPressed) == int('d'))
		{

			if (posIndicador == 0)
			{
				if (exibeDisciplinas() == -1)
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
			return;
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
	n.nota = 8.6;

	dis.notas.push_back(n);
    dis.notas.push_back(n);
    dis.notas.push_back(n);

	bancoDados.push_back(dis);
	bancoDados.push_back(dis);
	run();
}
