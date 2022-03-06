import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# certs_path = Path.expand("../certs", __DIR__)

# ssl_opts = [
#   client: [
#     cacertfile: "#{certs_path}/app.crt",
#     certfile: "#{certs_path}/client.crt",
#     keyfile: "#{certs_path}/client.key",
#     verify: :verify_peer
#   ],
#   server: [
#     cacertfile: "#{certs_path}/app.crt",
#     certfile: "#{certs_path}/client.crt",
#     keyfile: "#{certs_path}/client.key",
#     verify: :verify_peer
#   ]
# ]
# |> IO.inspect(label: "ssl opts")


node_list =
  "NODE_LIST"
  |> System.get_env()
  |> to_string()
  |> String.split(",")
  |> Enum.map(&String.trim/1)
  |> Enum.map(&String.split(&1, ":"))

node_list
|> Enum.map(fn [node_name, port] ->
    :epmdless_dist.add_node(String.to_atom(node_name), String.to_integer(port))
  end)

config :epmdless,
  transport: :inet,
  listen_port: System.get_env("EPMDLESS_DIST_PORT", "17012") |> String.to_integer()

config :libcluster,
  topologies: [
    example: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Epmd,
      # Configuration for the provided strategy. Optional.
      config: [hosts: node_list |> Enum.map(&List.first/1) |> Enum.map(&String.to_atom/1) ],
      # The function to use for connecting nodes. The node
      # name will be appended to the argument list. Optional
      connect: {:net_kernel, :connect_node, []},
      # The function to use for disconnecting nodes. The node
      # name will be appended to the argument list. Optional
      disconnect: {:erlang, :disconnect_node, []},
      # The function to use for listing nodes.
      # This function must return a list of node names. Optional
      list_nodes: {:erlang, :nodes, [:connected]},
    ]
  ]

# ERL_LIBS=_build/dev/lib/ EPMDLESS_DIST_PORT=17012 iex --cookie 123 --name "a@192.168.4.105" --erl "-proto_dist epmdless_proto" --erl "-start_epmd false"  --erl "-epmd_module epmdless_client" -S mix
# ERL_LIBS=_build/dev/lib/ EPMDLESS_DIST_PORT=17013 iex --cookie 123 --name "b@192.168.4.105" --erl "-proto_dist epmdless_proto" --erl "-start_epmd false"  --erl "-epmd_module epmdless_client" -S mix

# docker run --rm -it -p 17012:17012 -e HOST_IP=192.168.4.105 -e APP_NAME=a -e EPMDLESS_DIST_PORT=17012 -e NODE_LIST=a@192.168.4.105:17012,b@192.168.4.105:17013  epmdless_test:1.0 sh
# docker run --rm -it -p 17013:17013 -e HOST_IP=192.168.4.105 -e APP_NAME=b -e EPMDLESS_DIST_PORT=17013 -e NODE_LIST=a@192.168.4.105:17012,b@192.168.4.105:17013  epmdless_test:1.0 sh
