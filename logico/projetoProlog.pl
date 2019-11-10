:- initialization(main).
/* --funcoes uteis a mais de uma tela*/
up(119).
down(115).
left(97).
right(100).

upAction(Cursor, Limit, NewCursor) :-
    Cursor =:= 0,
    NewCursor is Limit.
upAction(Cursor, _, NewCursor) :-
    Cursor =\= 0,
    NewCursor is Cursor - 1.

downAction(Cursor, Limit, NewCursor) :-
    Max is Limit + 1,
    PC is Cursor + 1,
    NewCursor is PC mod Max.

showOptions([], _, _).
showOptions([A|As], N, N) :- 
    write("->"),
    writeln(A),
    N1 is N+1,
    showOptions(As, N, N1).
    
showOptions([A|As], Cursor, N) :- 
    write("  "),
    writeln(A),
    N1 is N+1,
    showOptions(As, Cursor, N1).

listNomesDisciplinas([], []).
listNomesDisciplinas([[Nome|Resto]|Ds], ListaOpcoes) :-
    listNomesDisciplinas(Ds, ListaOpcoes2),
    ListaOpcoes = [Nome|ListaOpcoes2].

/* funcoes uteis a mais de uma tela--*/

/*-- tela principal*/
optionsMainScreen([" Disciplinas", " Compromissos", " Configuracoes", " Tutorial"]).

doMainScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    (up(Action) -> upAction(Cursor, 3, NewCursor), mainScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action) -> downAction(Cursor, 3, NewCursor), mainScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> write("");
     right(Action) -> (Cursor =:= 0 -> acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 2 -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
                       mainScreen(ListaCompromissos, ListaDisciplinas, Cursor));
     mainScreen(ListaCompNromissos, ListaDisciplinas, Cursor)).

mainScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    optionsMainScreen(ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doMainScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).
/*tela principal --*/

/*-- tela configuracoes*/
optionsConfiguracoesScreen([" Cadastrar disciplina", " Atualizar disciplina", " Remover disciplina", " Resetar sistema"]).

doConfiguracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    (up(Action) -> upAction(Cursor, 3, NewCursor), configuracoesScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action) -> downAction(Cursor, 3, NewCursor), configuracoesScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> mainScreen(ListaCompromissos, ListaDisciplinas, Cursor);
     right(Action) -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor);
     configuracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor)).


configuracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    optionsConfiguracoesScreen(ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doConfiguracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* tela Configuracoes --*/

/* -- tela acesso disciplinas */
doAcessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    (up(Action) -> length(ListaDisciplinas, Tam), Tamanho is Tam-1, upAction(Cursor, Tamanho, NewCursor), acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action) -> length(ListaDisciplinas, Tam), Tamanho is Tam-1, downAction(Cursor, Tamanho, NewCursor), acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> mainScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action) -> nth0(Cursor, ListaDisciplinas, Disciplina), disciplinaScreen(ListaCompromissos, ListaDisciplinas, 0 , 0, Disciplina);
     acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor)
    ).

acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    listNomesDisciplinas(ListaDisciplinas, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).
/* tela acesso disciplinas --*/

/* -- tela de uma disciplina */
showDisciplinaHeader(Nome, Sala, Professor) :-
    write("Disciplina: "), writeln(Nome),
    write("Sala: "), write(Sala), write(" | "), write("Professor: "), writeln(Professor),
    writeln("Avaliacao - nota - peso -|- Usar dado:\n").

showDisciplinaContent([], _, _, _).
showDisciplinaContent([[Nome, Peso, Valor,Considerar]|Ns], CursorX, CursorY, Cont) :-
    (CursorX =:= 0, CursorY =:= Cont -> write("->"), write(Nome), write(" |   "), write(Valor), write(" |   "), write(Peso), write(" |   "), writeln(Considerar);
     CursorX =:= 1, CursorY =:= Cont -> write("  "), write(Nome), write(" | ->"), write(Valor), write(" |   "), write(Peso), write(" |   "), writeln(Considerar);
     CursorX =:= 2, CursorY =:= Cont -> write("  "), write(Nome), write(" |   "), write(Valor), write(" | ->"), write(Peso), write(" |   "), writeln(Considerar);
     CursorX =:= 3, CursorY =:= Cont -> write("  "), write(Nome), write(" |   "), write(Valor), write(" |   "), write(Peso), write(" | ->"), writeln(Considerar);
     write("  "), write(Nome), write(" |   "), write(Valor), write(" |   "), write(Peso), write(" |   "), writeln(Considerar)
    ),
    Cont1 is Cont +1,
    showDisciplinaContent(Ns, CursorX, CursorY, Cont1).

showDisciplinaScreen(Nome, Sala, Professor, Notas, CursorX, CursorY) :-
    showDisciplinaHeader(Nome, Sala, Professor),
    showDisciplinaContent(Notas, CursorX, CursorY, 0).

doDisciplinasScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas], Action) :-
    (up(Action) -> length(Notas, Tam), Tamanho is Tam-1, upAction(CursorY, Tamanho, NewCursorY), disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, NewCursorY, [Nome,Sala,Professor,Notas]);
     down(Action) -> length(Notas, Tam), Tamanho is Tam-1, downAction(CursorY, Tamanho, NewCursorY), disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, NewCursorY, [Nome,Sala,Professor,Notas]);
     left(Action), CursorX =:= 0 -> acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
     left(Action) -> upAction(CursorX, 3, NewCursorX), disciplinaScreen(ListaCompromissos, ListaDisciplinas, NewCursorX, CursorY, [Nome,Sala,Professor,Notas]);
     right(Action) -> downAction(CursorX, 3, NewCursorX), disciplinaScreen(ListaCompromissos, ListaDisciplinas, NewCursorX, CursorY, [Nome,Sala,Professor,Notas]);
     disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas])).   
    

disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas]) :-
    shell(clear),
    showDisciplinaScreen(Nome, Sala, Professor, Notas, CursorX, CursorY),
    get_single_char(Action),
    doDisciplinasScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas], Action).
/* tela de uma disciplina --*/

a([["ozocaba", "babaca", "zocaro", [["poi", 100.00, 100, 1], ["poi", 100.00, 100, 1]]], ["ozocaba", "babaca", "zocaro", [["poi", 100.00, 100, 1]]]]).
main :-
    a(Li),
    mainScreen([], Li, 0).