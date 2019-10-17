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


endRun :: Disciplinas -> Compromissos -> IO ()
endRun disciplinas compromissos = do
   arq <- openFile "Arquivos/Disciplinas.txt" WriteMode
   hPutStrLn arq (show (disciplinas))
   hClose arq

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
getNovoNomeNota :: IO String
getNovoNomeNota = do 
   putStrLn("\nDigite um novo nome")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- getLine
   return x

getNovoValorNota :: IO Double
getNovoValorNota = do 
   putStrLn("\nDigite um novo valor de nota")
   hSetBuffering stdin LineBuffering
   hSetEcho stdin True
   x <- readLn
   return x

getNovoPesoNota :: IO Double
getNovoPesoNota = do 
   putStrLn("\nDigite um novo peso de nota")
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
   showDisciplinaScreen (disciplinas !! fromInteger(disciplina)) cursorx cursory 
   showRelatorioSituacao (disciplinas !! fromInteger(disciplina))
  
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

   run
