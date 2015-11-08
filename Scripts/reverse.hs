module Main where

import Data.Char (ord)
import Data.Bits ((.&.))
import Numeric (showHex)
import System.Environment (getArgs, getProgName)
import System.Exit (exitWith, ExitCode(..))

data TrimType = Trim
              | TrimSafe
	      | TrimNone
                deriving (Eq)

modifyLength :: String -> String
modifyLength s 
   | length s `mod` 4 == 0  = s
   | otherwise              = modifyLength $ '/' : s

splitInFours :: String -> [String]
splitInFours "" = []
splitInFours s  = take 4 s : splitInFours (drop 4 s)

toHexByte :: Char -> String
toHexByte c = 
    if length hexNum == 1
      then '0' : hexNum
      else hexNum
  where hexNum = showHex (ord c .&. 0xff) ""

hexify :: String -> String
hexify s = "0x" ++ concat (hexify' s)
  where hexify' = map toHexByte 

pushStr :: TrimType -> String -> String
pushStr t s = "push " ++ if t == TrimSafe && length s == 6
                            then "word " ++ s
			    else s

usage :: IO ()
usage = do
	progName <- getProgName
	putStrLn $ "Usage : " ++ progName ++ " [--trim | --trim-safe] <string>"


splitHead :: [String] -> [String]
splitHead [] = []
splitHead str@(x:xs)
    | lenX == 3 = (reverse . modSplit . splitAt 2 . reverse) x ++ xs
    | otherwise	= str
  where lenX = length x
        modSplit (a, b) = reverse a : [b]
        
pushify :: String -> TrimType -> IO ()
pushify s t = mapM_ putStrLn $ hexList s
  where splitArg
  	  | t == TrimSafe = splitHead . reverse . map reverse . splitInFours 
	  | otherwise     = splitInFours . reverse . modifyLength
        hexList arg = map (pushStr t . hexify) $ splitArg arg

trimLength :: String -> IO ()
trimLength s
      | l == 4    = return ()
      | otherwise = putStrLn $ "add  esp, 0x" ++ show l
   where l = 4 - length s `mod` 4

parse :: [String] -> IO ()
parse ["--help"]	 = usage
parse ["--trim", x] 	 = pushify x Trim >> trimLength x
parse ["--trim-safe", x] = pushify x TrimSafe
parse [x] 		 = pushify x TrimNone 
parse _			 = usage >> exitWith (ExitFailure 1)

main :: IO ()
main = parse =<< getArgs

