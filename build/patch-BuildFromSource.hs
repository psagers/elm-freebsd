--- BuildFromSource.hs.orig	2018-08-05 16:13:09.710412000 -0700
+++ BuildFromSource.hs	2018-08-05 16:15:22.215205000 -0700
@@ -198,6 +198,7 @@
       -- install all of the packages together in order to resolve transitive dependencies robustly
       -- (install the dependencies a bit more quietly than the elm packages)
       cabal ([ "install", "-j", "--only-dependencies", "--ghc-options=\"-w\"" ]
+             ++ ["--constraint=basement<0.0.8"]
              ++ (if version <= "0.15.1" then [ "--constraint=fsnotify<0.2" ] else [])
              ++ map fst repos)
       cabal ([ "install", "-j" ]
