module Run(mainLoop) where


import Control.Exception (try, SomeException)
import Page
import JSExports
import Control.Concurrent
import Asterius.Types
import Data.IORef

mainLoop :: IO (IORef Page) ->  IO ()
mainLoop page = do
  timeTry <- try getTime :: IO (Either SomeException JSVal) 
  case timeTry of
    Right time -> do
      pageRef <- page
      writeTry <- try (writePageState pageRef "time" time) :: IO (Either SomeException ())
      case writeTry of
        Right () -> do return ()
        Left e -> do return ()
    Left e -> do return ()
  threadDelay 2000
  mainLoop page
