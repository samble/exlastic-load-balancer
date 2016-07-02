defmodule AWS do
  @doc """
  """
  @spec cpu_usage_percent(String) :: Integer
  def cpu_usage_percent(instance_id) do
    :erlcloud_mon.get_metric_statistics(
      'CPUUtilization',
      {{2016, 06, 29},{0, 0, 0}},
      '2016-06-29T00:30:00Z',
      instance_id
    )

  end
end
