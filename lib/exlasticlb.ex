defmodule AWS do


  def cpu_usage_percent(instance_id) do

    :ssl.start()
    :erlcloud.start()

    mets = :erlcloud_mon.list_metrics('AWS/EC2', 'CPUUtilization', [{'InstanceType','t2.micro'}], '')
    IO.puts Kernel.inspect(mets, pretty: true)

    stats = :erlcloud_mon.get_metric_statistics(
      'CPUUtilization',
      {{2016, 06, 29},{0, 0, 0}},
      {{2016, 06, 29},{0, 30, 0}},
      'i-1902ba9f'
    )
    IO.puts Kernel.inspect(stats, pretty: true)
    stats

    #IO.puts 1+1
  end

end

