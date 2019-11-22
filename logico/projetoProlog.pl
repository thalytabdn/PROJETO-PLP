:- initialization(main).
/* --funcoes uteis a mais de uma tela*/
up(119).
down(115).
left(97).
right(100).
select(113).

mediaAprovacaoPadrao(7.0).
mediaAprovacaoFinal(5.0).
mediaMinimaFinal(4.0).
valorProvaFinal(0.4).

getNotaMaximaFinal(Media, Nota) :-
    valorProvaFinal(VPF),
    Nota is ((1 - VPF)*Media) + (VPF*10).

getNotaMinimaFinal(Media, Nota) :-
    mediaAprovacaoFinal(MAF),
    valorProvaFinal(VPF),
    Nota is ((MAF - ((1 - VPF)*(Media)))/VPF).

getMaximoFaltante(PesoConsiderado, PesoDesconsiderado, Maximo) :-
    Maximo is ((PesoDesconsiderado *10)/(PesoConsiderado+PesoDesconsiderado)).

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

switch([O|Os], Item, Pos, Cont, NewO) :-
    (Pos =:= Cont -> NewO = [Item|Os];
     Cont2 is Cont + 1, switch(Os, Item, Pos, Cont2, NewO2), NewO = [O|NewO2]).

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

/* funcoes de entrada de dados--*/

getString(FinalInput, Mensagem) :-
    write("\n"),
    writeln(Mensagem),
    read_line_to_codes(user_input, Entrada), atom_string(Entrada, Return),
    FinalInput = Return.

getDouble(FinalInput, Mensagem) :-
    write("\n"),
    writeln(Mensagem),
    read(Return),
    FinalInput = Return.

/*-- funcoes de entrada de dados*/

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
     right(Action) -> disciplinaScreen(ListaCompromissos, ListaDisciplinas, 0 , 0, Cursor);
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

getPesoConsiderado([], 0).
getPesoConsiderado([[Nome, Peso, Valor,Considerar]|Ns], Retorno) :- 
    (Considerar =:= 1 -> getPesoConsiderado(Ns, Retorno2), Retorno = Peso + Retorno2; 
     getPesoConsiderado(Ns, Retorno2), Retorno = 0 + Retorno2).

getPesoDesconsiderado([], 0).
getPesoDesconsiderado([[Nome, Peso, Valor,Considerar]|Ns], Retorno) :- 
    (Considerar =:= 0 -> getPesoDesconsiderado(Ns, Retorno2), Retorno = Peso + Retorno2; 
     getPesoDesconsiderado(Ns, Retorno2), Retorno = 0 + Retorno2).

getValorConsiderado([], 0).
getValorConsiderado([[Nome, Peso, Valor,Considerar]|Ns], Retorno) :-
    (Considerar =:= 1 -> getValorConsiderado(Ns, Retorno2), V is Peso*Valor, Retorno = V + Retorno2;
     getValorConsiderado(Ns, Retorno2), Retorno = 0 + Retorno2).

getValorDesconsiderado([], 0).
getValorDesconsiderado([[Nome, Peso, Valor,Considerar]|Ns], Retorno) :-
    (Considerar =:= 0 -> getValorDesconsiderado(Ns, Retorno2), V is Peso*Valor, Retorno = V + Retorno2;
    getValorDesconsiderado(Ns, Retorno2), Retorno = 0 + Retorno2).

getMediaConsiderada(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaConsiderada) :-
    MediaConsiderada is (ValorConsiderado)/(PesoConsiderado + PesoDesconsiderado).

getMediaGeral(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaGeral) :-
    MediaGeral is (ValorConsiderado+ValorDesconsiderado)/(PesoConsiderado + PesoDesconsiderado).

relatorioNotasCompleto(MediaConsiderada) :-
    mediaAprovacaoPadrao(MAP),
    mediaMinimaFinal(MMF),
    (MediaConsiderada >= MAP -> write("'Parabens' :D voce esta aprovado, com media: "), writeln(MediaConsiderada);
     MediaConsiderada < MMF -> write("VISHI!! :( Voce ja esta 'Reprovado'");
     getNotaMaximaFinal(MediaConsiderada, NMF), getNotaMinimaFinal(MediaConsiderada, NMIF), write("Voce esta na final precisando de: "), writeln(NMIF), writeln(" para ser aprovado.\n"), write("Podendo ter media maxima de: "), writeln(NMF), writeln("caso tire 10 na final\n")).

relatorioNotasParcial(MaximoFaltante, MediaConsiderada) :-
    mediaAprovacaoPadrao(MAP),
    mediaAprovacaoFinal(MAF),
    MM is MediaConsiderada + MaximoFaltante,
    (MediaConsiderada >= MAP -> write("'Parabens' :D voce esta aprovado com media: "), write(MediaConsiderada), writeln(",caso voce tire 0 nas proximas notas\n"), write("Caso voce tire 100% nas proximas provas, sua media sera: "), writeln(MM);
     MediaConsiderada < MAP, MM >= MAP -> MN is MAP - MediaConsiderada, write("Voce ainda nao foi 'aprovado', entretanto voce tem que acumular no minimo: "), write(MN), writeln(", para ser aprovado.\n"), write("Podendo ter no maximo a media de: "), writeln(MM);
     (MM < MAF -> writeln("VISHI!! :( Voce ja esta 'Reprovado'\n");
      writeln("CUIDADO!! :O Voce ja esta na 'Final'\n"))).


relatorioNotas(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaConsiderada) :- 
    (PesoDesconsiderado =:= 0 -> relatorioNotasCompleto(MediaConsiderada);
     getMaximoFaltante(PesoConsiderado, PesoDesconsiderado, Maximo), relatorioNotasParcial(Maximo, MediaConsiderada)).

checaPesoTotalValido(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado) :-
    PesoAtual is (100 - (PesoConsiderado+PesoDesconsiderado)),
    (PesoAtual =< 0.11, PesoAtual >= 0 -> writeln("\nRelatorio de notas:\n"), getMediaConsiderada(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaConsiderada), relatorioNotas(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaConsiderada);
     writeln("\nErro - O valor somado de todos os pesos deve corresponder a 100%")).

showRelatorioSituacao(Notas) :-

    getPesoConsiderado(Notas, PesoConsiderado),
    getPesoDesconsiderado(Notas, PesoDesconsiderado),
    getValorConsiderado(Notas, ValorConsiderado),
    getValorDesconsiderado(Notas, ValorDesconsiderado),
    getMediaGeral(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaGeral),

    write("\nMedia Acumulada: "),
    writeln(MediaGeral),

    checaPesoTotalValido(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado).

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

getNewNomeNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina) :-
    nth0(CursorY, Notas, [Nome1, Peso1, Valor1,Considerar1]),
    getString(Input, "Digite o novo nome da nota"),
    switch(Notas, [Input, Peso1, Valor1, Considerar1], CursorY, 0, NewNotas),
    NewDisciplina = [Nome,Sala,Professor,NewNotas].

getNewPesoNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina) :-
    nth0(CursorY, Notas, [Nome1, Peso1, Valor1,Considerar1]),
    getDouble(Input, "Digite o novo peso da nota"),
    switch(Notas, [Nome1, Input, Valor1, Considerar1], CursorY, 0, NewNotas),
    NewDisciplina = [Nome,Sala,Professor,NewNotas].

getNewValorNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina) :-
    nth0(CursorY, Notas, [Nome1, Peso1, Valor1,Considerar1]),
    getDouble(Input, "Digite o novo valor da nota"),
    switch(Notas, [Nome1, Peso1, Input, Considerar1], CursorY, 0, NewNotas),
    NewDisciplina = [Nome,Sala,Professor,NewNotas].

switchConsiderar(Old, New) :-
    (Old =:= 0 -> New is 1;
     New is 0).

getNewConsiderarNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina) :-
    nth0(CursorY, Notas, [Nome1, Peso1, Valor1,Considerar1]),
    switchConsiderar(Considerar1, NewConsiderar),
    switch(Notas, [Nome1, Peso1, Valor1, NewConsiderar], CursorY, 0, NewNotas),
    NewDisciplina = [Nome,Sala,Professor,NewNotas].

doDisciplinasScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas], Action, IndexDisciplina) :-
    (up(Action) -> length(Notas, Tam), Tamanho is Tam-1, upAction(CursorY, Tamanho, NewCursorY), disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, NewCursorY, IndexDisciplina);
     down(Action) -> length(Notas, Tam), Tamanho is Tam-1, downAction(CursorY, Tamanho, NewCursorY), disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, NewCursorY, IndexDisciplina);
     left(Action), CursorX =:= 0 -> acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
     left(Action) -> upAction(CursorX, 3, NewCursorX), disciplinaScreen(ListaCompromissos, ListaDisciplinas, NewCursorX, CursorY, IndexDisciplina);
     right(Action) -> downAction(CursorX, 3, NewCursorX), disciplinaScreen(ListaCompromissos, ListaDisciplinas, NewCursorX, CursorY, IndexDisciplina);
     select(Action), CursorX =:= 0 -> getNewNomeNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina), switch(ListaDisciplinas, NewDisciplina, IndexDisciplina, 0, OI), disciplinaScreen(ListaCompromissos, OI, CursorX, CursorY, IndexDisciplina);
     select(Action), CursorX =:= 1 -> getNewValorNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina), switch(ListaDisciplinas, NewDisciplina, IndexDisciplina, 0, OI), disciplinaScreen(ListaCompromissos, OI, CursorX, CursorY, IndexDisciplina);
     select(Action), CursorX =:= 2 -> getNewPesoNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina), switch(ListaDisciplinas, NewDisciplina, IndexDisciplina, 0, OI), disciplinaScreen(ListaCompromissos, OI, CursorX, CursorY, IndexDisciplina);
     select(Action), CursorX =:= 3 -> getNewConsiderarNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina), switch(ListaDisciplinas, NewDisciplina, IndexDisciplina, 0, OI), disciplinaScreen(ListaCompromissos, OI, CursorX, CursorY, IndexDisciplina);
     disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, IndexDisciplina)).   
    

disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, IndexDisciplina) :-
    shell(clear),
    nth0(IndexDisciplina, ListaDisciplinas, [Nome,Sala,Professor,Notas]), 
    showDisciplinaScreen(Nome, Sala, Professor, Notas, CursorX, CursorY),
    showRelatorioSituacao(Notas),
    get_single_char(Action),
    doDisciplinasScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas], Action, IndexDisciplina).
/* tela de uma disciplina --*/

a([["ozocaba", "babaca", "zocaro", [["poi", 100.00, 100, 1], ["poi", 100.00, 100, 1]]], ["ozocaba", "babaca", "zocaro", [["poi", 100.00, 100, 1]]]]).
main :-
    a(Li),
    mainScreen([], Li, 0).