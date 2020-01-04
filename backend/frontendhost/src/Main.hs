-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

import System.Environment
import Control.Lens

import FrontendHost (hostFrontend)

--frontendDir = "dist-ghcjs/build/x86_64-linux/ghcjs-8.4.0.1/frontend-0.1.0.0/x/webapp/build/webapp/webapp.jsexe"

main :: IO ()
main = do
    args <- getArgs
    let hostPort = 5473
        frontendDir = args ^? element 0

    case frontendDir of
        Just dir -> do
            putStrLn "Webserver started..."
            hostFrontend hostPort dir
        _ -> putStrLn "err: provide frontend .jsexe dir as first arg"
