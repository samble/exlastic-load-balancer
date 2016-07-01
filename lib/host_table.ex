defmodule HostTable do
  @ default_config %{"hosts" => %{}}
  @ default_host_config %{"metered" => false}

  @ t2_cpu_limits %{
    "t2.nano"  =>  0.05,
    "t2.micro" =>  0.10,
    "t2.small" =>  0.20,
    "t2.medium" => 0.40,
    "t2.large" =>  0.60
  } # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/t2-instances.html
  # TODO: What does the ** mean practically:
  # 't2.medium and t2.large instances have two vCPUs. The base performance is an aggregate of the two vCPUs.'

  @doc """
  Class attributes cannot be accessed outside the class,
  so this function simply returns the class attribute
  """
  @spec default_host_config() :: Dict
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
    IO.puts "hosts!"
    IO.puts Kernel.inspect config_hash, pretty: true
    IO.puts "Registering #{num_hosts} hosts under this LB"
    (num_hosts>0) && IO.puts "Hosts are: #{host_string}"
    Agent.start_link(fn -> config_hash end, name: __MODULE__)
  end

  @doc """
  Gets the configuration for a specific host.
  """
  @spec get_host(String) :: Dict
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
  @spec update_all() :: nil
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
  @spec rank_host(Dict) :: Integer
  def rank_host(host_dict) do
    _ = host_dict # silence compiler warning
    1
  end

  @doc """
  Based on all available host health data, choose the host that
  should answer the current HTTP request.
  """
  @spec choose_host() :: String
  def choose_host() do
    hosts = HostTable.get_hosts()
    ranks = Enum.map(
          hosts,
          fn host_id ->
            host = HostTable.get_host(host_id)
            host_rank = HostTable.rank_host(host)
            [host_rank, host_id]
          end)
    {_, chosen_host} = Enum.max(ranks)
    chosen_host
  end

  @doc """
  Updates the health data for one host.
  The host must have already been registered with the load balancer
  """
  @spec update_host(String) :: any
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
  @spec put_host(String, Dict) :: Dict
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
  @spec get_hosts() :: Enum
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
