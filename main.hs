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
--    ok $ (toResponse "dupa") {rsHeaders = mkHeaders [("Access-Control-Allow-Origin", "*")]}
--    msum [handlerWithAdditions, handlerSimple]
    handlerSimple

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
        ecode' <- system $ "cd " ++ td ++ "&& (tar zxf add.tar.gz && ghc --make file.hs >/dev/null && ./file) > temporary 2>&1"
        str' <- readFile $ combine td "temporary" 
        return (ecode', str')
--        system $ "( cd " ++ td ++ " && tar zxf add.tar.gz &&  ghc --make file.hs &&  ./file.hs) >> temporary 2>&1"
    str <- liftIO $ readFile $ combine "dupa" "temporary" 
    ok $ (toResponse $ show ecode ++ str) {rsHeaders = mkHeaders [("Access-Control-Allow-Origin", "*")]}

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
-- handler
