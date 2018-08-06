--- BuildFromSource.hs.orig	2018-08-05 16:37:24.434519000 -0700
+++ BuildFromSource.hs	2018-08-05 16:51:34.234050000 -0700
@@ -183,7 +183,8 @@
 makeRepos artifactDirectory version repos =
   do  createDirectoryIfMissing True artifactDirectory
       setCurrentDirectory artifactDirectory
-      writeFile "cabal.config" "split-objs: True"
+      writeFile "cabal.config" "split-objs: True\n"
+      appendFile "cabal.config" "constraints: basement<0.0.8\n"
       root <- getCurrentDirectory
       mapM_ (uncurry (makeRepo root)) repos
 
