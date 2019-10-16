import System.IO 
import Control.Exception
import System.IO.Error 
import System.Process
import Control.Monad (when)

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


getKey :: IO [Char]
getKey = reverse <$> getKey' ""
  where getKey' chars = do
          char <- getChar
          more <- hReady stdin
          (if more then getKey' else return) (char:chars)
a1 = do
  system "clear"
  putStr("o1")

a2 = do
  system "clear"
  putStr("o2")


a4 = do
  system "clear"
  putStr("o4")


getNotasDisciplina :: Disciplina -> Notas 
getNotasDisciplina (Disciplina a b c notas) = notas


changeMainScreen :: Disciplinas -> Compromissos -> Integer -> IO()
changeMainScreen disciplinas compromissos cursor | cursor == 0 = do disciplinasScreen disciplinas compromissos 0 
                                                 | cursor == 1 = do a2            
                                                 | cursor == 2 = do configuracoesScreen disciplinas compromissos 0 
                                                 | cursor == 3 = do a4

                 
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
   showSimpleScreen optionsMainScreen cursor 0
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doMainScreen disciplinas compromissos cursor action


endRun :: IO ()
endRun = do
   system "clear"
   putStrLn("Obrigado por Utilizar")
   pause <- getKey
   system "clear"
   putStr ""

doExitScreen :: Disciplinas -> Compromissos -> String -> IO ()
doExitScreen disciplinas compromissos action | action == "s" = endRun
                                             | otherwise = mainScreen disciplinas compromissos 0
    
exitScreen :: Disciplinas -> Compromissos -> IO ()
exitScreen disciplinas compromissos = do
   system "clear"
   putStrLn("Digite (s) para encerrar a execucao ou (Outra tecla) para voltar para o menu");
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doExitScreen disciplinas compromissos action

changeConfiguracoesScreen :: Integer -> IO()
changeConfiguracoesScreen 0 = do a1
changeConfiguracoesScreen 1 = do a2
changeConfiguracoesScreen 2 = do a2
changeConfiguracoesScreen 3 = do a4

doConfiguracoesScreen :: Disciplinas -> Compromissos -> Integer -> [Char] -> IO()
doConfiguracoesScreen disciplinas compromissos cursor action | action == "\ESC[B" = configuracoesScreen disciplinas compromissos ((cursor+1) `mod` 4)
                                                    | action == "\ESC[A" && cursor /= 0 = configuracoesScreen disciplinas compromissos (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = configuracoesScreen disciplinas compromissos 3
                                                    | action == "\ESC[C" = changeConfiguracoesScreen cursor
                                                    | action == "\ESC[D" = mainScreen disciplinas compromissos 0
                                                    | otherwise = configuracoesScreen disciplinas compromissos cursor


configuracoesScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
configuracoesScreen disciplinas compromissos cursor = do
   
   system "clear"
   showSimpleScreen optionsConfiguracoesScreen cursor 0
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doConfiguracoesScreen disciplinas compromissos cursor action

doDisciplinasScreen :: Disciplinas -> Compromissos -> Integer -> [Char] -> IO()
doDisciplinasScreen disciplinas compromissos cursor action | action == "\ESC[B" = disciplinasScreen disciplinas compromissos ((cursor+1) `mod` toInteger(length disciplinas))
                                                            | action == "\ESC[A" && cursor /= 0 = disciplinasScreen disciplinas compromissos (cursor-1)
                                                            | action == "\ESC[A" && cursor == 0 = disciplinasScreen disciplinas compromissos (toInteger(length disciplinas) -1)
                                                            | action == "\ESC[C" = disciplinaScreen disciplinas compromissos cursor 0 0
                                                            | action == "\ESC[D" = mainScreen disciplinas compromissos 0
                                                            | otherwise = disciplinasScreen disciplinas compromissos cursor

disciplinasScreen :: Disciplinas -> Compromissos -> Integer -> IO ()
disciplinasScreen disciplinas compromissos cursor = do
   
   system "clear"
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

getNovoNomeNota :: IO String
getNovoNome = do 
   putStrLn("digite um novo nome")
   hSetEcho stdin True
   x <- getLine
   return x

doDisciplinaScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> Integer -> [Char] -> IO()
doDisciplinaScreen disciplinas compromissos disciplina cursorx cursory action 
   | action == "\ESC[B" = disciplinaScreen disciplinas compromissos disciplina ((cursorx+1) `mod` toInteger(length (getNotasDisciplina (disciplinas !! fromInteger(disciplina))))) cursory
   | action == "\ESC[A" && cursorx /= 0 = disciplinaScreen disciplinas compromissos disciplina (cursorx-1) cursory
   | action == "\ESC[A" && cursorx == 0 = disciplinaScreen disciplinas compromissos disciplina (toInteger(length (getNotasDisciplina (disciplinas !! fromInteger(disciplina)))) -1) cursory
   | action == "\ESC[C" = disciplinaScreen disciplinas compromissos disciplina cursorx ((cursory+1) `mod` 4)
   | action == "\ESC[D" && cursory == 0 = disciplinasScreen disciplinas compromissos 0
   | action == "\ESC[D" && cursory /= 0 = disciplinaScreen disciplinas compromissos disciplina cursorx (cursory-1)
   | action == "a" && cursory == 0 = do
      x <- getNovoNome
      disciplinaScreen (changeNota disciplinas disciplina cursorx 0 x) compromissos disciplina cursorx cursory 
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

   
disciplinaScreen :: Disciplinas -> Compromissos -> Integer -> Integer -> Integer -> IO ()
disciplinaScreen disciplinas compromissos disciplina cursorx cursory = do
   
   system "clear"
   showDisciplinaScreen (disciplinas !! fromInteger(disciplina)) cursorx cursory 
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   
   doDisciplinaScreen disciplinas compromissos disciplina cursorx cursory action

   
   

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

te1 :: Disciplina
te1 = (Disciplina "dd" "gg" "uu" [(Nota 0.33 0 "ii" True), (Nota 0.33 0 "ii" True), (Nota 0 0.33 "ii" True)])

te2 :: Disciplina
te2 = (Disciplina "dd1" "gg" "uu" [(Nota 0 0 "ii" True)])

te3 :: Disciplina
te3 = (Disciplina "dd2" "gg" "uu" [(Nota 0 0 "ii" True)])


put :: IO ()
put = do 
   arq <- openFile "Arquivos/Disciplinas.txt" WriteMode
   hPutStrLn arq (show[te1, te2, te3])
   hClose arq

main :: IO ()
main = do

   put
   run
