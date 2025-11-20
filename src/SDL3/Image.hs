{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

{- |

Module      : SDL.Image
Copyright   : (c) 2015 Siniša Biđin
License     : MIT
Maintainer  : sinisa@bidin.eu
Stability   : experimental

Bindings to the @SDL2_image@ library. These should allow you to load various
types of images as @SDL@ 'Surface's, as well as detect image formats.

You can safely assume that any monadic function listed here is capable of
throwing an 'SDLException' in case it encounters an error.
-}
module SDL3.Image (
  -- * Loading images

  --

  {- | Use the following functions to read any @PNG@, @JPG@, @TIF@, @GIF@,
  @WEBP@, @CUR@, @ICO@, @BMP@, @PNM@, @XPM@, @XCF@, @PCX@ and @XV@ formatted
  data.

  If you have @TGA@-formatted data, you might wish to use the functions from
  the <#tga following section> instead.
  -}
  load,
  decode,
  loadTexture,
  decodeTexture,

  -- * Loading TGA images

  --

  {- | #tga# Since @TGA@ images don't contain a specific unique signature, the
  following functions might succeed even when given files not formatted as
  @TGA@ images.

  Only use these functions if you're certain the inputs are @TGA@-formatted,
  otherwise they'll throw an exception.
  -}
  loadTGA,
  decodeTGA,
  loadTextureTGA,
  decodeTextureTGA,

  -- * Format detection
  formattedAs,
  format,
  Format (..),

  -- * Other
  version,
) where

import Control.Exception (SomeException (SomeException), bracket, throwIO)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Bits ((.|.))
import Data.ByteString (ByteString)
import Data.ByteString.Unsafe (unsafeUseAsCStringLen)
import Data.List (find)
import Data.Text (pack)
import Foreign.C.String (withCString)
import Foreign.C.Types (CBool, CInt)
import Foreign.Ptr (Ptr, castPtr, nullPtr)
import Foreign.Storable (peek)
import GHC.Generics (Generic)

-- import SDL (Renderer, SDLException (..), Surface (..), Texture)
-- import SDL.Internal.Exception (throwIfNull, throwIf_)
-- import SDL.Raw.Filesystem (rwFromConstMem, rwFromFile)
-- import SDL.Raw.Types (RWops)
import System.IO.Unsafe (unsafePerformIO)

-- import qualified SDL
-- import qualified SDL.Raw

import Data.Function ((&))
import Foreign (throwIfNull)
import SDL hiding (version)
import qualified SDL3.Raw.Image as CImage

-- flagToCInt :: InitFlag -> CInt
-- flagToCInt =
--   \case
--     InitJPG -> SDL.Raw.Image.IMG_INIT_JPG
--     InitPNG -> SDL.Raw.Image.IMG_INIT_PNG
--     InitTIF -> SDL.Raw.Image.IMG_INIT_TIF
--     InitWEBP -> SDL.Raw.Image.IMG_INIT_WEBP

{- | Loads any given file of a supported image type as a 'Surface', including
@TGA@ if the filename ends with @\".tga\"@.

If you have @TGA@ files that don't have names ending with @\".tga\"@, use
'loadTGA' instead.
-}
load :: (MonadIO m) => FilePath -> m (Ptr SDLSurface)
load path = liftIO $ withCString path CImage.load & throwIfNull "SDL3.Image.load"

{- | Same as 'load', but returning a 'Texture' instead.

For @TGA@ files not ending in ".tga", use 'loadTextureTGA' instead.
-}
loadTexture :: (MonadIO m) => SDLRenderer -> FilePath -> m (Maybe SDLTexture)
loadTexture r path =
  liftIO . bracket (load path) sdlDestroySurface $
    sdlCreateTextureFromSurface r

{- | Reads an image from a 'ByteString'.

This will work for all supported image types, __except TGA__. If you need to
decode a @TGA@ 'ByteString', use 'decodeTGA' instead.
-}
decode :: (MonadIO m) => ByteString -> m (Ptr SDLSurface)
decode bytes = liftIO
  . unsafeUseAsCStringLen bytes
  $ \(cstr, len) -> do
    iost <- sdlIOFromConstMem (castPtr cstr) (fromIntegral len)
    CImage.load_IO iost 0
      & throwIfNull "SDL.Image.load"

{- | Same as 'decode', but returning a 'Texture' instead.

If you need to decode a @TGA@ 'ByteString', use 'decodeTextureTGA' instead.
-}
decodeTexture :: (MonadIO m) => SDLRenderer -> ByteString -> m (Maybe SDLTexture)
decodeTexture r bytes =
  liftIO . bracket (decode bytes) sdlDestroySurface $
    sdlCreateTextureFromSurface r

{- | If your @TGA@ files aren't in a filename ending with @\".tga\"@, you can
load them using this function.
-}
loadTGA :: (MonadIO m) => FilePath -> m (Ptr SDLSurface)
loadTGA path =
  liftIO $
    throwIfNull "SDL3.Image.loadTGA" $
      do
        -- ios <- "rb" $ withCString path . flip sdlIOFromFile
        ios <- sdlIOFromFile "rb" path
        case ios of
          Nothing -> return nullPtr
          Just ios' -> CImage.loadTGA_IO ios'

-- | Same as 'loadTGA', only returning a 'Texture' instead.
loadTextureTGA :: (MonadIO m) => SDLRenderer -> FilePath -> m (Maybe SDLTexture)
loadTextureTGA r path =
  liftIO . bracket (loadTGA path) sdlDestroySurface $
    sdlCreateTextureFromSurface r

{- | Reads a @TGA@ image from a 'ByteString'.

Assumes the input is a @TGA@-formatted image.
-}
decodeTGA :: (MonadIO m) => ByteString -> m (Ptr SDLSurface)
decodeTGA bytes = liftIO
  . unsafeUseAsCStringLen bytes
  $ \(cstr, len) -> do
    ios <- sdlIOFromConstMem (castPtr cstr) (fromIntegral len)
    throwIfNull "SDL.Image.decodeTGA" $ CImage.loadTGA_IO ios

-- Same as 'decodeTGA', but returns a 'Texture' instead.
decodeTextureTGA :: (MonadIO m) => SDLRenderer -> ByteString -> m (Maybe SDLTexture)
decodeTextureTGA r bytes =
  liftIO . bracket (decodeTGA bytes) sdlDestroySurface $
    sdlCreateTextureFromSurface r

-- | Tests whether a 'ByteString' contains an image of a given format.
formattedAs :: Format -> ByteString -> Bool
formattedAs f bytes = unsafePerformIO
  . unsafeUseAsCStringLen bytes
  $ \(cstr, len) -> do
    ios <- sdlIOFromConstMem (castPtr cstr) (fromIntegral len)
    formatPredicate f ios >>= \case
      1 -> return True
      0 -> return False
      e -> do
        let err = "Expected 1 or 0, got " `mappend` show e `mappend` "."
        let fun = "IMG_is" `mappend` show f
        throwIO $ userError $ "SDL.Image.formattedAs" <> fun <> err

{- | Tries to detect the image format by attempting 'formattedAs' with each
possible 'Format'.

If you're trying to test for a specific format, use a specific 'formattedAs'
directly instead.
-}
format :: ByteString -> Maybe Format
format bytes = fst <$> find snd attempts
 where
  attempts = map (\f -> (f, formattedAs f bytes)) [minBound ..]

-- | Each of the supported image formats.
data Format
  = CUR
  | ICO
  | BMP
  | PNM
  | XPM
  | XCF
  | PCX
  | GIF
  | LBM
  | XV
  | JPG
  | PNG
  | TIF
  | WEBP
  deriving (Eq, Enum, Ord, Bounded, Generic, Read, Show)

-- Given an image format, return its raw predicate function.
formatPredicate :: (MonadIO m) => Format -> Ptr SDLIOStream -> m CBool
formatPredicate = \case
  CUR -> CImage.isCUR
  ICO -> CImage.isICO
  BMP -> CImage.isBMP
  PNM -> CImage.isPNM
  XPM -> CImage.isXPM
  XCF -> CImage.isXCF
  PCX -> CImage.isPCX
  GIF -> CImage.isGIF
  LBM -> CImage.isLBM
  XV -> CImage.isXV
  JPG -> CImage.isJPG
  PNG -> CImage.isPNG
  TIF -> CImage.isTIF
  WEBP -> CImage.isWEBP

-- | Gets the major, minor, patch versions of the linked @SDL2_image@ library.
version :: (Integral a, MonadIO m) => m (a, a, a)
version = liftIO $ do
  v <- CImage.getVersion
  let version = fromIntegral v
      major = version `div` 1000000
      remainder = version `mod` 1000000
      minor = remainder `div` 1000
      patch = remainder `mod` 1000
  pure (major, minor, patch)
