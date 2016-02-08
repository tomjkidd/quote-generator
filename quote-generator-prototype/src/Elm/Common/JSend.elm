module Common.JSend
    (JSend (..))
    where

type JSend a =
    JSend
        { status : String
        , data : a
        }
