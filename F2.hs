module F2 where
import Data.List
import Control.Monad 
{-
  1. Skapa en datatyp MolSeq för molekylära sekvenser som anger sekvensnamn , 
    sekvens(ensträng), och om det är DNA eller protein som sekvensen beskriver. 
    Du behöver inte begränsa vilka bokstäver som får finnas i en DNA/protein-sträng.-}
 
 
 
data MolSeq = MolSeq { sekvensnamn :: String
                     , sekvens :: String
                     , sekvensTyp :: SekvensTyp 
                     } deriving (Eq, Show, Read)
                    
data SekvensTyp = DNA | Protein deriving (Show, Eq, Read)                    
                    
                             
{- 
  2. Skriven funktion string2seq med typsignaturen String -> String -> MolSeq. 
  Dess första argument är ett namn och andra argument är en sekvens. 
  Denna funktion ska automatiskt skilja på DNA och protein, 
  genom att kontrollera om en sekvens bara innehåller A, C, G, samt T och 
  då utgå ifrån att det är DNA.-}
 
eDetDNA :: String -> Bool
eDetDNA [] = True
eDetDNA (x:xs)
   | x `elem` "ACGT" = eDetDNA xs
   | otherwise = False 
  
string2seq :: String -> String -> MolSeq
string2seq sekvensnamn sekvens     
   | eDetDNA sekvens       =   MolSeq sekvensnamn sekvens DNA
   | otherwise             =   MolSeq sekvensnamn sekvens Protein 
 
 
{-
eDetDNA :: String -> SekvensTyp
eDetDNA seqMol
   | all (`elem` nucleotides) seqMol = DNA
   | all (`elem` aminoacids) seqMol = Protein
   | otherwise = error "Fel!! Sekvens"  
  
string2seq :: String -> String -> MolSeq
string2seq sekvensnamn sekvens  =   MolSeq sekvensnamn sekvens (eDetDNA sekvens)
-}
 
 
 
{- 
  3. Skriv tre funktioner seqName,seqSequence,seqLength som tar en MolSeq och returnerar 
  namn, sekvens, respektive sekvenslängd. Du ska inte behöva duplicera din kod beroende 
  på om det är DNA eller protein! -}
 
 
--Funktion som returnerar Namn 
seqName :: MolSeq -> String
seqName (MolSeq namn _ _) = namn
 
--Fukntion som returnerar sekvens 
seqSequence :: MolSeq -> String
seqSequence (MolSeq _ sekvens _) = sekvens
 
--Funktion som beräknar Längden 
seqLength :: MolSeq -> Int
seqLength (MolSeq _ sekvens _ ) = length sekvens
 
--Funktion som returnerar typ
seqTyp :: MolSeq -> SekvensTyp
seqTyp (MolSeq _ _ sekvensTyp ) = sekvensTyp
 
 
{-
  4. Implementera seqDistance :: MolSeq -> MolSeq -> Double som jämför två DNA- sekvenser 
  eller två proteinsekvenser och returnerar deras evolutionära avstånd. 
  Om man försöker jämföra DNA med protein ska det signaleras ett fel med hjälp av 
  funktionen error.-}
 
seqDistance :: MolSeq -> MolSeq -> Double
seqDistance molA molB 
   | seqTyp molA /= seqTyp molB  = error "Fel!! Du försöker jämföra DNA med protein"
   | seqTyp molA == DNA     = användJukesCantor alfa
   | seqTyp molA == Protein = användPoissonModell alfa  
   where
        alfa = fromIntegral lengthDiff / fromIntegral length
        lengthDiff = beräknaHammingavståndet (seqSequence molA) (seqSequence molB)
        length = seqLength molA
 
{-
    α är andelen positioner där sekvenserna skiljer sig åt 
    (det normaliserade Hamming-avståndet mellan sekvenserna)
    Hammingavståndet mellan dessa är :
    "toned" och "roses" är 3.
-}    
 
beräknaHammingavståndet :: String -> String -> Int
beräknaHammingavståndet [] [] = 0
beräknaHammingavståndet (hA:tA) (hB:tB)
    | hA == hB  = 0 + beräknaHammingavståndet tA tB
    | otherwise = 1 + beräknaHammingavståndet tA tB
 
{-
  Enligt en känd och enkel modell som kallas Jukes-Cantor låter man avståndet da,
  b mellan två DNA-sekvenser a och b vara -}
  
användJukesCantor :: Double -> Double
användJukesCantor alfa
    | alfa <= 0.74   = -3/4 * log(1 - 4/3 * alfa)
    | otherwise                = 3.3
 
{-
   Det finns en nästan likadan modell (“Poisson-modellen”) för proteinsekvenser där 
   man sätter avståndet till-}
 
användPoissonModell :: Double -> Double
användPoissonModell alfa
    | alfa <= 0.94   = -19/20 * log(1 - 20 * alfa / 19)
    | otherwise                 = 3.7
 
 
{-Profiler och sekvenser-}
{- 
    1. Skapa en datatyp Profile för att lagra profiler. Datatypen ska lagra information 
    om den profil som lagras med hjälp av matrisen M (enligt beskrivningen ovan), 
    det är en profil för DNA eller protein, hur många sekvenser profilen är byggd ifrån, 
    och ett namn på profilen.-}
    
data Profile = Profile {matrisen :: [[(Char, Int)]]
                     ,moleType :: SekvensTyp
                     ,antalSekvenser :: Int
                     ,namn :: String
                     } deriving (Show)
 
 
{-
    2. Skriv en funktion molseqs2profile :: String -> [MolSeq] -> Profile 
    som returnerar en profil från de givna sekvenserna med den givna strängen som namn. 
    Som hjälp för att skapa profil-matrisen har du koden i figur 2. 
    Vid redovisning ska du kunna förklara exakt hur den fungerar, 
    speciellt raderna (i)-(iv). Skriv gärna kommentarer direkt in i koden inför 
    redovisningen, för så här kryptiskt ska det ju inte se ut!-}
    
molseqs2profile :: String -> [MolSeq] -> Profile
molseqs2profile s mlistan = Profile matrisen moleType antalSekvenser name
        where 
            matrisen = makeProfileMatrix mlistan
            moleType = seqTyp (head mlistan)
            antalSekvenser = length mlistan
            name = s
            
 
 
nucleotides = "ACGT"
aminoacids = sort "ARNDCEQGHILKMFPSTWYVX"
makeProfileMatrix :: [MolSeq] -> [[(Char,  Int)]] 
makeProfileMatrix [] = error "Empty sequence list" 
makeProfileMatrix sl = res
 where
   t = seqTyp (head sl) 
   n = length sl 
   defaults = if t == DNA then
                  zip nucleotides (replicate (length nucleotides) 0) 
                  
                  {- Rad (i) replicate skapar en lista med lika många element som 
                  antalet nukleotider, och lägger 0 överallt denna zippas sedan ihop 
                  med nucleotides, dvs en lista [(A,0), (C,0) ....] skapas-}
                  
              else
                  zip aminoacids (replicate (length aminoacids) 0)
                  
                 {- Rad (ii) som rad 1, fast med aminosyror istället. 
                 dvs en lista skapas med [(A, 0), (R, 0), (N, 0) ...]-}
                 
   strs = map seqSequence sl 
   
   {- Rad (iii)  strs deklareras till en lista som innehåller alla sekvenser 
   som matrisen skapas utifrån-}
   
   tmp1 = map (map (\x -> ((head x), (length x))) . group . sort)
                (transpose strs)  
                
                {- Rad (iv) transponera listan strs, dvs så vi får en lista K som 
                innehåller listor. Ks första element består då av första elementet 
                ur varje sekventer, andra elementet består av andra elementet ur varje 
                sekvens etc. skapa en sorterad map och gruppera elementen, dvs så att 
                alla A står bredvid varandra. mappa sedan denna med den transponerade 
                listan för att få -}
                 
   equalFst a b = (fst a) == (fst b)
   res = map sort (map (\l -> unionBy equalFst l defaults) tmp1)
 
 
 
 
{-
    3. Skriven funktion profileName :: Profile -> String som returnerar en profilsnamn, 
    och en funktion profileFrequency :: Profile -> Int -> Char -> Double som tar en profil p,
    en heltalsposition i, och ett tecken c, och returnerar den relativa frekvensen för 
    tecken c på position i i profilen p 
    (med andra ord, värdet på elementet mc,i i profilens matris M ).-}
 
profileName :: Profile -> String
profileName (Profile _ _ _ name) = name
 
 
profileFrequency :: Profile -> Int -> Char -> Double
profileFrequency (Profile matrisen _ antalSekvenser _ ) position tecken = fromIntegral antal / fromIntegral antalSekvenser
       where  antal = antalIMatris ( matrisen !! position) tecken
 
antalIMatris :: [(Char,  Int)] -> Char -> Int
antalIMatris (hE:tE) (tecken)
 | fst hE == tecken = snd hE
 | otherwise = antalIMatris tE tecken
 
 
{- 
    4. Skriv profileDistance :: Profile -> Profile -> Double . 
    Avståndetmellantvå profiler M och M′ mäts med hjälp av funktionen d(M,M′) 
    beskriven ovan.-}
 
profileDistance :: Profile -> Profile -> Double
profileDistance prof1 prof2 = summaMatriser matris1 matris2 prof1 prof2
        where  
               matris1 = matrisen prof1
               matris2 = matrisen prof2
 
summaMatriser :: [[(Char, Int)]] -> [[(Char, Int)]] -> Profile -> Profile -> Double
summaMatriser [] [] _ _ = 0
summaMatriser ma1 ma2 pr1 pr2 = ab + summaMatriser (tail ma1) (tail ma2) pr1 pr2
        where ab = absBelopp (head ma1) (head ma2) pr1 pr2
 
 
absBelopp :: [(Char, Int)] -> [(Char, Int)] -> Profile -> Profile -> Double
absBelopp [] [] _ _ = 0
absBelopp ma1 ma2 pr1 pr2 = abs(fMa1 - fMa2) + absBelopp (tail ma1) (tail ma2) pr1 pr2 
        where  
             fMa1 = fromIntegral (snd (head ma1)) / fromIntegral (antalSekvenser pr1)
             fMa2 = fromIntegral (snd (head ma2)) / fromIntegral (antalSekvenser pr2)
 
 
 
 
 
{-
   1. Implementera typklassen Evol och låt MolSeq och Profile bli instanser av Evol. 
   Alla instanser av Evol ska implementera en funktion distance som mäter avstånd 
   mellan två Evol, och en funktion name som ger namnet på en Evol. Finns det någon mer 
   funktion som man bör implementera i Evol? -}
 
 
class Evol objekt where
 name :: objekt -> String
 distance :: objekt -> objekt -> Double
 distanceMatrix :: [objekt] -> [(String, String, Double)]
 addRow :: [objekt] -> Int -> [(String, String, Double)]
 distanceMatrix [] = []
 distanceMatrix objekt =
  addRow objekt 0 ++ distanceMatrix (tail objekt)
 addRow objekt num
  | num < length objekt = (name a, name b, distance a b) : addRow objekt (num + 1)
  | otherwise = [] 
  where  
        a = head objekt
        b = objekt !! num
 
 
 
instance Evol MolSeq where
 name = seqName
 distance = seqDistance
 
instance Evol Profile where
 name = profileName
 distance = profileDistance
 
