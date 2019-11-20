import Node

config = NodeConfig {
  nodePort=5472,
  hostPort=5473
}

main :: IO ()
main = node config
