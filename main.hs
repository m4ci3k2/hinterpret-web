module Main where
import Control.Monad
import Happstack.Server 
import Control.Monad.Trans (MonadIO(liftIO))
import System.Cmd
import System.IO
import System.IO.Temp
import System.FilePath

myPolicy :: BodyPolicy
myPolicy = defaultBodyPolicy "/tmp" 1024000 1024000 1024000

handler  :: ServerPart Response
handler =
  do
    decodeBody myPolicy
    method POST
    msum [handlerWithAdditions, handlerSimple]

handlerWithAdditions  :: ServerPart Response
handlerWithAdditions =
  do
    addition <- look "addition"
    file <- look "file"
    (ecode,str) <- liftIO $ withSystemTempDirectory "hinterpw." $ \td -> do
        outf <- openFile (combine td "file.hs") WriteMode
        outa <- openFile (combine td "add.tar.gz") WriteMode
        hPutStr outf file
        hPutStr outa addition
        hFlush outf
        hFlush outa
        ecode' <- system $ "cd " ++ td ++ "&& ((base64 -d < add.tar.gz | tar zx) && ghc --make file.hs >/dev/null && ./file) > temporary 2>&1"
        str' <- readFile $ combine td "temporary" 
        return (ecode', str')
    ok $ (toResponse $ show ecode ++ "\n" ++ str) {rsHeaders = mkHeaders [("Access-Control-Allow-Origin", "*")]}

handlerSimple  :: ServerPart Response
handlerSimple =
  do
    file <- look "file"
    (ecode,str) <- liftIO $ withSystemTempDirectory "hinterpw." $ \td -> do
        outf <- openFile (combine td "file.hs") WriteMode
        hPutStr outf file
	hFlush outf
        ecode' <- system $ "cd " ++ td ++ "&& (ghc --make file.hs >/dev/null && ./file) > temporary 2>&1"
        str' <- readFile $ combine td "temporary" 
        return (ecode', str')
    ok $ (toResponse $ show ecode ++ "\n" ++ str) {rsHeaders = mkHeaders [("Access-Control-Allow-Origin", "*")]}

main :: IO ()
main =
  let config = nullConf in
  simpleHTTP nullConf $ handler 
