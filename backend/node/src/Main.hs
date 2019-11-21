import Node

main :: IO ()
main = node NodeConfig { nodePort=5472, hostPort=5473 }
