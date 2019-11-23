-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

import Node

main :: IO ()
main = node NodeConfig { nodePort=5472, hostPort=5473 }
