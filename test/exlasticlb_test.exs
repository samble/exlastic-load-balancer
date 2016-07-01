
defmodule HostTableTests do
  use ExUnit.Case
  @host_id "i-42"
  test "read config" do
    HostTable.start_link("test/exlastic_test_config.json");
    host_names = HostTable.get_hosts()
    assert "metered-host-small" in host_names
    assert "unmetered-host" in host_names

    assert HostTable.get_host("metered-host-small")["instance-type"] == "t2.small"
    assert HostTable.get_host("unmetered-host")["instance-type"] == "m4.large"

  end
  
  test "simple registration" do
    HostTable.start_link();
    HostTable.put_host(@host_id);
    hosts = HostTable.get_hosts()
    assert @host_id in hosts
    actual = HostTable.get_host(@host_id)
    expected = HostTable.default_host_config()
    assert actual==expected
  end

  test "update one" do
    HostTable.start_link()
    HostTable.put_host(@host_id)
    HostTable.update_host(@host_id)
  end

  test "update many" do
    HostTable.start_link()
    HostTable.put_host(@host_id)
    HostTable.update_host(@host_id)
  end

  test "get AWS cpu usage percent" do
    #AWS.cpu_usage_percent('dummy')
    assert true
  end

end

defmodule ExlasticLBTest do
  use ExUnit.Case

end
