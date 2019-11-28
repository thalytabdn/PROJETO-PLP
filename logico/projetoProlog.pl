:- initialization(main).
/* --funcoes uteis a mais de uma tela*/
up(119).
down(115).
left(97).
right(100).
select(113).
remotion(101).

mediaAprovacaoPadrao(7.0).
mediaAprovacaoFinal(5.0).
mediaMinimaFinal(4.0).
valorProvaFinal(0.4).

getNotaMaximaFinal(Media, Nota) :-
    valorProvaFinal(VPF),
    Nota is ((1 - VPF)*Media) + (VPF*10).

getNotaMinimaFinal(Media, Nota) :-
    mediaAprovacaoFinal(MAF),
    valorProvaFinal(VPF),showOptions
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

remotionExitAction(Mensagem, Resultado) :-
    shell(clear),
    writeln(Mensagem),
    get_single_char(Input),
    (remotion(Input) -> Resultado is 1;
     Resultado is 0).

switch([O|Os], Item, Pos, Cont, NewO) :-
    (Pos =:= Cont -> NewO = [Item|Os];
     Cont2 is Cont + 1, switch(Os, Item, Pos, Cont2, NewO2), NewO = [O|NewO2]).


remove([], _, _, []).
remove([O|Os], Pos, Cont, NewO) :-
    (Pos =:= Cont -> NewO = Os;
     Cont2 is Cont1 + 1, remove(O, Pos, Cont2, NewO2), NewO = [O|NewO2]).https://github.com/thalytabdn/PROJETO-PLP.git

add([], Item, NewO) :-
    NewO = Item.
add([O|Os], Item, NewO) :-
    add(Os, Item, NewO2), NewO = [O|NewO2].

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

getInt(FinalInput, Mensagem) :-
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
     left(Action) -> killRunning(ListaCompromissos, ListaDisciplinas);
     right(Action) -> (Cursor =:= 0 -> acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);                       
                       Cursor =:= 1 -> cadastroCompromissoScreen(ListaCompromissos);
                       Cursor =:= 2 -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 3 -> tst;
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
     right(Action), Cursor =:= 0 -> cadastroDisciplinaScreen(ListaCompromissos, ListaDisciplinas);
     right(Action), Cursor =:= 1 -> acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action), Cursor =:= 2 -> acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
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
    length(ListaDisciplinas, Tam),
    (up(Action), Tam > 0 ->  Tamanho is Tam-1, upAction(Cursor, Tamanho, NewCursor), acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action), Tam > 0 -> Tamanho is Tam-1, downAction(Cursor, Tamanho, NewCursor), acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> mainScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action), Tam > 0 -> disciplinaScreen(ListaCompromissos, ListaDisciplinas, 0 , 0, Cursor);
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
    mediaAprovacaoPadrao(MAP),doMainScreen
    mediaMinimaFinal(MMF),
    (MediaConsiderada >= MAP -doMainScreenvado, com media: "), writeln(MediaConsiderada);
     MediaConsiderada < MMF ->doMainScreenovado'");
     getNotaMaximaFinal(MediaCdoMainScreenMediaConsiderada, NMIF), write("Voce esta na final precisando de: "), writeln(NMIF), writeln(" para ser aprovado.\n"), write("Podendo ter media maxima de: "), writeln(NMF), writeln("caso tire 10 na final\n")).

relatorioNotasParcial(MaximoFadoMainScreen
    mediaAprovacaoPadrao(MAP),doMainScreen
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

    length(Notas, Tam),
    (Tam =:= 0 -> write("\nMedia Acumulada: inexistente");

    getPesoConsiderado(Notas, PesoConsiderado),
    getPesoDesconsiderado(Notas, PesoDesconsiderado),
    getValorConsiderado(Notas, ValorConsiderado),
    getValorDesconsiderado(Notas, ValorDesconsiderado),
    
    getMediaGeral(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaGeral),

    write("\nMedia Acumulada: "),
    writeln(MediaGeral),

    checaPesoTotalValido(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado)).

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
    length(Notas, Tam),
    (up(Action), Tam > 0  -> Tamanho is Tam-1, upAction(CursorY, Tamanho, NewCursorY), disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, NewCursorY, IndexDisciplina);
     down(Action), Tam > 0  -> Tamanho is Tam-1, downAction(CursorY, Tamanho, NewCursorY), disciplinaScreen(ListaCompromissos, ListaDisciplinas, CursorX, NewCursorY, IndexDisciplina);
     left(Action), CursorX =:= 0 -> acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
     left(Action), Tam > 0  -> upAction(CursorX, 3, NewCursorX), disciplinaScreen(ListaCompromissos, ListaDisciplinas, NewCursorX, CursorY, IndexDisciplina);
     right(Action), Tam > 0  -> downAction(CursorX, 3, NewCursorX), disciplinaScreen(ListaCompromissos, ListaDisciplinas, NewCursorX, CursorY, IndexDisciplina);
     select(Action), CursorX =:= 0, Tam > 0 -> getNewNomeNota([Nome,Sala,Professor,Notas], CursorY, NewDisciplina), switch(ListaDisciplinas, NewDisciplina, IndexDisciplina, 0, OI), disciplinaScreen(ListaCompromissos, OI, CursorX, CursorY, IndexDisciplina);
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

/* -- tela de remocao de disciplinas */
doAcessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    
    length(ListaDisciplinas, Tam),
    (up(Action), Tam > 0 -> Tamanho is Tam-1, upAction(Cursor, Tamanho, NewCursor), acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action), Tam > 0 -> Tamanho is Tam-1, downAction(Cursor, Tamanho, NewCursor), acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
     select(Action), Tam > 0 -> remotionExitAction("Caso deseje excluir a disciplina pressione a tecla (e)", Resultado), 
     (Resultado =:= 1 -> remove(ListaDisciplinas, Cursor, 0, NewLis), shell(clear), writeln("Excluido com sucesso"), get_single_char(NotUsed), acessoRemocaoDisciplinasScreen(ListaCompromissos, NewLis, 0);
      acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0));
     acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor)
    ).

acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    listNomesDisciplinas(ListaDisciplinas, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).
/* tela de remocao de disciplinas --*/

/* -- tela acesso disciplinas para edicao */
doAcessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    length(ListaDisciplinas, Tam), 
    (up(Action), Tam > 0 -> Tamanho is Tam-1, upAction(Cursor, Tamanho, NewCursor), acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action), Tam > 0 -> Tamanho is Tam-1, downAction(Cursor, Tamanho, NewCursor), acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action), Tam > 0 -> edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, Cursor, 0);
     acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor)
    ).

acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    listNomesDisciplinas(ListaDisciplinas, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).
/* tela acesso disciplinas para edicao --*/

/* -- tela disciplina para edicao */
optionEdicaoDisciplina([Nome,Sala,Professor,Notas], ListaOpcoes) :-
    length(Notas, Len),
    string_concat("Nome Disciplina: ", Nome, A),
    string_concat("Nome Professor: ", Professor, B),
    string_concat("Sala: ", Sala, C),
    string_concat("Quantidade de notas: ", Len, D),
    ListaOpcoes = [A,B,C,D].

retrieve([N|Ns], NewLen, NewNotas, Cont) :-
    (Cont =:= NewLen -> NewNotas = [];
     Cont2 is Cont + 1, retrieve(Ns, NewLen, NewNotas2, Cont2), NewNotas = [N|NewNotas2]).

getEmptyNotas(OldLen, NewLen, EmptyNotas) :-
    string_concat(OldLen,"º Nota", Nome),
    (NewLen =:= OldLen -> EmptyNotas = [[Nome, 0, 0, 0]];
     OldLen2 is OldLen + 1, getEmptyNotas(OldLen2, NewLen, EmptyNotas2), EmptyNotas = [[Nome, 0, 0, 0]|EmptyNotas2]).

getNewLenNotas(Notas, OldLen, NewLen, NewO) :-
    (NewLen < OldLen -> retrieve(Notas, NewLen, NewNotas, 0), NewO = NewNotas;
     NewLen > OldLen -> OldLen2 is OldLen + 1, getEmptyNotas(OldLen2, NewLen, EmptyNotas), append(Notas, EmptyNotas, NewNotas), NewO = NewNotas;
     NewO = Notas
).

doEdicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, [Nome,Sala,Professor,Notas], Cursor, Action) :-
    (up(Action) -> Tamanho is 3, upAction(Cursor, Tamanho, NewCursor), edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, NewCursor);
     down(Action) -> Tamanho is 3, downAction(Cursor, Tamanho, NewCursor), edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, NewCursor);
     left(Action) -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action), Cursor =:= 0 -> getString(Input, "Digite o novo nome da disciplina"), switch(ListaDisciplinas, [Input,Sala,Professor,Notas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     right(Action), Cursor =:= 2 -> getString(Input, "Digite a nova sala da disciplina"), switch(ListaDisciplinas, [Nome,Input,Professor,Notas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     right(Action), Cursor =:= 1 -> getString(Input, "Digite o novo professor da disciplina"), switch(ListaDisciplinas, [Nome,Sala,Input,Notas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     right(Action), Cursor =:= 3 -> getInt(Input, "Digite a nova quantidade de notas"), length(Notas, Len), getNewLenNotas(Notas, Len, Input, NewNotas), switch(ListaDisciplinas, [Nome,Sala,Professor,NewNotas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, Cursor)
    ).

edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, Cursor) :-
    shell(clear),
    nth0(IndexDisciplina, ListaDisciplinas, Disciplina),
    optionEdicaoDisciplina(Disciplina, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doEdicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, Disciplina, Cursor, Action).
/* tela disciplina para edicao --*/

/* -- tela de cadastro de disciplinas */
cadastroDisciplinaScreen(ListaCompromissos, ListaDisciplinas) :-
    getString(Nome, "Digite um novo Nome de disciplina"),
    getString(Professor, "Digite um nome para o professor"),
    getString(Sala, "Digite o Identificador da sala"),

    Notas = [["1º Nota",33.33, 0, 1], ["2º Nota",33.33, 0, 1], ["3º Nota", 33.33, 0, 1]],
    append(ListaDisciplinas, [[Nome,Sala,Professor,Notas]], NewO),

    writeln("\nA disciplina foi iniciada com o sistema de notas padrao, (!!nao se preucupe ele pode ser modificado em configuracoes!!)"),
    get_single_char(NotUsed),

    configuracoesScreen(ListaCompromissos, NewO, 0).

/* tela de cadastro de disciplinas --*/

write_list_to_file(Filename,List) :-
    open(Filename, write, File),
    write_canonical(File, List),  
    write(File, "."),
    close(File).

readDisciplinas(ListaDisciplinas) :-
    open("Arquivos/Disciplinas.dat", read, File),
    read(File, W),
    close(File),
    ListaDisciplinas = W.

killRunning(ListaCompromissos, ListaDisciplinas) :-
    write_list_to_file("Arquivos/Disciplinas.dat", ListaDisciplinas).


a([["ozocaba", "babaca", "zocaro", [["poi", 100.00, 100, 1], ["poi", 100.00, 100, 1]]], ["ozocaba", "babaca", "zocaro", [["poi", 100.00, 100, 1]]]]).
main :-
    readDisciplinas(ListaDisciplinas),
    mainScreen([], ListaDisciplinas, 0).

cadastroCompromissoScreen(ListaCompromissos) :-
    write("|| Aperte (d) para criar Compromissos ou Acessa-los ||\n"),

    


    get_single_char(Action),
    doConfiguracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).


tst:- 
    write("\nTutorial Geral do App de Gerenciamento: \n"),   
    write("\nPara se Locomover no aplicativo utilize as teclas {W,A,S,D}"),  
    write("\n-----------------------------------------------------------"), 
    write("\n(Seta Superior) - Faz com que o curso se mova para cima"),  
    write("\n(Seta Esquerda) - Volta para a pagina anterior"),   
    write("\n(Seta Inferior) - Faz com que o curso se mova para baixo"),   
    write("\n(Seta Direita)  - Passa para a proxima Pagina"),    
    write("\n-----------------------------------------------------------"),   
    write("\nDisciplina:"),    
    write("\n-----------------------------------------------------------"),    
    write("\nAo acessar a pagina Disciplina você será direcionado para o local onde\nficará amazenado todas as suas Disciplinas e para acessá-las basta com as\nteclas selecionadas escolher qual Disciplina você deseja vizualizar e clicar 'D',\ndentro da disciplina selecionada você pode cadastrar as notas e o programa lhe\ndirar sua situcação na disciplina."),    
    write("\n-----------------------------------------------------------"),     
    write("\nConfigurações:"),     
    write("\n----------------------------------------------------------- "),   
    write("\nAo acessar a pagina de Configuraçoes, você será direcionado para 4 opções\nde configuraçoes onde podera cadastrar, atualizar ou remover a disciplina\n\nCadastrar Disciplina: Ao selecionar a opção de castrar disciplina\nserá peguntados informações basicas sobre a disciplina.\n\nAtualizar Disciplina: Caso deseja que a disciplina já cadastrada mude alguma\ninformação basta atualizala\n\nRemover Disciplina: Remove uma Disciplina já cadastrada\n\nReset: Irá resetar todo o programa."),   
    write("\n-----------------------------------------------------------"),    
    write("\nEntão você já estar preparado para se organizar durante seu período?\nEntão vamos lá, basta apenas clicar 'A' para voltar a pagina inicial e cadastrar suas disciplinas."),
    get_single_char(Action),
    doConfiguracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).
