import Control.Monad (join)
import Data.Char (isHexDigit)
import Data.List.Split (chunksOf)
import Numeric (readHex)

myTail :: String -> String 
myTail "" = ""
myTail (_:xs) = xs

extractDigits :: String -> String
extractDigits = takeWhile isHexDigit . myTail . dropWhile (\c -> c /= 'x')

splitHex :: String -> [String]
splitHex = chunksOf 2

getAscii :: String -> Char
getAscii = toEnum . fst . head . readHex

--toChar :: Int -> Char
--toChar = toEnum

hexStringToString :: [String] -> String
hexStringToString = map getAscii 

convertHexToString :: String -> String
convertHexToString = hexStringToString . reverse . splitHex . extractDigits

main :: IO ()
main = do
    orig <- getContents
    let ls = reverse $ lines orig
        chks = map convertHexToString ls
        ans = join chks
    putStrLn ans
