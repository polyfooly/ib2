import FrontendHost (hostFrontend)

frontendDir = "/home/syecpsa/github/ib2/dist-ghcjs/build/x86_64-linux/ghcjs-8.4.0.1/frontend-0.1.0.0/x/webapp/build/webapp/webapp.jsexe"
hostPort = 5473

main :: IO ()
main = hostFrontend hostPort frontendDir
