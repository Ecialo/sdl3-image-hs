{-|

Module      : SDL.Raw.Image
Copyright   : (c) 2015 Siniša Biđin
License     : MIT
Maintainer  : sinisa@bidin.eu
Stability   : experimental

Raw bindings to the @SDL2_image@ library. No error-handling is done here. For
more information about specific function behaviour, see the @SDL2_image@
documentation.

-}

{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE TemplateHaskell #-}

module SDL3.Raw.Image(
  -- * Version information
  getVersion,
  load
) where

#include <SDL3_image/SDL_image.h>

import Foreign.C.String       (CString)
import Foreign.C.Types        (CInt(..))
import Foreign.Ptr            (Ptr)
import Prelude         hiding (init)
import SDL (SDLSurface, SDLIOStream)
import SDL3.Raw.Helper         (liftF)

liftF "getVersion" "IMG_Version"
  [t|IO CInt|]

-- type InitFlags = CInt

-- pattern IMG_INIT_JPG  = #{const IMG_INIT_JPG}
-- pattern IMG_INIT_PNG  = #{const IMG_INIT_PNG}
-- pattern IMG_INIT_TIF  = #{const IMG_INIT_TIF}
-- pattern IMG_INIT_WEBP = #{const IMG_INIT_WEBP}


liftF "load" "IMG_Load"
  [t|CString -> IO (Ptr SDLSurface)|]

-- -- | Should the 'Ptr' 'IOStream' be freed after an operation? 1 for yes, 0 for no.
type Free = CBool

liftF "load_IO" "IMG_Load_IO"
  [t|Ptr SDLIOStream -> Free -> IO (Ptr SDLSurface)|]

-- | A case-insensitive desired format, e.g. @\"jpg\"@ or @\"PNG\"@.
type Format = CString

liftF "loadTyped_IO" "IMG_LoadTyped_IO"
  [t|Ptr SDLIOStream -> Free -> Format -> IO (Ptr SDLSurface)|]

liftF "loadCUR_IO"  "IMG_LoadCUR_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadICO_IO"  "IMG_LoadICO_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadBMP_IO"  "IMG_LoadBMP_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadPNM_IO"  "IMG_LoadPNM_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadXPM_IO"  "IMG_LoadXPM_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadXCF_IO"  "IMG_LoadXCF_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadPCX_IO"  "IMG_LoadPCX_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadGIF_IO"  "IMG_LoadGIF_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadJPG_IO"  "IMG_LoadJPG_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadTIF_IO"  "IMG_LoadTIF_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadPNG_IO"  "IMG_LoadPNG_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadTGA_IO"  "IMG_LoadTGA_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadLBM_IO"  "IMG_LoadLBM_IO"  [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadXV_IO"   "IMG_LoadXV_IO"   [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]
liftF "loadWEBP_IO" "IMG_LoadWEBP_IO" [t|Ptr SDLIOStream -> IO (Ptr SDLSurface)|]

-- liftF "isCUR"  "IMG_isCUR"  [t|Ptr RWops -> IO CInt|]
-- liftF "isICO"  "IMG_isICO"  [t|Ptr RWops -> IO CInt|]
-- liftF "isBMP"  "IMG_isBMP"  [t|Ptr RWops -> IO CInt|]
-- liftF "isPNM"  "IMG_isPNM"  [t|Ptr RWops -> IO CInt|]
-- liftF "isXPM"  "IMG_isXPM"  [t|Ptr RWops -> IO CInt|]
-- liftF "isXCF"  "IMG_isXCF"  [t|Ptr RWops -> IO CInt|]
-- liftF "isPCX"  "IMG_isPCX"  [t|Ptr RWops -> IO CInt|]
-- liftF "isGIF"  "IMG_isGIF"  [t|Ptr RWops -> IO CInt|]
-- liftF "isJPG"  "IMG_isJPG"  [t|Ptr RWops -> IO CInt|]
-- liftF "isTIF"  "IMG_isTIF"  [t|Ptr RWops -> IO CInt|]
-- liftF "isPNG"  "IMG_isPNG"  [t|Ptr RWops -> IO CInt|]
-- liftF "isLBM"  "IMG_isLBM"  [t|Ptr RWops -> IO CInt|]
-- liftF "isXV"   "IMG_isXV"   [t|Ptr RWops -> IO CInt|]
-- liftF "isWEBP" "IMG_isWEBP" [t|Ptr RWops -> IO CInt|]
