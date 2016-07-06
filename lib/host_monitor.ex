defmodule HostMon do
  @moduledoc """
  """

  def start_link do
    Task.Supervisor.start_link([name: __MODULE__])
  end

  @doc """
  Updates the health data for all hosts.
  """
  def update_hosts do
    hosts = HostTable.get_hosts()
    Enum.each(hosts, fn(host) ->
      Task.start_link(
        fn ->
          HostTable.update_host(host, fetch_cpu_usage(host))
          end)
      end)
  end

  defp fetch_cpu_usage(instance_id) do
    stats = AWS.get_cpu_metrics(instance_id)
    latest = List.last(stats)
    latest[:maximum]
  end

end
