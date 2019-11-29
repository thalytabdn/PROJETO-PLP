:- initialization(main).

/* -> FUNCOES UTEIS -- */

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

/* -------------------- */

upAction(0, Limit, Limit).
upAction(Cursor, _, NewCursor) :-
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

getNotaMaximaFinal(Media, Nota) :-
    valorProvaFinal(VPF),
    Nota is ((1 - VPF)*Media) + (VPF*10).

getNotaMinimaFinal(Media, Nota) :-
    mediaAprovacaoFinal(MAF),
    valorProvaFinal(VPF),
    Nota is ((MAF - ((1 - VPF)*(Media)))/VPF).

getMaximoFaltante(PesoConsiderado, PesoDesconsiderado, Maximo) :-
    Maximo is ((PesoDesconsiderado *10)/(PesoConsiderado+PesoDesconsiderado)).

switch([O|Os], Item, Pos, Cont, NewO) :-
    (Pos =:= Cont -> NewO = [Item|Os];
        Cont2 is Cont + 1, switch(Os, Item, Pos, Cont2, NewO2), NewO = [O|NewO2]).

remove([], _, _, []).
remove([O|Os], Pos, Cont, NewO) :-
    (Pos =:= Cont -> NewO = Os;
        Cont2 is Cont + 1, remove(Os, Pos, Cont2, NewO2), NewO = [O|NewO2]).

add([], Item, Item).
add([O|Os], Item, NewO) :-
    add(Os, Item, NewO2),
    NewO = [O|NewO2].

showOptions([], _, _).
showOptions([A|As], Cursor, Cursor) :- 
    write("-> "),
    writeln(A),
    N is Cursor + 1,
    showOptions(As, Cursor, N).
    
showOptions([A|As], Cursor, N) :- 
    write("   "),
    writeln(A),
    NewN is N + 1,
    showOptions(As, Cursor, NewN).

listNomesDisciplinas([], []).
listNomesDisciplinas([[Nome|Resto]|Ds], ListaOpcoes) :-
    listNomesDisciplinas(Ds, ListaOpcoes2),
    ListaOpcoes = [Nome|ListaOpcoes2].

listNomesCompromissos([],[]).
listNomesCompromissos([[Nome, Detalhes, Prioridade, Status]|OthersComps], ListaOpcoes) :-
    listNomesCompromissos(OthersComps, NewListaOpcoes),
    atom_concat("Titulo: ", Nome, A1),
    atom_concat("\n   Status: ", Status, A2),
    atom_concat(A2, "\n", A3),
    atom_concat(A1, A3, A),
    ListaOpcoes = [A|NewListaOpcoes].

/* FUNCOES UTEIS <- */

/* -> FUNCOES PARA IO */

getString(FinalInput, Mensagem) :-
    write("\n"),
    writeln(Mensagem),
    read_line_to_codes(user_input, Entrada), atom_string(Entrada, Return),
    FinalInput = Return.

getDouble(FinalInput, Mensagem) :-
    write("\n"),
    writeln(Mensagem),
    read_line_to_codes(user_input, Entrada), atom_string(Entrada, Return),
    (number_string(Number, Return), Number >= 0 -> FinalInput = Number;
        getDouble(NewF, "Entrada invalida digite novamente!"), FinalInput is NewF).

getDouble10(FinalInput, Mensagem) :-
    getDouble(F, Mensagem),
    (F >= 0, F =< 10 -> FinalInput is F;
        getDouble(NewF, "Entrada invalida digite novamente!"), FinalInput is NewF).

getInt(FinalInput, Mensagem) :-
    write("\n"),
    writeln(Mensagem),
    read_line_to_codes(user_input, Entrada), atom_string(Entrada, Return),
    (number_string(Number, Return), Number >= 0 -> FinalInput = Number;
        getDouble(NewF, "Entrada invalida digite novamente!"), FinalInput is NewF).

/* FUNCOES PARA IO <- */

/* -> TELA PRINCIPAL */

optionsMainScreen(["Disciplinas", "Compromissos", "Configuracoes", "Tutorial"]).
limitMain(3).

/* ------------------------------------------------------------------------------ */

showExitMessage() :-
    shell(clear),
    writeln("---------------------------------------------"),
    writeln("* MUITO OBRIGADO POR UTILIZAR NOSSO SISTEMA *"),
    writeln("*                 ATE MAIS!                 *"),
    writeln("---------------------------------------------\n").

doMainScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    limitMain(Limit),
    (up(Action) -> upAction(Cursor, Limit, NewCursor), mainScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action) -> downAction(Cursor, Limit, NewCursor), mainScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> showExitMessage(), killRunning(ListaCompromissos, ListaDisciplinas);
     right(Action) -> (Cursor =:= 0 -> acessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 1 -> acessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 2 -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 3 -> tutorialScreen(ListaCompromissos, ListaDisciplinas));
     mainScreen(ListaCompromissos, ListaDisciplinas, Cursor)).

mainScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    writeln("\n|| (w,s) Para mover o cursor  ||"),
    writeln("|| (a) Para modificar a tela  ||"),
    writeln("|| (d) Para entrar nas opcoes ||\n"),
    optionsMainScreen(ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doMainScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* TELA PRINCIPAL <- */

/* -> TELA CONFIGURACOES */

optionsConfiguracoesScreen(["Cadastrar disciplina", "Atualizar disciplina", "Remover disciplina", "Resetar sistema"]).
limitConfig(3).

/* -------------------------------------------------------------------------------------------------------------------- */

doConfiguracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    limitConfig(Limit),
    (up(Action) -> upAction(Cursor, Limit, NewCursor), configuracoesScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action) -> downAction(Cursor, Limit, NewCursor), configuracoesScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> mainScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action) -> (Cursor =:= 0 -> cadastroDisciplinaScreen(ListaCompromissos, ListaDisciplinas);
                       Cursor =:= 1 -> acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 2 -> acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
                       Cursor =:= 3 -> remotionExitAction("(e) Para limpar o banco [ IRREVERSSIVEL ]", Resultado), 
                                       (Resultado =:= 1 -> shell(clear), writeln("Sistema resetado com sucesso!"),
                                                           get_single_char(NotUsed),
                                                           resetSystem;
                                            configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0)));
     configuracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor)).

configuracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    writeln("\n|| (w,s) Para mover o cursor  ||"),
    writeln("|| (a) Para modificar a tela  ||"),
    writeln("|| (d) Para entrar nas opcoes ||\n"),
    optionsConfiguracoesScreen(ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doConfiguracoesScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* TELA CONFIGURACOES <- */

/* -> TELA DE ACESSO A DISCIPLINAS */

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
    writeln("\n|| (w,s) Para mover o cursor     ||"),
    writeln("|| (a) Para modificar a tela     ||"),
    writeln("|| (d) Para entrar na disciplina ||\n"),
    listNomesDisciplinas(ListaDisciplinas, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* TELA DE ACESSO A DISCIPLINAS <- */

/* -> TELA DE REMOÇÃO DE DISCIPLINA */

/* --> FUNÇÕES ESTÁTICAS */

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

round(X,Y,D) :- Z is X * 10^D, round(Z, ZA), Y is ZA / 10^D.

getMediaConsiderada(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaConsiderada) :-
    MediaConsiderada1 is (ValorConsiderado)/(PesoConsiderado + PesoDesconsiderado),
    round(MediaConsiderada1, MediaConsiderada, 2).

getMediaGeral(PesoConsiderado, PesoDesconsiderado, ValorConsiderado, ValorDesconsiderado, MediaGeral) :-
    MediaGeral1 is (ValorConsiderado+ValorDesconsiderado)/(PesoConsiderado + PesoDesconsiderado),
    round(MediaGeral1, MediaGeral, 2).
    
/* FUNÇÕES ESTÁTICAS <-- */

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
    P is PesoConsiderado + PesoDesconsiderado,
    (P =:= 0 -> write("\nMedia Acumulada: inexistente");

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
    getDouble10(Input, "Digite o novo valor da nota"),
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
    writeln("\n|| (a) ou (d) Para mover o cursor horizontalmente                                                              ||"),
    writeln("|| (w) ou (s) Para mover o cursor verticalmente                                                                    ||"), 
    writeln("|| (q) Para mudar algum atributo de nota                                                                           ||"),
    writeln("|| (Usar dado) indica se o codigo deve ou nao analisar a nota no relatorio (1)->sim (0)->nao, alterna-se com (q)!! ||\n"), 

    nth0(IndexDisciplina, ListaDisciplinas, [Nome,Sala,Professor,Notas]), 
    showDisciplinaScreen(Nome, Sala, Professor, Notas, CursorX, CursorY),
    showRelatorioSituacao(Notas),
    get_single_char(Action),
    doDisciplinasScreen(ListaCompromissos, ListaDisciplinas, CursorX, CursorY, [Nome,Sala,Professor,Notas], Action, IndexDisciplina).

/* TELA DE UMA DISCIPLINA <- */

/* -> TELA DE REMOÇÃO DE DISCIPLINA */

doAcessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    
    length(ListaDisciplinas, Tam),
    (up(Action), Tam > 0 -> Tamanho is Tam-1, upAction(Cursor, Tamanho, NewCursor), acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action), Tam > 0 -> Tamanho is Tam-1, downAction(Cursor, Tamanho, NewCursor), acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> configuracoesScreen(ListaCompromissos, ListaDisciplinas, 0);
     select(Action), Tam > 0 -> remotionExitAction("(e) Para excluir a disciplina", Resultado), 
     (Resultado =:= 1 -> remove(ListaDisciplinas, Cursor, 0, NewLis), shell(clear), writeln("Excluido com sucesso!"), get_single_char(NotUsed), acessoRemocaoDisciplinasScreen(ListaCompromissos, NewLis, 0);
      acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0));
     acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor)).

acessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    writeln("\n|| (w,s) Para mover o cursor                 ||"),
    writeln("|| (a,d) Para modificar a tela               ||"),
    writeln("|| (q) Para escolher qual disciplina remover ||\n"),

    listNomesDisciplinas(ListaDisciplinas, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoRemocaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* TELA DE REMOÇÃO DE DISCIPLINA <- */

/* TELA DE ACESSO À EDIÇÃO DE DISCIPLINA <- */

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
    writeln("\n|| (w,s) Para mover o cursor                 ||"),
    writeln("|| (a,d) Para modificar a tela               ||"),
    writeln("|| (d) Para escolher qual disciplina Editar  ||\n"),
    listNomesDisciplinas(ListaDisciplinas, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* TELA DE ACESSO À EDIÇÃO DE DISCIPLINA <- */

/* -> TELA PARA EDIÇÃO DE DISCIPLINA */

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
     left(Action) -> acessoEdicaoDisciplinasScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action), Cursor =:= 0 -> getString(Input, "Digite o novo nome da disciplina"), switch(ListaDisciplinas, [Input,Sala,Professor,Notas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     right(Action), Cursor =:= 2 -> getString(Input, "Digite a nova sala da disciplina"), switch(ListaDisciplinas, [Nome,Input,Professor,Notas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     right(Action), Cursor =:= 1 -> getString(Input, "Digite o novo professor da disciplina"), switch(ListaDisciplinas, [Nome,Sala,Input,Notas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     right(Action), Cursor =:= 3 -> getInt(Input, "Digite a nova quantidade de notas"), length(Notas, Len), getNewLenNotas(Notas, Len, Input, NewNotas), switch(ListaDisciplinas, [Nome,Sala,Professor,NewNotas], IndexDisciplina, 0, NewO), edicaoDisciplinaScreen(ListaCompromissos, NewO, IndexDisciplina, Cursor);
     edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, Cursor)
    ).

edicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, Cursor) :-
    shell(clear),
    writeln("\n|| Utilize os direcionais (w,s) do teclado para mover o cursor e (a,d) para modificar a tela ||"),
    writeln("|| Aperte (q) para escolher qual informacao alterar ||\n"),

    nth0(IndexDisciplina, ListaDisciplinas, Disciplina),
    optionEdicaoDisciplina(Disciplina, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doEdicaoDisciplinaScreen(ListaCompromissos, ListaDisciplinas, IndexDisciplina, Disciplina, Cursor, Action).

/* TELA PARA EDIÇÃO DE DISCIPLINA <- */

/* -> TELA DE CADASTRO DE DISCIPLINAS */

cadastroDisciplinaScreen(ListaCompromissos, ListaDisciplinas) :-
    shell(clear),
    getString(Nome, "Digite um novo Nome de disciplina"),
    getString(Professor, "Digite um nome para o professor"),
    getString(Sala, "Digite o Identificador da sala"),

    Notas = [["1º Nota",33.33, 0, 1], ["2º Nota",33.33, 0, 1], ["3º Nota", 33.33, 0, 1]],
    append(ListaDisciplinas, [[Nome,Sala,Professor,Notas]], NewO),

    writeln("\nA disciplina foi iniciada com o sistema de notas padrao, (!!nao se preucupe ele pode ser modificado em configuracoes!!)"),
    get_single_char(NotUsed),

    configuracoesScreen(ListaCompromissos, NewO, 0).

/* TELA DE CADASTRO DE DISCIPLINAS <- */

/* -> TELA DE ACESSO ASOS COMPROMISSOS */

optionsAcessoCompromissoScreen(["CADASTRAR COMPROMISSO\n"]).

doAcessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action) :-
    length(ListaCompromissos, LEN),
    (up(Action) -> upAction(Cursor, LEN, NewCursor), acessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     down(Action) -> downAction(Cursor, LEN, NewCursor), acessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, NewCursor);
     left(Action) -> mainScreen(ListaCompromissos, ListaDisciplinas, Cursor);
     right(Action), Cursor =:= 0 -> cadastroCompromissosScreen(ListaCompromissos, ListaDisciplinas);
     right(Action), Cursor =\= 0 -> Cursor1 is Cursor -1, compromissoScreen(ListaCompromissos, ListaDisciplinas, Cursor1, 0);
     acessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, Cursor)).

acessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, Cursor) :-
    shell(clear),
    writeln("\n|| (w,s) Para mover o cursor                     ||"),
    writeln("|| (a,d) Para modificar a tela                   ||"),
    writeln("|| (d) Para cadastar ou acessar os compromissos  ||\n"),
    optionsAcessoCompromissoScreen(Opcoes),
    listNomesCompromissos(ListaCompromissos, ListaNomes),
    append(Opcoes, ListaNomes, ListaOpcoes),
    showOptions(ListaOpcoes, Cursor, 0),
    get_single_char(Action),
    doAcessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, Cursor, Action).

/* TELA DE ACESSO ASOS COMPROMISSOS <- */

/* -> TELA DE CADASTRO DOS COMPROMISSOS */

cadastroCompromissosScreen(ListaCompromissos, ListaDisciplinas) :-
    shell(clear),
    getString(Nome, "Digite um Titulo para o compromisso"),
    getString(Detalhes, "Digite os Detalhes do compromisso"),
    getString(Prioridade, "Digite a Prioridade do compromisso"),

    append(ListaCompromissos, [[Nome, Detalhes, Prioridade, "Em Andamento"]], NewO),
    acessoCompromissosScreen(NewO, ListaDisciplinas, 0).

/* TELA DE CADASTRO DOS COMPROMISSOS <- */

/* -> TELA DE COMPROMISSOS */

optionsCompromissoScreen([Nome, Detalhes, Prioridade, Status], Options) :-
    atom_concat("Titulo    : ", Nome, L0),
    atom_concat("Detalhes  : ", Detalhes, L1),
    atom_concat("Prioridade: ", Prioridade, L2),
    atom_concat("Status    : ", Status, L3),
    atom_concat(L3, "\n", L4),    

    Options = [L0, L1, L2, L4, "REMOVER COMPROMISSO"].
    
doCompromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, Cursor, Action) :-
    nth0(IndexCompromisso, ListaCompromissos, [Nome, Detalhes, Prioridade, Status]),
    (up(Action) -> upAction(Cursor, 4, NewCursor), compromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, NewCursor);
     down(Action) -> downAction(Cursor, 4, NewCursor), compromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, NewCursor);
     left(Action) -> acessoCompromissosScreen(ListaCompromissos, ListaDisciplinas, 0);
     right(Action), Cursor =:= 0 -> getString(Input, "Digite o novo titulo do compromisso"), switch(ListaCompromissos, [Input, Detalhes, Prioridade, Status], IndexCompromisso, 0, NewO), compromissoScreen(NewO, ListaDisciplinas, IndexCompromisso, Cursor);
     right(Action), Cursor =:= 1 -> getString(Input, "Digite os novos detalhes do compromisso"), switch(ListaCompromissos, [Nome, Input, Prioridade, Status], IndexCompromisso, 0, NewO), compromissoScreen(NewO, ListaDisciplinas, IndexCompromisso, Cursor);
     right(Action), Cursor =:= 2 -> getString(Input, "Digite a nova prioridade do compromisso"), switch(ListaCompromissos, [Nome, Detalhes, Input, Status], IndexCompromisso, 0, NewO), compromissoScreen(NewO, ListaDisciplinas, IndexCompromisso, Cursor);
     right(Action), Cursor =:= 3 -> getString(Input, "Digite o novo status do compromisso"), switch(ListaCompromissos, [Nome, Detalhes, Prioridade, Input], IndexCompromisso, 0, NewO), compromissoScreen(NewO, ListaDisciplinas, IndexCompromisso, Cursor);
     right(Action), Cursor =:= 4 -> remotionExitAction("Caso deseje excluir o compromisso pressione a tecla (e)", Resultado), 
     (Resultado =:= 1 -> remove(ListaCompromissos, IndexCompromisso, 0, NewLis), shell(clear), writeln("Excluido com sucesso"), get_single_char(NotUsed), acessoCompromissosScreen(NewLis, ListaDisciplinas, 0);
      compromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, Cursor));
     compromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, Cursor)).

compromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, Cursor) :-
    shell(clear),
    writeln("\n|| (w,s) Para mover o cursor                     ||"),
    writeln("|| (a,d) Para modificar a tela                   ||"),
    writeln("|| (d) Para cadastar ou acessar os compromissos  ||\n"),
    writeln("|| Selecione um campo para atera-lo              ||\n"),

    nth0(IndexCompromisso, ListaCompromissos, Compromisso),
    optionsCompromissoScreen(Compromisso, Options),
    showOptions(Options, Cursor, 0),
    get_single_char(Action),
    doCompromissoScreen(ListaCompromissos, ListaDisciplinas, IndexCompromisso, Cursor, Action).

/* TELA DE COMPROMISSOS <- */

/* -> TELA DE TUTORIAL */

tutorialScreen(ListaCompromissos, ListaDisciplinas):- 
    shell(clear),
    writeln("TUTORIAL PARA O APP DE GERENCIAMENTO: "),
    writeln("\nPara se Locomover no aplicativo utilize as teclas {W,A,S,D}"),
    writeln("-----------------------------------------------------------"),
    writeln("(w) - Faz com que o cursor se mova para cima"),
    writeln("(a) - Volta para a pagina anterior"),
    writeln("(s) - Faz com que o cursor se mova para baixo"),
    writeln("(d) - Funciona como Enter"),
    writeln("-----------------------------------------------------------"),
    writeln("\nDISCIPLINA: "),
    writeln("-----------------------------------------------------------"),
    writeln("Ao acessar a pagina Disciplina você sera direcionado para o\nlocal onde ficarao amazenadas todas as suas Disciplinas e,\npara acessá-las, basta que, com as teclas indicadas acima,\nse escolha qual Disciplina você deseja.\n\nDentro da disciplina selecionada você pode cadastrar as\nnotas e o programa lhe dira sua situcacao na disciplina."),
    writeln("-----------------------------------------------------------"),
    writeln("\nCONFIGURACOES: "),
    writeln("-----------------------------------------------------------"),
    writeln("Ao acessar a pagina de Configuraçoes, você será direcionado\npara 4 opcoes de configuraçoes, onde poderá cadastrar,\natualizar ou remover a disciplina e/ou resetar o sistema."),
    writeln("\nCadastrar Disciplina:\n    Ao selecionar a opção de castrar disciplina serao\n    peguntadas as informações basicas sobre a disciplina;"),
    writeln("\nAtualizar Disciplina:\n    Caso deseje que alterar alguma informacao de uma\n    disciplina já cadastrada, basta atualiza-la;"),
    writeln("\nRemover Disciplina: Remove uma Disciplina já cadastrada;"),
    writeln("\nReset: Ira resetar todo o programa."),
    writeln("\n-----------------------------------------------------------\n"),
    writeln("Então... Ja ta preparado pra se organizar nesse periodo?"),
    write("\nVamos lá, basta apenas pressionar 'a' para voltar a pagina\ninicial e cadastrar suas disciplinas e compromissos."),
    get_single_char(Action),
    (left(Action) -> mainScreen(ListaCompromissos, ListaDisciplinas, 0);
     tutorialScreen(ListaCompromissos, ListaDisciplinas)).

/* TELA DE TUTORIAL <- */

/* -> MANIPULAÇÃO DE ARQUIVOS */

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

readCompromissos(ListaCompromissos) :-
    open("Arquivos/Compromissos.dat", read, File),
    read(File, W),
    close(File),
    ListaCompromissos = W.

killRunning(ListaCompromissos, ListaDisciplinas) :-
    write_list_to_file("Arquivos/Disciplinas.dat", ListaDisciplinas),
    write_list_to_file("Arquivos/Compromissos.dat", ListaCompromissos).

resetSystem :-
    write_list_to_file("Arquivos/Disciplinas.dat", []),
    write_list_to_file("Arquivos/Compromissos.dat", []),
    configuracoesScreen([], [], 0).

/* MANIPULAÇÃO DE ARQUIVOS <- */

main :-
    readDisciplinas(ListaDisciplinas),
    readCompromissos(ListaCompromissos),
    mainScreen(ListaCompromissos, ListaDisciplinas, 0),
    halt(0).