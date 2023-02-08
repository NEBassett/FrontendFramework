module JSExports
  (getTime,
   connectToMainLoop,
   add,
   makeCallback,
   setPropertyId,
   destroyNode,
   updateNode,
   createRootNode,
   setPropertyBody,
   toJSVal) where

import Asterius.Types

toJSVal (JSString val) = val

foreign import javascript 
   "(() => {                                    \
   \   return + new Date();          \
   \ })()"
   getTime ::  IO JSVal

foreign import javascript 
   "(() => {                                    \
   \   setInterval($1, 20);            \
   \ })()"
   connectToMainLoop :: JSFunction -> IO ()

foreign import javascript 
   "$1 + $2"
   add :: JSVal -> JSVal -> IO (JSVal)

foreign import javascript "wrapper" makeCallback :: IO () -> IO JSFunction

foreign import javascript 
   "(() => {                                    \
   \   document.getElementById($1).style.setProperty($2, $3);            \
   \ })()"
   setPropertyId :: JSString -> JSString -> JSString -> IO ()

foreign import javascript
   "(() => {                                    \
   \   var elem = document.getElementById($2);          \
   \   if (elem) {elem.remove();}                                             \
   \ })()"
   destroyNode :: JSString -> JSString -> IO ()

foreign import javascript 
   "(() => {                                    \
   \   document.body.style.setProperty($1, $2);            \
   \ })()"
   setPropertyBody :: JSString -> JSString -> IO ()

foreign import javascript 
   "(() => {                                    \
   \   const d = document.createElement($3); \
   \   d.id = $4; \
   \   d.innerHTML = $2; \
   \   d.setAttribute(\"style\", $5);                      \
   \   document.getElementById($1).appendChild(d);            \
   \ })()"
   createNode :: JSString -> JSString -> JSString -> JSString -> JSString -> IO ()

foreign import javascript safe
   "(() => {                                    \
   \   try{const d = document.getElementById($4) || document.createElement($3); \
   \   d.id = $4; \
   \   d.innerHTML = $2; \
   \   d.setAttribute(\"style\", $5);                      \
   \   document.getElementById($1).appendChild(d); }  catch {}         \
   \ })()"
   updateNode :: JSString -> JSVal  -> JSString -> JSString -> JSString -> IO ()

foreign import javascript 
   "(() => {                                    \
   \   const d = document.createElement('div'); \
   \   d.id = 'root'; \
   \   document.body.appendChild(d);            \
   \ })()"
   createRootNode :: IO ()
