module Page (State (..), Page (..), DOMNode (..), Element (..), newElement, renderDomElement, writePageState) where

import Control.Monad (sequence)
import qualified Data.Map as M
import Data.IORef
import Control.Exception (try, SomeException)
import JSExports
import Asterius.Types

type State = M.Map JSString JSVal
data Page = Page State  [Element]
data DOMNode = DOMNode {nodeType :: String, parent :: String, content :: JSVal,  nodeId :: String, nodeStyle :: String} deriving (Show)
data Element = Element {params :: State, evaluate :: State -> IO (DOMNode)}

renderDomElement :: IORef (Page) -> Element -> IO (Element)
renderDomElement page element = do
  (Page state _) <- readIORef page
  node <- (evaluate element) state
  if (not $ foldr (&&) True $ M.mapWithKey (\name val -> (M.lookup name state) == (Just val)) (params element))
    then do
      possibleError <- try (updateNode (toJSString $ parent node) (content node) (toJSString $ nodeType node) (toJSString $ nodeId node) (toJSString $ nodeStyle node)) :: IO (Either SomeException ())
      case possibleError of
        Right () -> do return ()
        Left e -> do return ()
   else return ()
  return $ Element {params = M.mapWithKey (\k d -> M.findWithDefault d k state) $ params element, evaluate = (evaluate element)}

--findElementsWithParam param list elem  = if (M.member (toJSString param) (params elem)) then list ++ [elem] ++ (foldr (++) [] (fmap (findElementsWithParam param list) (subElements elem))) else list ++ (foldr (++) [] (fmap (findElementsWithParam param list) (subElements elem)))

writePageState :: IORef (Page) -> String -> JSVal -> IO ()
writePageState pageRef key val = do
  (Page state elems) <- readIORef pageRef
  let newState = (M.insert (toJSString key) val state)
  writeIORef pageRef (Page newState elems) -- write before to update state for subelements
  newElems <- sequence $ fmap (renderDomElement pageRef) (filter (\elem -> M.member (toJSString key) (params elem)) elems)
  writeIORef pageRef (Page newState newElems)
  return ()

newElement id parent dependencies htmlType htmlContentStatement cssContentStatement  = Element{
                                                                          params = M.fromList $ fmap (\name -> (toJSString name, toJSVal $ toJSString  "uninitialized")) dependencies,
                                                                          evaluate = (\state -> do
                                                                                         newContent <- htmlContentStatement state
                                                                                         newCss <- cssContentStatement state
                                                                                         return $ DOMNode {
                                                                                           nodeType = htmlType,
                                                                                           parent = parent,
                                                                                           nodeId = id,
                                                                                           content = newContent,
                                                                                           nodeStyle = newCss})
                                                                     }
