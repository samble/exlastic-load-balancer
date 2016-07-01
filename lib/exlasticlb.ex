defmodule Exlasticlb do
  use Application

  def start(_type, _args) do

    IO.puts "starting"
    
    :ssl.start()
    :erlcloud.start()

    stats = AWS.cpu_usage_percent('i-1902ba9f')
    IO.puts Kernel.inspect(stats, pretty: true)

    :ok

  end


end

defmodule AWS do

  def cpu_usage_percent(instance_id) do
    :erlcloud_mon.get_metric_statistics(
      'CPUUtilization',
      {{2016, 06, 29},{0, 0, 0}},
      '2016-06-29T00:30:00Z',
      instance_id
    )

  end

end

