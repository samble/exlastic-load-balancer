import AWS
import HostTable

defmodule HostMon do

  def start_link do
    Task.Supervisor.start_link([name: __MODULE__])
  end

  def update_hosts do
    hosts = HostTable.get_hosts()
    Enum.each(hosts, Task.async(fn(host) ->
      HostTable.update_host(
        host["instance_id"],
        fetch_cpu_usage(host["instance_id"]))
      end))
  end

  defp fetch_cpu_usage(instance_id) do
    stats = AWS.get_cpu_metrics(instance_id)
    latest = List.last(stats)
    latest["maximum"]
  end

end
