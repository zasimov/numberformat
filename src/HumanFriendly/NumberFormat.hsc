{-# LANGUAGE ForeignFunctionInterface #-}
module HumanFriendly.NumberFormat(initNumberFormat, decimalPoint, getDecimalPoint, showFloat, showDouble) where

#include <locale.h>

import Foreign.Storable
import Foreign.C.String (peekCString, CString, withCString)
import Foreign.C.Types
import Foreign.Ptr

-- see man -s7 localeconv
-- struct lconv representation
data LocaleConvStruct = LocaleConvStruct String

instance Storable LocaleConvStruct where
    alignment _ = #{alignment struct lconv}
    sizeOf _ = #{size struct lconv}
    peek ptr = do
        decimal_point_ <- #{peek struct lconv, decimal_point} ptr
        decimal_point <- peekCString decimal_point_
        return (LocaleConvStruct decimal_point)
    -- NOTE: Warning!
    -- pokeElemOff, pokeByteOf is not defined!


foreign import ccall "locale.h localeconv" c_localeconv :: IO (Ptr LocaleConvStruct)

foreign import ccall "local.h setlocale" c_setlocale :: CInt -> CString -> IO CString

-- |initNumberFormat initializes "decimal point" for current locale.
-- current locale determines using environment variables.
initNumberFormat :: IO ()
initNumberFormat = do
     withCString "" $ \c -> do
         c_setlocale (fromIntegral #{const LC_NUMERIC}) c
         return ()

defaultPoint = '.'

-- |decimalPoint returns "current" decimal point.
-- You should use initNumberFormat to initialize "decimal_point".
-- Also you can use getDecimalPoint function.
decimalPoint :: IO Char
decimalPoint = do
  lconv_ <- c_localeconv
  (LocaleConvStruct dp) <- peek lconv_
  case dp of
      [point] -> return point
      _ -> return defaultPoint

-- |getDecimalPoint initializes locale and returns decimal point.
getDecimalPoint = do
  initNumberFormat
  decimalPoint

-- |showFloat returns locale-specific float representation.
-- TODO: That's very bad implementation =)
showFloat :: Char -> Float -> String
showFloat dp f =
    let repl '.' = dp
        repl c = c
    in map repl (show f)

-- |showDouble returns locale-specific float representation.
-- TODO: That's very bad implementation =)
showDouble :: Char -> Double -> String
showDouble dp d =
    let repl '.' = dp
        repl c = c
    in map repl (show d)