--- BuildFromSource.hs.orig	2018-08-06 17:14:47.921869000 -0700
+++ BuildFromSource.hs	2018-08-06 19:53:33.228240000 -0700
@@ -183,7 +183,8 @@
 makeRepos artifactDirectory version repos =
   do  createDirectoryIfMissing True artifactDirectory
       setCurrentDirectory artifactDirectory
-      writeFile "cabal.config" "split-objs: True"
+      writeFile "cabal.config" "split-objs: True\n"
+      appendFile "cabal.config" "constraints: basement<0.0.8\n"
       root <- getCurrentDirectory
       mapM_ (uncurry (makeRepo root)) repos
 
@@ -197,15 +198,15 @@
 
       -- install all of the packages together in order to resolve transitive dependencies robustly
       -- (install the dependencies a bit more quietly than the elm packages)
-      cabal ([ "install", "-j", "--only-dependencies", "--ghc-options=\"-w\"" ]
+      cabal ([ "install", "--only-dependencies", "--ghc-options=\"-w\"" ]
              ++ (if version <= "0.15.1" then [ "--constraint=fsnotify<0.2" ] else [])
              ++ map fst repos)
-      cabal ([ "install", "-j" ]
+      cabal ([ "install" ]
              ++ (if version <= "0.15.1" then [ "--ghc-options=\"-XFlexibleContexts\"" ] else [])
              ++ filter (/= "elm-reactor") (map fst repos))
 
       -- elm-reactor needs to be installed last because of a post-build dependency on elm-make
-      cabal [ "install", "-j", "elm-reactor" ]
+      cabal [ "install", "elm-reactor" ]
 
       return ()
 
