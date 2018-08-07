--- BuildFromSource.hs.orig	2018-08-07 11:07:50.957704000 -0700
+++ BuildFromSource.hs	2018-08-07 11:20:47.322086000 -0700
@@ -197,7 +197,7 @@

       -- install all of the packages together in order to resolve transitive dependencies robustly
       -- (install the dependencies a bit more quietly than the elm packages)
-      cabal ([ "install", "-j", "--only-dependencies", "--ghc-options=\"-w\"" ]
+      cabal ([ "install", "-j", "--only-dependencies", "--ghc-options=\"-w\"", "--max-backjumps=-1" ]
              ++ (if version <= "0.15.1" then [ "--constraint=fsnotify<0.2" ] else [])
              ++ map fst repos)
       cabal ([ "install", "-j" ]
