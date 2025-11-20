module Main where

import qualified SDL3.Image as Image
import Test.Hspec

main :: IO ()
main = hspec $ do
    describe "Image" $ do
        it "correct version" $ do
            v <- Image.version
            v `shouldBe` (3, 3, 0)
        it "can load an image" $ do
            _ <- Image.load "test/data/test.png"
            1 `shouldBe` 1

-- it "can load an image via IOStream" $ do
--     _ <- Image.load_IOStream "test/data/test.png"
--     1 `shouldBe` 1
