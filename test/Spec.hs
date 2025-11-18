module Main where

import qualified SDL3.Image as Image
import Test.Hspec

main :: IO ()
main = hspec $ do
    describe "Image" $ do
        it "correct version" $ do
            v <- Image.version
            v `shouldBe` (3, 3, 0)
