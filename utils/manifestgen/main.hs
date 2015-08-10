{-# LANGUAGE OverloadedStrings #-}
module Main ( main ) where

import Prelude hiding (putStr)
import Control.Arrow ((&&&))
import Data.ByteString (putStr)
import Data.List (intercalate, sort)
import Data.String (fromString)
import Data.Yaml
import System.Environment (getArgs)

omg cartridgeVersion torVersions = object
    [ ("Name", "tor")
    , ("Cartridge-Short-Name", "TOR")
    , ("Cartridge-Version", fromString cartridgeVersion)
    , ("Cartridge-Vendor", "mkollar")
    , ("Version", fromString $ last torVersions)
    , ("Versions", array $ map fromString torVersions)
    , ("License", "Tor's License")
    , ("License-Url", "https://gitweb.torproject.org/tor.git/plain/LICENSE")
    , ("Categories", array ["embedded", "tor"])
    , ("Provides", array $ map (fromString . ("tor - " ++)) torVersions)
    , ("Scaling", object [("Min", Number 1), ("Max", Number (-1))])
    , ("Source-Url", "https://github.com/xkollar/tor-openshift/archive/master.zip")
    ]

annotatel :: (a -> b) -> a -> (b, a)
annotatel = (&&& id)

sep :: (a -> Bool) -> [a] -> [[a]]
sep p = uncurry (:) . foldr (\ x (a,s) -> if p x then ([],a:s) else ((x:a),s) ) ([],[])

parseVer :: String -> [Int]
parseVer = map readInt . sep ('.'==) where
    readInt = read :: String -> Int

bumpVer :: [Int] -> [Int]
bumpVer [n] = [succ n]
bumpVer (x:s) = x : bumpVer s

bumpVerStr :: String -> String
bumpVerStr = intercalate "." . map show . bumpVer . parseVer

parseAndSortVersions :: String -> [String]
parseAndSortVersions = map snd . sort . map (annotatel $ parseVer) . lines

main' :: [String] -> IO ()
main' [oldCartridgeVersion] = do
    versions <- fmap parseAndSortVersions getContents
    putStr . encode $ omg (bumpVerStr oldCartridgeVersion) versions
main' _ = print "usage: $1 oldCartridgeVersion"

main :: IO ()
main = getArgs >>= main'
