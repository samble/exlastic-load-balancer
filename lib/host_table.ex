
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
    config_hash = cond do
      config_file != nil ->
        {:ok, body} = File.read(config_file)
        config_hash = Poison.Parser.parse!(body)
      true ->
        config_hash = @default_config
      end
      hosts = config_hash
      |> Dict.get("hosts")
      |> Dict.keys()
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
  Return an integer rank based on host health, where the magnitude
  is based on the preference that this host ought to answer the
  current HTTP request to the load balancer.  This value should
  only be based on data directly available in host_dict and need
  no other computation.. host_dict is considered to already contain
  all the relevant/most recent data.
  """
  def rank_host(host_dict) do
    return 1
  end

  @doc """
  Based on all available host health data, choose the host that
  should answer the current HTTP request.
  """
  def choose_host() do
    Agent.get(
      __MODULE__,
      fn map ->
        hosts = HostTable.get_hosts()
        ranks = Enum.map(
          hosts,
          fn host_id ->
            host = HostTable.get_host(host_id)
            host_rank = HostTable.rank(host)
            [host_rank, host_id]
          end)
        {best_rank, chosen_host} = Enum.max(ranks)
        chosen_host
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
            # TODO: raise an exception here for invalid config,
            #       or else do config validation during `start_link`
            #       and during `put_host`
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
