import Mock

defmodule HostTableTests do
  use ExUnit.Case

  @host_id "i-42"

  test "host rank" do
  end

  test "choose_host" do
  end
  test "hostmon update_hosts" do
    HostTable.start_link("test/exlastic_test_config.json")
    HostMon.update_hosts()
  end

  test "application entrypoint and bad cli arguments" do
    with_mock System, [halt: fn(exit_code) -> exit_code end] do
      with_mock ExlasticLB, [main_loop: fn() -> nil end] do
        ExlasticLB.main(["--bad","arguments"])
        assert called System.halt(1)
      end
    end
  end

  test "read config" do
    HostTable.start_link("test/exlastic_test_config.json");
    host_names = HostTable.get_hosts()
    assert "metered-host-small" in host_names
    assert "unmetered-host" in host_names
    assert HostTable.get_host("metered-host-small")["instance_type"] == "t2.small"
    assert HostTable.get_host("unmetered-host")["instance_type"] == "m4.large"

  end

  test "simple registration" do
    HostTable.start_link()
    HostTable.put_host(@host_id)
    hosts = HostTable.get_hosts()
    assert @host_id in hosts
    actual = HostTable.get_host(@host_id)
    expected = HostTable.default_host_config()
    assert actual==expected
  end

  test "update one" do
    HostTable.start_link()
    HostTable.put_host(@host_id)
    HostTable.update_host(@host_id, 0.69)

    IO.puts "updated host: "
    IO.puts inspect HostTable.get_host(@host_id)
  end

  test "update many" do
    HostTable.start_link()
    HostTable.put_host(@host_id)
    HostTable.update_host(@host_id, 0)
  end

  test "get AWS cpu usage percent" do
    :ssl.start()
    :erlcloud.start()

    IO.puts inspect AWS.get_cpu_metrics('i-1902ba9f')
    assert true
  end

end

defmodule ExlasticLBTest do
  use ExUnit.Case

end
