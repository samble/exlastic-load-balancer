defmodule AWS do
  @doc """
  """
  @spec get_cpu_metrics(String) :: Integer
  def get_cpu_metrics(instance_id) do
    IO.puts("asking erlcloud for stats for #{instance_id}")
    :erlcloud_mon.get_metric_statistics(
      'CPUUtilization',
      {{2016, 06, 29},{0, 0, 0}},
      '2016-06-29T00:30:00Z',
      instance_id
    )

  end
end
