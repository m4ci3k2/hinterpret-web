module Main where
import Control.Monad
import Happstack.Server 
import Control.Monad.Trans (MonadIO(liftIO))
import System.Cmd
import System.IO
import System.IO.Temp
import System.FilePath

myPolicy :: BodyPolicy
myPolicy = defaultBodyPolicy "/tmp" 0 1024000 1024000

handler  :: ServerPart Response
handler =
  do
    decodeBody myPolicy
    method POST
    msum [handlerWithAdditions, handlerSimple]

handlerWithAdditions  :: ServerPart Response
handlerWithAdditions =
  do
    file <- look "file"
    addition <- look "addition"
    ecode <- liftIO $ withSystemTempDirectory "hinterpw." $ \td -> do
        outf <- openFile (combine td "file.hs") WriteMode
        outa <- openFile (combine td "add.tar.gz") WriteMode
        hPutStr outf file
        hPutStr outa addition
        system "(tar zxf add.tar.gz &&  ghc --make file.hs &&  ./file.hs) > temporary 2>&1"
    str <- liftIO $ readFile "temporary" 
    ok $ toResponse $ show ecode ++ str

handlerSimple  :: ServerPart Response
handlerSimple =
  do
    file <- look "file"
    ecode <- liftIO $ withSystemTempDirectory "hinterpw." $ \td -> do
        outf <- openFile (combine td "file.hs") WriteMode
        hPutStr outf file
        system "(ghc --make file.hs && ./file) > temporary 2>&1"
    str <- liftIO $ readFile "temporary" 
    ok $ toResponse $ show ecode ++ str

main :: IO ()
main =
  let config = nullConf in
  simpleHTTP nullConf $ handler
