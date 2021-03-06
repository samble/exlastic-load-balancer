require Logger

defmodule HostTable do
  @moduledoc """
  """
  # FIXME: use defstruct
  @ default_config %{"hosts" => %{}}
  @ default_host_config %{
    "instance_type" => "",
    "cpu_usage" => 0.0,
    "available" => false}

  @ t2_cpu_limits %{
    "t2.nano"  =>  0.05,
    "t2.micro" =>  0.10,
    "t2.small" =>  0.20,
    "t2.medium" => 0.40,
    "t2.large" =>  0.60
  } # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/t2-instances.html
  # TODO: What does the ** mean practically:
  # ** 't2.medium and t2.large instances have two vCPUs.
  # The base performance is an aggregate of the two vCPUs.'

  @doc """
  Class attributes cannot be accessed outside the class,
  so this function simply returns the class attribute
  """
  @spec default_host_config :: any
  def default_host_config do @default_host_config end

  @doc """
  Implementing Agent.start_link
  """
  def start_link(config_file \\ nil) do
    config_file_hash = cond do
      config_file != nil ->
        case File.read(config_file) do
          {:ok, body} ->
            Poison.Parser.parse!(body)
          {:error, reason} ->
            IO.puts("error opening #{config_file}: #{reason}")
            System.halt(1)
        end
      true ->
        @default_config
      end

    user_msg("HostTable configuration:")
    IO.puts Kernel.inspect config_file_hash, pretty: true
    host_config_hash = for {instance_id, data} <-
        config_file_hash["hosts"], into: %{}, do:
          {instance_id, _create_host_entry(data)}
    num_hosts = host_config_hash |> Map.keys() |> Enum.count()
    if num_hosts, do: user_msg("Starting HostTable with #{num_hosts} servers")
    host_string = Kernel.inspect(host_config_hash, pretty: true)
    Logger.info("Hosts are: #{host_string}")

    Agent.start_link(fn -> host_config_hash end, name: __MODULE__)
  end

  defp _create_host_entry(host_map) do
    Map.merge(@default_host_config, host_map)
  end

  @spec user_msg(String) :: any
  def user_msg(msg) do
    msg = IO.ANSI.blue() <> msg <> IO.ANSI.reset()
    IO.puts(msg)
  end

  @doc """
  Gets the configuration for a specific host.
  """
  @spec get_host(String) :: Dict
  def get_host(host_id) do
    Agent.get(
      __MODULE__,
      fn map ->
        # IO.puts("map=#{inspect(map)}")
        Map.get(map, host_id)
      end
    )
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
  @spec choose_host :: String
  def choose_host do
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
  @spec update_host(String, Float) :: any
  def update_host(host_id, cpu_usage_latest) do
    Agent.update(
      __MODULE__,
      fn map ->
        host = map[host_id]
        IO.puts "host: "
        IO.puts inspect host
        map = Map.update!(
          map,
          host_id,
          &(Map.put(&1, "cpu_usage", cpu_usage_latest)))
        map
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
        map = Map.put(map, host_id, host_config)
        # IO.puts("map=#{inspect(map)}")
        map
      end )
  end

  @doc """
  Get a Enum of all the host_id registered with the loader balancer
  """
  @spec get_hosts :: Enum
  def get_hosts do
    Agent.get(
      __MODULE__,
      fn map ->
        Map.keys(map)
      end)
  end
end
