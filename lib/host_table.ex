import Poison
defmodule HostTable do
  @ default_config %{"hosts" => %{}}
  @ default_host_config %{"metered" => false}

  @doc """
  Class attributes cannot be accessed outside the class,
  so this function simply returns the class attribute
  """
  def default_host_config() do @default_host_config end

  @doc """
  Implementing Agent.start_link
  """
  def start_link(config_file\\nil) do
    {config_hash,hosts} = cond do
      config_file != nil ->
        {:ok, body} = File.read(config_file)
        config_hash = Poison.Parser.parse!(body)
        hosts = config_hash
        |> Dict.get("hosts")
        |> Dict.keys()
        {config_hash, hosts}
      true ->
        config_hash = @default_config
        hosts = config_hash|>Dict.get("hosts")
        {config_hash, hosts}
      end
    num_hosts = hosts |> Enum.count()
    host_string = Enum.join(hosts, ",")
    IO.puts "Registering #{num_hosts} hosts under this LB"
    (num_hosts>0) && IO.puts "Hosts are: #{host_string}"
    Agent.start_link(fn -> config_hash end, name: __MODULE__)
  end

  @doc """
  Gets the configuration for a specific host.
  """
  def get_host(host_id) do
    Agent.get(
      __MODULE__,
      fn map ->
        IO.puts("map=#{inspect(map)}")
        map|>Dict.get("hosts")|>Dict.get(host_id)
      end
    )
  end

  @doc """
  Updates the health data for all hosts.
  """
  def update_all() do
    Enum.map(
      HostTable.get_hosts(),
      fn host_id ->
        HostTable.update_host(host_id)
      end)
  end

  @doc """
  Updates the health data for one host.
  The host must have already been registered with the load balancer
  """
  def update_host(host_id) do
    Agent.get(
      __MODULE__,
      fn map ->
        current_data = map
        |> Dict.get("hosts")
        |> Dict.get(host_id)
        metered = current_data |> Dict.get("metered")
        cond do
          metered == true ->
            # consult cloudwatch in a Proc here,
            # Proc must compute new_data, then calls `put_host`
            true
          metered == false ->
             # noop here
             false
          true ->
            # value for `metered` was never set, or set to something
            # that is not a bool.  this should never happen
            # TODO: raise an exception here
            nil
        end
      end)
  end

  @doc """
  Registers a new host with load balancer,
  along with an optional host config.
  """
  def put_host(host_id, host_config \\ @default_host_config) do
    Agent.update(
      __MODULE__,
      fn map ->
        hosts = map|>Dict.get("hosts")
        hosts = hosts|>Dict.put(host_id, host_config)
        map = map|>Dict.put("hosts", hosts)
        #IO.puts("map=#{inspect(map)}")
        map
      end )
  end

  @doc """
  Get a Enum of all the host_id registered with the loader balancer
  """
  def get_hosts() do
    Agent.get(
      __MODULE__,
      fn map->
        map
        |>Dict.get("hosts")
        |>Dict.keys()
      end)
  end
end