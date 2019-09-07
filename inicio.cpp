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

	vector<nota> notas;
	string nome;
	string sala;
	string professor;
};

string indicador = "->";
string indicadorVazio = "  ";

vector<disciplina> bancoDados;


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
		
		else{
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
	bancoDados.push_back(dis);
	bancoDados.push_back(dis);
	run();
}
