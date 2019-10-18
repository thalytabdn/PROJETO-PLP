import System.IO 
import Control.Exception
import System.IO.Error 
import System.Process
import Control.Monad (when)
import Text.Printf

type Peso = Double
type Pontos = Double
type NomeNota = String
type Considerar = Bool
data Nota = Nota Peso Pontos NomeNota Considerar
                                                   deriving (Show, Read)
                  

type Disciplinas = [Disciplina]                                                   
type NomeDisciplina = String
type Sala = String
type Professor = String
type Notas = [Nota]
data Disciplina = Disciplina NomeDisciplina Sala Professor Notas
                                                                   deriving (Show, Read)

type Compromissos = [Compromisso]       
type Titulo = String
type Detalhe = String
type Prioridade = String
type Status = String                                                            
data Compromisso = Compromisso Titulo Detalhe Prioridade Status
                                                                   deriving (Show, Read)

mediaAprovacaoPadrao :: Double
mediaAprovacaoPadrao = 7.0

mediaAprovacaoFinal :: Double
mediaAprovacaoFinal = 5.0;

mediaMinimaFinal :: Double 
mediaMinimaFinal = 4.0;

valorProvaFinal :: Double 
valorProvaFinal = 0.4;

getNotaMaximaFinal :: Double -> Double
getNotaMaximaFinal media = ((1 - valorProvaFinal)*media) + (valorProvaFinal*10)

getNotaMinimaFinal :: Double -> Double
getNotaMinimaFinal media = ((mediaAprovacaoFinal - ((1 - valorProvaFinal)*(media)))/valorProvaFinal)

getMaximoFaltante :: Double -> Double -> Double
getMaximoFaltante pesoConsiderado pesoDesconsiderado = ((pesoDesconsiderado *10)/(pesoConsiderado+pesoDesconsiderado))


getKey :: IO [Char]
getKey = reverse <$> getKey' ""
  where getKey' chars = do
          char <- getChar
          more <- hReady stdin
          (if more then getKey' else return) (char:chars)

tutorialScreen :: Disciplinas -> Compromissos -> IO ()
tutorialScreen disciplinas compromissos = do

   system "clear"
   putStrLn (
      "\nTutorial Geral do App de Gerenciamento: \n" ++ 
      "\nPara se Locomover no aplicativo utilize as teclas {W,A,S,D}" ++
      "\n-----------------------------------------------------------" ++
      "\n(Seta Superior) - Faz com que o curso se mova para cima" ++
      "\n(Seta Esquerda) - Volta para a pagina anterior" ++
      "\n(Seta Inferior) - Faz com que o curso se mova para baixo" ++
      "\n(Seta Direita)  - Passa para a proxima Pagina"  ++
      "\n( a)            - muda o valor de um dado ou confirma um evento" ++
      "\n-----------------------------------------------------------" ++
      "\nDisciplina: " ++
      "\n-----------------------------------------------------------" ++
      "\nAo acessar a pagina Disciplina você será direcionado para o local onde\nficará amazenado todas as suas Disciplinas e para acessá-las basta com as\nteclas selecionadas escolher qual Disciplina você deseja vizualizar e clicar 'D',\ndentro da disciplina selecionada você pode cadastrar as notas e o programa lhe\ndirar sua situcação na disciplina." ++
      "\n-----------------------------------------------------------"  ++
      "\nConfigurações: " ++
      "\n-----------------------------------------------------------" ++
      "\nAo acessar a pagina de Configuraçoes, você será direcionado para 4 opções\nde configuraçoes onde podera cadastrar, atualizar ou remover a disciplina\n\nCadastrar Disciplina: Ao selecionar a opção de castrar disciplina\nserá peguntados informações basicas sobre a disciplina.\n\nAtualizar Disciplina: Caso deseja que a disciplina já cadastrada mude alguma\ninformação basta atualizala\n\nRemover Disciplina: Remove uma Disciplina já cadastrada\n\nReset: Irá resetar todo o programa."++
      "\n-----------------------------------------------------------" ++
      "\nEntão você já estar preparado para se organizar durante seu período?\nEntão vamos lá, basta apenas clicar 'A' para voltar a pagina inicial e cadastrar suas disciplinas.")

   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey

   if (action == "\ESC[D" ) then do
      mainScreen disciplinas compromissos 0
   else 
      tutorialScreen disciplinas compromissos

getNotasDisciplina :: Disciplina -> Notas 
getNotasDisciplina (Disciplina a b c notas) = notas


changeMainScreen :: Disciplinas -> Compromissos -> Integer -> IO()
changeMainScreen disciplinas compromissos cursor | cursor == 0 = do disciplinasScreen disciplinas compromissos 0 
                                                 | cursor == 1 = do compromissosScreen disciplinas compromissos 0            
                                                 | cursor == 2 = do configuracoesScreen disciplinas compromissos 0 
                                                 | cursor == 3 = do tutorialScreen disciplinas compromissos

                 
optionsMainScreen :: [String]
optionsMainScreen = [" Disciplinas", " Compromissos", " Configuracoes", " Tutorial"]

optionsConfiguracoesScreen :: [String]
optionsConfiguracoesScreen = [" Cadastrar disciplina", " Atualizar disciplina", " Remover disciplina", " Resetar sistema"]

doMainScreen :: Disciplinas -> Compromissos -> Integer -> [Char] -> IO()
doMainScreen disciplinas compromissos cursor action | action == "\ESC[B" = mainScreen disciplinas compromissos ((cursor+1) `mod` 4)
                                                    | action == "\ESC[A" && cursor /= 0 = mainScreen disciplinas compromissos (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = mainScreen disciplinas compromissos 3
                                                    | action == "\ESC[C" = changeMainScreen disciplinas compromissos cursor
                                                    | action == "\ESC[D" = exitScreen disciplinas compromissos
                                                    | otherwise = mainScreen disciplinas compromissos cursor

showSimpleScreen :: [String] -> Integer -> Integer -> IO()
showSimpleScreen [] cursor contador = return ()
showSimpleScreen (o:os) cursor contador = do
   if contador == cursor
      then 
      putStrLn("->" ++ o)
   else
      putStrLn("  " ++ o)
   showSimpleScreen os cursor (contador+1)

showDisciplinasScreen :: [Disciplina] -> Integer -> Integer -> IO()
showDisciplinasScreen [] cursor contador = return ()
showDisciplinasScreen ((Disciplina a b c d):os) cursor contador = do
   if contador == cursor
      then 
      putStrLn("->" ++ (show a))
   else
      putStrLn("  " ++ (show a))
   showDisciplinasScreen os cursor (contador+1)

mainScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
mainScreen disciplinas compromissos cursor = do
   
   system "clear"
   putStrLn("\n|| Utilize os direcionais do teclado para mover o cursor ||\n")
   showSimpleScreen optionsMainScreen cursor 0
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doMainScreen disciplinas compromissos cursor action


endRun :: Disciplinas -> Compromissos -> IO ()
endRun disciplinas compromissos = do
   arq <- openFile "Arquivos/Disciplinas.txt" WriteMode
   hPutStrLn arq (show (disciplinas))
   hClose arq

   arq1 <- openFile "Arquivos/Compromissos.txt" WriteMode
   hPutStrLn arq1 (show (compromissos))
   hClose arq1

   system "clear"
   putStrLn("Obrigado por Utilizar")
   pause <- getKey
   system "clear"
   putStr ""

doExitScreen :: Disciplinas -> Compromissos -> String -> IO ()
doExitScreen disciplinas compromissos action | action == "s" = endRun disciplinas compromissos
                                             | otherwise = mainScreen disciplinas compromissos 0
    
exitScreen :: Disciplinas -> Compromissos -> IO ()
exitScreen disciplinas compromissos = do
   system "clear"
   putStrLn("Digite (s) para encerrar a execucao ou (Outra tecla) para voltar para o menu");
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doExitScreen disciplinas compromissos action

changeConfiguracoesScreen :: Disciplinas -> Compromissos -> Integer -> IO()
changeConfiguracoesScreen disciplinas compromissos cursor
   | cursor == 0 = cadastroDisciplinaScreen disciplinas compromissos
   | cursor == 1 = alteraDisciplinasScreen disciplinas compromissos 0
   | cursor == 2 = excluiDisciplinasScreen disciplinas compromissos 0
   | cursor == 3 = resetSystemScreen disciplinas compromissos


doConfiguracoesScreen :: Disciplinas -> Compromissos -> Integer -> [Char] -> IO()
doConfiguracoesScreen disciplinas compromissos cursor action | action == "\ESC[B" = configuracoesScreen disciplinas compromissos ((cursor+1) `mod` 4)
                                                    | action == "\ESC[A" && cursor /= 0 = configuracoesScreen disciplinas compromissos (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = configuracoesScreen disciplinas compromissos 3
                                                    | action == "\ESC[C" = changeConfiguracoesScreen disciplinas compromissos cursor
                                                    | action == "\ESC[D" = mainScreen disciplinas compromissos 0
                                                    | otherwise = configuracoesScreen disciplinas compromissos cursor


configuracoesScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
configuracoesScreen disciplinas compromissos cursor = do
   
   system "clear"
   putStrLn ("\n|| Aperte (Seta Direita) para escolher qual Opcao acessar ||\n")
   showSimpleScreen optionsConfiguracoesScreen cursor 0
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doConfiguracoesScreen disciplinas compromissos cursor action

doDisciplinasScreen :: Disciplinas -> Compromissos -> Integer -> [Char] -> IO()
doDisciplinasScreen disciplinas compromissos cursor action | action == "\ESC[B" = disciplinasScreen disciplinas compromissos ((cursor+1) `mod` toInteger(length disciplinas))
                                                            | action == "\ESC[A" && cursor /= 0 = disciplinasScreen disciplinas compromissos (cursor-1)
                                                            | action == "\ESC[A" && cursor == 0 = disciplinasScreen disciplinas compromissos (toInteger(length disciplinas) -1)
                                                            | action == "\ESC[C" && (length disciplinas) > 0 = disciplinaScreen disciplinas compromissos cursor 0 0
                                                            | action == "\ESC[D" = mainScreen disciplinas compromissos 0
                                                            | otherwise = disciplinasScreen disciplinas compromissos cursor

disciplinasScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
disciplinasScreen disciplinas compromissos cursor = do
   
   system "clear"
   putStrLn "\n|| Se mova com o direcional do teclado  ||\n|| Aperte (Seta Direita) para entrar nas opcoes ||\n"
   showDisciplinasScreen disciplinas cursor 0
  
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doDisciplinasScreen disciplinas compromissos cursor action

showNotaCursor :: Nota -> Integer -> IO ()
showNotaCursor (Nota peso pontos nomeNota considerar) cursory = do 
   if (cursory == 0) then 
      putStrLn ("->" ++ nomeNota ++ " -   " ++ show(pontos) ++ " -   " ++ show(peso) ++ " % -   " ++ show(considerar))
   else if (cursory == 1) then
      putStrLn ("  " ++ nomeNota ++ " - ->" ++ show(pontos) ++ " -   " ++ show(peso) ++ " % -   " ++ show(considerar))
   else if (cursory == 2) then
      putStrLn ("  " ++ nomeNota ++ " -   " ++ show(pontos) ++ " - ->" ++ show(peso) ++ " % -   " ++ show(considerar))
   else  
      putStrLn ("  " ++ nomeNota ++ " -   " ++ show(pontos) ++ " -   " ++ show(peso) ++ " % - ->" ++ show(considerar))

----------------------------------------------------------------------------------------------
changeNotaDisciplina :: Notas -> Integer -> Integer -> String -> Notas
changeNotaDisciplina [] nota contador novoNome = []
changeNotaDisciplina ((Nota peso pontos nomeNota considerar):os) nota contador novoNome
   | contador == nota = (Nota peso pontos novoNome considerar) : changeNotaDisciplina os nota (contador+1) novoNome
   | otherwise = (Nota peso pontos nomeNota considerar) : changeNotaDisciplina os nota (contador+1) novoNome

changeNota :: Disciplinas -> Integer -> Integer -> Integer -> String -> Disciplinas
changeNota [] disciplina nota contador novoNome = []
changeNota ((Disciplina a b c notas):os) disciplina nota contador novoNome
   | contador == disciplina = (Disciplina a b c (changeNotaDisciplina notas nota 0 novoNome)) : changeNota os disciplina nota (contador+1) novoNome
   | otherwise = (Disciplina a b c notas) : changeNota os disciplina nota (contador+1) novoNome


changeValorNotaDisciplina :: Notas -> Integer -> Integer -> Double -> Notas
changeValorNotaDisciplina [] nota contador novaNota  = []
changeValorNotaDisciplina ((Nota peso pontos nomeNota considerar):os) nota contador novaNota
   | contador == nota = (Nota peso novaNota nomeNota considerar) : changeValorNotaDisciplina os nota (contador+1) novaNota
   | otherwise = (Nota peso pontos nomeNota considerar) : changeValorNotaDisciplina os nota (contador+1) novaNota


changeValorNota :: Disciplinas -> Integer -> Integer -> Integer -> Double -> Disciplinas
changeValorNota [] disciplina nota contador novaNota = []
changeValorNota ((Disciplina a b c notas):os) disciplina nota contador novaNota
   | contador == disciplina = (Disciplina a b c (changeValorNotaDisciplina notas nota 0 novaNota)) : changeValorNota os disciplina nota (contador+1) novaNota
   | otherwise = (Disciplina a b c notas) : changeValorNota os disciplina nota (contador+1) novaNota



changePesoNotaDisciplina :: Notas -> Integer -> Integer -> Double -> Notas
changePesoNotaDisciplina [] nota contador novoPeso  = []
changePesoNotaDisciplina ((Nota peso pontos nomeNota considerar):os) nota contador novoPeso
   | contador == nota = (Nota novoPeso pontos nomeNota considerar) : changePesoNotaDisciplina os nota (contador+1) novoPeso
   | otherwise = (Nota peso pontos nomeNota considerar) : changePesoNotaDisciplina os nota (contador+1) novoPeso


changePesoNota :: Disciplinas -> Integer -> Integer -> Integer -> Double -> Disciplinas
changePesoNota [] disciplina nota contador novoPeso = []
changePesoNota ((Disciplina a b c notas):os) disciplina nota contador novoPeso
   | contador == disciplina = (Disciplina a b c (changePesoNotaDisciplina notas nota 0 novoPeso)) : changePesoNota os disciplina nota (contador+1) novoPeso
   | otherwise = (Disciplina a b c notas) : changePesoNota os disciplina nota (contador+1) novoPeso

changeConsiderarNotaDisciplina :: Notas -> Integer -> Integer -> Notas
changeConsiderarNotaDisciplina [] nota contador   = []
changeConsiderarNotaDisciplina ((Nota peso pontos nomeNota considerar):os) nota contador 
   | contador == nota = (Nota peso pontos nomeNota (not considerar)) : changeConsiderarNotaDisciplina os nota (contador+1) 
   | otherwise = (Nota peso pontos nomeNota considerar) : changeConsiderarNotaDisciplina os nota (contador+1) 


changeConsiderarNota :: Disciplinas -> Integer -> Integer -> Integer -> Disciplinas
changeConsiderarNota [] disciplina nota contador = []
changeConsiderarNota ((Disciplina a b c notas):os) disciplina nota contador 
   | contador == disciplina = (Disciplina a b c (changeConsiderarNotaDisciplina notas nota 0 )) : changeConsiderarNota os disciplina nota (contador+1) 
   | otherwise = (Disciplina a b c notas) : changeConsiderarNota os disciplina nota (contador+1) 
---------------------------------------------------

getTituloCompromisso :: IO String
getTituloCompromisso = do
   putStrLn("\nDigite um Titulo para o compromisso")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getDetalhesCompromisso :: IO String
getDetalhesCompromisso = do
   putStrLn("\nDigite os Detalhes do compromisso")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getPrioridadeCompromisso :: IO String
getPrioridadeCompromisso = do
   putStrLn("\nDigite a Prioridade do compromisso")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getStatusCompromisso :: IO String
getStatusCompromisso = do
   putStrLn("\nDigite o atual Status do compromisso")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getNovoNomeNota :: IO String
getNovoNomeNota = do 
   putStrLn("\nDigite um Nome para a Nota")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getNovoNomeDisciplina :: IO String
getNovoNomeDisciplina = do 
   putStrLn("\nDigite um novo Nome de disciplina")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getNovoProfessorDisciplina :: IO String
getNovoProfessorDisciplina = do 
   putStrLn("\nDigite um nome para o professor")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getNovaSalaDisciplina :: IO String
getNovaSalaDisciplina = do 
   putStrLn("\nDigite o Identificador da sala")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getNovoNumerosNotas :: IO Integer
getNovoNumerosNotas = do 
   putStrLn("\nDigite a Quantidade de notas esperada")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- readLn
   return x

getNovoValorNota :: IO Double
getNovoValorNota = do 
   putStrLn("\nDigite um Valor para essa nota")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- readLn
   return x

getNovoPesoNota :: IO Double
getNovoPesoNota = do 
   putStrLn("\nDigite um Peso para essa nota")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- readLn
   return x
-------------------------------------------------------------
doDisciplinaScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> Integer -> [Char] -> IO()
doDisciplinaScreen disciplinas compromissos disciplina cursorx cursory action 
   | action == "\ESC[B" = disciplinaScreen disciplinas compromissos disciplina ((cursorx+1) `mod` toInteger(length (getNotasDisciplina (disciplinas !! fromInteger(disciplina))))) cursory
   | action == "\ESC[A" && cursorx /= 0 = disciplinaScreen disciplinas compromissos disciplina (cursorx-1) cursory
   | action == "\ESC[A" && cursorx == 0 = disciplinaScreen disciplinas compromissos disciplina (toInteger(length (getNotasDisciplina (disciplinas !! fromInteger(disciplina)))) -1) cursory
   | action == "\ESC[C" = disciplinaScreen disciplinas compromissos disciplina cursorx ((cursory+1) `mod` 4)
   | action == "\ESC[D" && cursory == 0 = disciplinasScreen disciplinas compromissos 0
   | action == "\ESC[D" && cursory /= 0 = disciplinaScreen disciplinas compromissos disciplina cursorx (cursory-1)
   | action == "a" && cursory == 0 = do
      x <- getNovoNomeNota
      disciplinaScreen (changeNota disciplinas disciplina cursorx 0 x) compromissos disciplina cursorx cursory
   | action == "a" && cursory == 1 = do
      x <- getNovoValorNota
      disciplinaScreen (changeValorNota disciplinas disciplina cursorx 0 x) compromissos disciplina cursorx cursory
   | action == "a" && cursory == 2 = do
      x <- getNovoPesoNota
      disciplinaScreen (changePesoNota disciplinas disciplina cursorx 0 x) compromissos disciplina cursorx cursory
   | action == "a" && cursory == 3 = 
      disciplinaScreen (changeConsiderarNota  disciplinas disciplina cursorx 0 ) compromissos disciplina cursorx cursory
   | otherwise = disciplinaScreen disciplinas compromissos disciplina cursorx cursory
                                                            
showNotaSemCursor :: Nota -> IO()
showNotaSemCursor (Nota peso pontos nomeNota considerar) = do
   putStrLn ("  " ++ nomeNota ++ " -   " ++ show(pontos) ++ " -   " ++ show(peso) ++ " % -   " ++ show(considerar))

showNotasScreen :: Notas -> Integer -> Integer -> Integer -> IO()
showNotasScreen [] _ _ _ = return ()
showNotasScreen (o:os) cursorx cursory contadorx = do
   if (contadorx == cursorx) then 
      showNotaCursor o cursory
   else
      showNotaSemCursor o
   showNotasScreen os cursorx cursory (contadorx+1)
   
showDisciplinaScreen :: Disciplina -> Integer -> Integer -> IO ()
showDisciplinaScreen (Disciplina a b c d) cursorx cursory = do
   putStrLn ("Disciplina: " ++ a)
   putStrLn ("Sala: " ++ b ++ " | Professor: " ++ c)
   putStrLn ("Avaliacao - nota - peso -|- Usar dado:")
   
   putStrLn("")
   
   showNotasScreen d cursorx cursory 0 

getPesoConsiderado :: Notas -> Double
getPesoConsiderado [] = 0
getPesoConsiderado ((Nota peso pontos nomeNota considerar): os) 
   | considerar == True = peso + getPesoConsiderado os
   | otherwise = 0 + getPesoConsiderado os
   
getPesoDesconsiderado :: Notas -> Double   
getPesoDesconsiderado [] = 0
getPesoDesconsiderado ((Nota peso pontos nomeNota considerar): os) 
   | considerar == True = 0 + getPesoDesconsiderado os
   | otherwise = peso + getPesoDesconsiderado os


getValorConsiderado :: Notas -> Double
getValorConsiderado [] = 0
getValorConsiderado ((Nota peso pontos nomeNota considerar): os) 
   | considerar == True = (peso*pontos) + getValorConsiderado os
   | otherwise = 0 + getValorConsiderado os
   
getValorDesconsiderado :: Notas -> Double   
getValorDesconsiderado [] = 0
getValorDesconsiderado ((Nota peso pontos nomeNota considerar): os) 
   | considerar == True = 0 + getValorDesconsiderado os
   | otherwise = (peso*pontos) + getValorDesconsiderado os 
   

getMediaConsiderada :: Double -> Double -> Double -> Double -> Double
getMediaConsiderada pesoC pesoD valorC valorD = (valorC) / (pesoD + pesoC)

getMediaGeral ::  Double -> Double -> Double -> Double -> Double
getMediaGeral pesoC pesoD valorC valorD = (valorC + valorD) / (pesoD + pesoC)

checaPesoTotalValido :: Double -> Double -> Bool
checaPesoTotalValido pc pd = (abs (100 - (pc + pd))) <= 0.1

relatorioNotasCompleto :: Double -> IO ()
relatorioNotasCompleto media 
   | media >= mediaAprovacaoPadrao = do
       putStr ("'Parabens' :D voce esta aprovado, com media: ")
       printf "%.2f\n" media
   
   | media < mediaMinimaFinal = do putStrLn "VISHI!! :( Voce ja esta 'Reprovado'"
   
   | otherwise = do
      let nFinalMaxima = getNotaMaximaFinal(media)
      let nFinalMinima = getNotaMinimaFinal (media)
      putStr("Voce esta na final precisando de: ") 
      printf "%.2f\n" nFinalMinima
      putStrLn(" para ser aprovado.\n")

      putStr("Podendo ter media maxima de: ")
      printf "%.2f\n" nFinalMaxima
      putStrLn ("caso tire 10 na final\n")

relatorioNotasParcial :: Double -> Double -> IO ()
relatorioNotasParcial maximoFaltante media 
   | (media >= mediaAprovacaoPadrao) = do
      putStr("'Parabens' :D voce esta aprovado com media: ")
      printf "%.2f\n" media
      putStrLn (",caso voce tire 0 nas proximas notas\n")

      putStr("Caso voce tire 100% nas proximas provas, sua media sera: ")
      printf "%.2f\n" (media + maximoFaltante)
      putStrLn("\n")

   | media < mediaAprovacaoPadrao && ((media + maximoFaltante) >= mediaAprovacaoPadrao) = do
      putStr("Voce ainda nao foi 'aprovado', entretanto voce tem que acumular no minimo: ")
      printf "%.2f\n" (mediaAprovacaoPadrao - media) 
      putStrLn(", para ser aprovado.\n")

      putStr("Podendo ter no maximo a media de: ")
      printf "%.2f\n" (maximoFaltante + media) 
      putStrLn ("\n")

   | otherwise = do
      if (media+maximoFaltante < mediaAprovacaoFinal) then
         putStrLn("VISHI!! :( Voce ja esta 'Reprovado'\n")    
      else
         putStrLn("CUIDADO!! :O Voce ja esta na 'Final'\n")

relatorioNotas :: Double -> Double -> Double -> Double -> Double -> IO ()
relatorioNotas pesoConsiderado pesoDesconsiderado valorConsiderado valorDesconsiderado media 
   | pesoDesconsiderado == 0 = relatorioNotasCompleto media
   | otherwise = relatorioNotasParcial (getMaximoFaltante pesoConsiderado pesoDesconsiderado) media

showRelatorioSituacao :: Disciplina -> IO ()
showRelatorioSituacao disciplina = do

   let notas = (getNotasDisciplina disciplina)
   let pesoConsiderado = getPesoConsiderado notas
   let pesoDesconsiderado = getPesoDesconsiderado notas
   let valorConsiderado = getValorConsiderado notas
   let valorDesconsiderado = getValorDesconsiderado notas

   putStrLn ("\nMedia Acumulada: " ++ (show (getMediaGeral pesoConsiderado pesoDesconsiderado valorConsiderado valorDesconsiderado)))

   if (checaPesoTotalValido pesoConsiderado pesoDesconsiderado == True) then do
      putStrLn ("\nRelatorio de notas:\n")
      relatorioNotas pesoConsiderado pesoDesconsiderado valorConsiderado valorDesconsiderado (getMediaConsiderada pesoConsiderado pesoDesconsiderado valorConsiderado valorDesconsiderado)
            
   else 
      putStrLn "\nErro - O valor somado de todos os pesos deve corresponder a 100%"

   
disciplinaScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> Integer -> IO ()
disciplinaScreen disciplinas compromissos disciplina cursorx cursory = do
   
   system "clear"

   putStrLn  ("\n|| Aperte (Seta Esquerda) ou (Seta Direitr) para mover o cursor horizontalmente || \n"++
              "|| Aperte (Seta Superior) ou (Seta Inferior) para mover o cursor verticalmente || \n"++
              "|| Aperte (a) para mudar algum atributo de nota || \n"++
              "|| (Usar dado) indica se o codigo deve ou nao analisar a nota no relatorio (True)->sim (False)->nao, alterna-se com (a)!! || \n")

   showDisciplinaScreen (disciplinas !! fromInteger(disciplina)) cursorx cursory 
   showRelatorioSituacao (disciplinas !! fromInteger(disciplina))
  
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   
   doDisciplinaScreen disciplinas compromissos disciplina cursorx cursory action



changeTituloCompromisso :: Compromissos -> Integer -> Integer -> String -> Compromissos 
changeTituloCompromisso [] _ _ _ = []
changeTituloCompromisso ((Compromisso titulo detalhe prioridade status):os) compromisso contador novoValor 
   | contador == compromisso = (Compromisso novoValor detalhe prioridade status) : changeTituloCompromisso os compromisso (contador+1) novoValor
   | otherwise = Compromisso titulo detalhe prioridade status : changeTituloCompromisso os compromisso (contador+1) novoValor

changeDetalheCompromisso :: Compromissos -> Integer -> Integer -> String -> Compromissos 
changeDetalheCompromisso [] _ _ _ = []
changeDetalheCompromisso ((Compromisso titulo detalhe prioridade status):os) compromisso contador novoValor 
   | contador == compromisso = (Compromisso titulo novoValor prioridade status) : changeDetalheCompromisso os compromisso (contador+1) novoValor
   | otherwise = Compromisso titulo detalhe prioridade status : changeDetalheCompromisso os compromisso (contador+1) novoValor

changePrioridadeCompromisso :: Compromissos -> Integer -> Integer -> String -> Compromissos 
changePrioridadeCompromisso [] _ _ _ = []
changePrioridadeCompromisso ((Compromisso titulo detalhe prioridade status):os) compromisso contador novoValor 
   | contador == compromisso = (Compromisso titulo detalhe novoValor status) : changePrioridadeCompromisso os compromisso (contador+1) novoValor
   | otherwise = Compromisso titulo detalhe prioridade status : changePrioridadeCompromisso os compromisso (contador+1) novoValor

changeStatusCompromisso :: Compromissos -> Integer -> Integer -> String -> Compromissos 
changeStatusCompromisso [] _ _ _ = []
changeStatusCompromisso ((Compromisso titulo detalhe prioridade status):os) compromisso contador novoValor 
   | contador == compromisso = (Compromisso titulo detalhe prioridade novoValor) : changeStatusCompromisso os compromisso (contador+1) novoValor
   | otherwise = Compromisso titulo detalhe prioridade status : changeStatusCompromisso os compromisso (contador+1) novoValor

changeNomeDisciplina :: Disciplinas -> Integer -> Integer -> String -> Disciplinas
changeNomeDisciplina [] disciplina contador novoValor = []
changeNomeDisciplina ((Disciplina a b c notas):os) disciplina contador novoValor 
   | contador == disciplina = (Disciplina novoValor b c notas) : changeNomeDisciplina os disciplina  (contador+1) novoValor
   | otherwise = (Disciplina a b c notas) : changeNomeDisciplina os disciplina (contador+1) novoValor

changeProfessorDisciplina :: Disciplinas -> Integer -> Integer -> String -> Disciplinas
changeProfessorDisciplina [] disciplina contador novoValor = []
changeProfessorDisciplina ((Disciplina a b c notas):os) disciplina contador novoValor 
   | contador == disciplina = (Disciplina a novoValor c notas) : changeProfessorDisciplina os disciplina  (contador+1) novoValor
   | otherwise = (Disciplina a b c notas) : changeProfessorDisciplina os disciplina (contador+1) novoValor

changeSalaDisciplina :: Disciplinas -> Integer -> Integer -> String -> Disciplinas
changeSalaDisciplina [] disciplina contador novoValor = []
changeSalaDisciplina ((Disciplina a b c notas):os) disciplina contador novoValor 
   | contador == disciplina = (Disciplina a b novoValor notas) : changeSalaDisciplina os disciplina  (contador+1) novoValor
   | otherwise = (Disciplina a b c notas) : changeSalaDisciplina os disciplina (contador+1) novoValor

getNotaNula :: String -> Nota
getNotaNula nome = (Nota 0 0 nome False)

geraNotasNulas :: Integer -> Integer -> Notas
geraNotasNulas numi num 
   | num /= 0 = (getNotaNula ("Nota "++show(numi))):(geraNotasNulas (numi+1) (num-1))
   | otherwise = [] 

tirarNotas :: Notas -> Integer -> Notas
tirarNotas (o:os) num
   | num /= 0 = o:(tirarNotas os (num-1))
   | num == 0 = []

changeNumeroNotas :: Notas -> Integer -> Integer -> Notas
changeNumeroNotas notas tam valor 
   | valor > tam = notas ++ (geraNotasNulas (tam+1) (valor - tam))
   | valor < tam = tirarNotas notas valor
   | otherwise = notas

changeNumeroNotasDisciplina :: Disciplinas -> Integer -> Integer -> Integer -> Disciplinas   
changeNumeroNotasDisciplina [] disciplina contador novoValor = []
changeNumeroNotasDisciplina ((Disciplina a b c notas):os) disciplina contador novoValor 
   | contador == disciplina = (Disciplina a b c (changeNumeroNotas notas (toInteger(length notas)) novoValor) ):(changeNumeroNotasDisciplina os disciplina (contador+1) novoValor)
   | otherwise = (Disciplina a b c notas):(changeNumeroNotasDisciplina os disciplina (contador+1) novoValor)

retornaCursor :: Integer -> Integer -> String 
retornaCursor cursor actual 
   | cursor == actual = "->"
   | cursor /= actual = "  "             
 
showAlteraDisciplinaScreen :: Disciplina -> Integer -> IO ()
showAlteraDisciplinaScreen (Disciplina a b c d) cursor = do 
   putStrLn ("Escolha as informacoes para alterar")
   putStrLn ((retornaCursor cursor 0) ++" Nome disciplina: " ++ a)
   putStrLn ((retornaCursor cursor 1) ++" Nome professor: " ++ b)
   putStrLn ((retornaCursor cursor 2) ++" Sala: " ++ c)
   putStrLn ((retornaCursor cursor 3) ++" Quantidade Notas: " ++ show(length d))


   
doAlteraDisciplinaScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> String -> IO ()  
doAlteraDisciplinaScreen disciplinas compromissos disciplina cursor action 
   | action == "\ESC[B" = alteraDisciplinaScreen disciplinas compromissos disciplina ((cursor+1) `mod` 4)
   | action == "\ESC[A" && cursor /=  0 = alteraDisciplinaScreen disciplinas compromissos disciplina (cursor-1)
   | action == "\ESC[A" && cursor ==  0 = alteraDisciplinaScreen disciplinas compromissos disciplina 3
   | action == "\ESC[C" && cursor == 0 = do
       novoValor <- getNovoNomeDisciplina 
       alteraDisciplinaScreen (changeNomeDisciplina disciplinas disciplina 0 novoValor) compromissos disciplina cursor 
   | action == "\ESC[C" && cursor == 1 = do
       novoValor <- getNovoProfessorDisciplina 
       alteraDisciplinaScreen (changeProfessorDisciplina disciplinas disciplina 0 novoValor) compromissos disciplina cursor 
   | action == "\ESC[C" && cursor == 2 = do
       novoValor <- getNovaSalaDisciplina 
       alteraDisciplinaScreen (changeSalaDisciplina disciplinas disciplina 0 novoValor) compromissos disciplina cursor 
   | action == "\ESC[C" && cursor == 3 = do
       novoValor <- getNovoNumerosNotas
       alteraDisciplinaScreen (changeNumeroNotasDisciplina disciplinas disciplina 0 novoValor) compromissos disciplina cursor 
   | action == "\ESC[D" = alteraDisciplinasScreen disciplinas compromissos 0
   | otherwise = alteraDisciplinaScreen disciplinas compromissos disciplina cursor
 
alteraDisciplinaScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> IO () 
alteraDisciplinaScreen disciplinas compromissos disciplina cursor = do
   system "clear"
   showAlteraDisciplinaScreen (disciplinas !! (fromInteger disciplina)) cursor

   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
 
   doAlteraDisciplinaScreen disciplinas compromissos disciplina cursor action
 
doAlteraDisciplinasScreen :: Disciplinas -> Compromissos -> Integer -> String -> IO ()  
doAlteraDisciplinasScreen disciplinas compromissos cursor action 
   | action == "\ESC[B" = alteraDisciplinasScreen  disciplinas compromissos ((cursor+1) `mod` toInteger(length disciplinas))
   | action == "\ESC[A" && cursor /=  0 = alteraDisciplinasScreen disciplinas compromissos (cursor-1)
   | action == "\ESC[A" && cursor ==  0 = alteraDisciplinasScreen disciplinas compromissos (toInteger(length disciplinas) -1)
   | action == "\ESC[C" && (length disciplinas) > 0 = alteraDisciplinaScreen disciplinas compromissos cursor 0
   | action == "\ESC[D" = configuracoesScreen disciplinas compromissos 0
   | otherwise = alteraDisciplinasScreen disciplinas compromissos cursor
 
alteraDisciplinasScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
alteraDisciplinasScreen disciplinas compromissos cursor = do
   system "clear"
   putStrLn ("\n|| Aperte (Seta Direita) para escolher qual disciplina Editar ||\n")
   showDisciplinasScreen disciplinas cursor 0
 
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
 
   doAlteraDisciplinasScreen disciplinas compromissos cursor action

excluiDisciplina :: Disciplinas -> Integer -> Integer -> Disciplinas 
excluiDisciplina [] _ _ = []
excluiDisciplina (o:os) cursor contador
   | cursor == contador = excluiDisciplina os cursor (contador+1)
   | otherwise = o:excluiDisciplina os cursor (contador+1)



doExcluiDisciplinasScreen :: Disciplinas -> Compromissos -> Integer -> String -> IO ()
doExcluiDisciplinasScreen disciplinas compromissos cursor action 
   | action == "\ESC[B" = excluiDisciplinasScreen disciplinas compromissos  ((cursor+1) `mod` toInteger(length disciplinas))
   | action == "\ESC[A" && cursor /=  0 = excluiDisciplinasScreen disciplinas compromissos  (cursor-1)
   | action == "\ESC[A" && cursor ==  0 = excluiDisciplinasScreen disciplinas compromissos  (toInteger(length disciplinas) -1)
   | action == "\ESC[C" && (length disciplinas) > 0 = do
     
      putStrLn ("\nSe voce realmente deseja excluir esta disciplina entao a aperte (a)")
      hSetBuffering stdin NoBuffering
      hSetEcho stdin False
      action <- getKey

      if (action == "a") then do
         let newDisciplinas = (excluiDisciplina disciplinas cursor 0)
         
         system "clear"
         putStrLn ("Excluido com sucesso")
         hSetBuffering stdin NoBuffering
         hSetEcho stdin False
         actdion <- getKey
         putStr ("")
         excluiDisciplinasScreen newDisciplinas compromissos 0
      else
         excluiDisciplinasScreen disciplinas compromissos 0
   | action == "\ESC[D" = configuracoesScreen disciplinas compromissos 0
   | otherwise = excluiDisciplinasScreen disciplinas compromissos  cursor

excluiDisciplinasScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
excluiDisciplinasScreen disciplinas compromissos cursor = do
   system "clear"
   putStrLn ("\n|| Aperte (Seta Direita) para escolher qual disciplina Excluir ||\n")
   showDisciplinasScreen disciplinas cursor 0
 
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
 
   doExcluiDisciplinasScreen disciplinas compromissos cursor action

getSistemaNotasPadrao :: Notas 
getSistemaNotasPadrao = [(Nota 33.33 0 "Nota 1" False ), (Nota 33.33 0 "Nota 2" False ), (Nota 33.33 0 "Nota 3" False )]


cadastroDisciplinaScreen :: Disciplinas -> Compromissos -> IO ()
cadastroDisciplinaScreen disciplinas compromissos = do


   system "clear"

   nome <- getNovoNomeDisciplina
   professor <- getNovoProfessorDisciplina
   sala <- getNovaSalaDisciplina

   putStrLn("\nA disciplina foi iniciada com o sistema de notas padrao, (!!nao se preucupe ele pode ser modificado em configuracoes!!)")
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey

   let nota = getSistemaNotasPadrao


   configuracoesScreen (disciplinas++[(Disciplina nome professor sala nota)]) compromissos 0
   
   putStrLn("")

optionsCompromissosFixedScreen :: [String]
optionsCompromissosFixedScreen = [" CADASTRO"]

optionsCompromissoFixedScreen :: [String]
optionsCompromissoFixedScreen = ["REMOVER COMPROMISSO"]

optionsCompromissoScreen :: Compromisso -> [String]
optionsCompromissoScreen (Compromisso titulo detalhe prioridade status) = 
   [" Titulo   : "++show(titulo),
    " Detalhes  : " ++ show(detalhe),
    " Prioridade: " ++ show(prioridade),
    " Status:   " ++show(status)]


optionsCompromissosScreen :: Compromissos -> [String]
optionsCompromissosScreen [] = []
optionsCompromissosScreen ((Compromisso titulo detalhe prioridade status):os) = [" Titulo:   "++show(titulo)++"\n   Status:   " ++show(status)]++optionsCompromissosScreen os

removeCompromisso ::Compromissos -> Integer -> Integer -> Compromissos
removeCompromisso [] _ _ = []
removeCompromisso (o:os) cursor contador
   | cursor == contador = removeCompromisso os cursor (contador+1)
   | otherwise = o:removeCompromisso os cursor (contador+1)

removeCompromissoScreen :: Disciplinas -> Compromissos -> Integer -> IO ()   
removeCompromissoScreen disciplinas compromissos compromisso = do
   putStrLn("Caso voce realmente queira excluir aperte (a)")

   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey

   if (action == "a") then do
      let newCompromissos = (removeCompromisso compromissos compromisso 0)
      
      system "clear"
      putStrLn ("Excluido com sucesso")
      hSetBuffering stdin NoBuffering
      hSetEcho stdin False
      actdion <- getKey
      putStr ("")
      compromissosScreen disciplinas (newCompromissos) 0
   else
      compromissoScreen disciplinas compromissos compromisso 0
 
alteraCompromissosScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> IO ()
alteraCompromissosScreen disciplinas compromissos compromisso cursor 
   | cursor == 0 = do
      x <- getTituloCompromisso
      compromissoScreen disciplinas (changeTituloCompromisso compromissos compromisso 0 x) compromisso 0 
   | cursor == 1 = do
      x <-  getDetalhesCompromisso
      compromissoScreen disciplinas (changeDetalheCompromisso compromissos compromisso 0 x) compromisso 0 
   | cursor == 2 = do
      x <-  getPrioridadeCompromisso
      compromissoScreen disciplinas (changePrioridadeCompromisso compromissos compromisso 0 x) compromisso 0 
   | cursor == 3 = do
      x <- getStatusCompromisso
      compromissoScreen disciplinas (changeStatusCompromisso compromissos compromisso 0 x) compromisso 0 

doCompromissoScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> String -> IO ()
doCompromissoScreen disciplinas compromissos compromisso cursor action 
    | action == "\ESC[B" = compromissoScreen  disciplinas compromissos compromisso ((cursor+1) `mod` 5)
    | action == "\ESC[A" && cursor /=  0 = compromissoScreen disciplinas compromissos compromisso (cursor-1)
    | action == "\ESC[A" && cursor ==  0 = compromissoScreen disciplinas compromissos compromisso (4)
    | action == "\ESC[C" && cursor == 4  = removeCompromissoScreen disciplinas compromissos compromisso
    | action == "\ESC[C" && cursor /= 4 = alteraCompromissosScreen disciplinas compromissos compromisso cursor
    | action == "\ESC[D" = compromissosScreen disciplinas compromissos 0 
    | otherwise = compromissoScreen disciplinas compromissos compromisso cursor

showCompromissoScreen :: [String] -> Integer -> Integer -> IO ()
showCompromissoScreen [] cursor contador = putStr("")
showCompromissoScreen (o:os) cursor contador 
   | contador == cursor = do
      putStrLn("->" ++ o)
      showCompromissoScreen os cursor (contador+1)
   | otherwise = do 
      putStrLn("  " ++ o)
      showCompromissoScreen os cursor (contador+1)

compromissoScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> IO ()   
compromissoScreen disciplinas compromissos compromisso cursor = do
 
   system "clear"
   putStrLn ("\n|| Aperte (Seta Direita) para alterar os campos ou para excluir o Compromisso ||")
   putStrLn ("|| Seleccione um campo para atera-lo ||\n")
   showCompromissoScreen ((optionsCompromissoScreen (compromissos !! fromInteger(compromisso)))++optionsCompromissoFixedScreen) cursor 0
   putStr("")

   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey

   doCompromissoScreen disciplinas compromissos compromisso cursor action 

showCompromissosScreen :: [String] -> Integer -> Integer -> IO ()
showCompromissosScreen [] cursor contador = putStr("")
showCompromissosScreen (o:os) cursor contador 
   | contador == cursor = do
      putStrLn("\n->" ++ o)
      showCompromissosScreen os cursor (contador+1)
   | otherwise = do 
      putStrLn("\n  " ++ o)
      showCompromissosScreen os cursor (contador+1)

cadastroCompromissoScreen :: Disciplinas -> Compromissos -> IO ()
cadastroCompromissoScreen disciplinas compromissos = do

   system "clear"
   
   titulo <- getTituloCompromisso
   detalhes <- getDetalhesCompromisso
   prioridade <- getPrioridadeCompromisso

   compromissosScreen disciplinas (compromissos++([(Compromisso titulo detalhes prioridade "Em Andamento")])) 0



doCompromissosScreen :: Disciplinas -> Compromissos -> Integer -> String -> IO ()
doCompromissosScreen disciplinas compromissos cursor action 
   | action == "\ESC[B" = compromissosScreen  disciplinas compromissos ((cursor+1) `mod` (toInteger(length compromissos)+1))
   | action == "\ESC[A" && cursor /=  0 = compromissosScreen disciplinas compromissos (cursor-1)
   | action == "\ESC[A" && cursor ==  0 = compromissosScreen disciplinas compromissos (toInteger(length compromissos))
   | action == "\ESC[C" && cursor == 0  = cadastroCompromissoScreen disciplinas compromissos
   | action == "\ESC[C" && cursor /= 0 = compromissoScreen disciplinas compromissos (cursor-1) 0
   | action == "\ESC[D" = mainScreen disciplinas compromissos 0
   | otherwise = compromissosScreen disciplinas compromissos cursor

compromissosScreen :: Disciplinas-> Compromissos -> Integer -> IO ()
compromissosScreen disciplinas compromissos cursor = do

   system "clear"
   putStrLn ("\n || Aperte (d) para criar Compromissos ou Acessa-los ||\n")
   showCompromissosScreen (optionsCompromissosFixedScreen++(optionsCompromissosScreen compromissos)) cursor 0

   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey

   doCompromissosScreen disciplinas compromissos cursor action

resetSystemScreen :: Disciplinas -> Compromissos -> IO ()
resetSystemScreen disciplinas compromissos = do
   system "clear"
   putStrLn ("CASO DESEJE RESETAR O SISTEMA APERTE (a)")
   
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine

   if (x == "a") then do
      putStrLn ("SISTEMA RESETADO COM SUCESSO")
      x <- getLine
      configuracoesScreen [] [] 0
      
   else do
      putStrLn ("SISTEMA NAO RESETADO")
      x <- getLine
      configuracoesScreen disciplinas compromissos 0

run :: IO ()
run = do
   {catch (iniciar) error;}
   where
      iniciar = do
      {
         arq <- openFile "Arquivos/Disciplinas.txt" ReadMode;
         dados <- hGetLine arq;
         hClose arq;

         arq2 <- openFile "Arquivos/Compromissos.txt" ReadMode;
         dados2 <- hGetLine arq2;
         hClose arq2;

         mainScreen (read dados) (read dados2) 0;
         return ()
      }
      error = ioError 

main :: IO ()
main = do

   run
