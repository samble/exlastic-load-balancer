import Mock

defmodule TestCommon do
  def noop(args \\ nil) do args end
end

defmodule AWSTests do
  use ExUnit.Case

  # run only these tests with "mix test --only aws"
  @moduletag :aws

  @real_instance "i-12363f8e"
  
  test "get AWS cpu usage percent" do
    Application.ensure_all_started(:erlcloud)
    IO.puts inspect AWS.get_cpu_metrics(@real_instance)
    assert true
  end

end

defmodule CommandLineTests do
  use ExUnit.Case

  # run only these tests with "mix test --only cli"
  @moduletag :cli

  test "multiple mocks" do
      with_mocks([
        {HashDict, [],
         [get: fn(%{}, "http://example.com") -> "<html></html>" end]},
        {String, [:passthrough],
         [reverse: fn(x) -> 2 * x end,
          length: fn(_x) -> :ok end]}
        ]) do
        assert HashDict.get(%{}, "http://example.com") == "<html></html>"
        assert String.reverse(3) == 6
        assert String.length(3) == :ok
        String.trim("a  abc  a", "a")
      end
  end

end

defmodule HostTableTests do
  use ExUnit.Case

  # run only these tests with "mix test --only hosttable"
  @moduletag :hosttable

  import ExlasticLB
  import Mock

  @host_id "i-42"

  test "host rank" do
  end

  test "choose_host" do
  end

  test "hostmon update_hosts" do
    HostTable.start_link("test/exlastic_test_config.json")
    HostMon.update_hosts()
  end

  test "read config" do
    HostTable.start_link("test/exlastic_test_config.json")
    host_names = HostTable.get_hosts()
    assert "metered-host-small" in host_names
    assert "unmetered-host" in host_names
    tmp = HostTable.get_host("metered-host-small")
    assert tmp["instance_type"] == "t2.small"
    tmp = HostTable.get_host("unmetered-host")
    assert tmp["instance_type"] == "m4.large"
  end

  test "simple registration" do
    HostTable.start_link()
    HostTable.put_host(@host_id)
    hosts = HostTable.get_hosts()
    assert @host_id in hosts
    actual = HostTable.get_host(@host_id)
    expected = HostTable.default_host_config()
    assert actual == expected
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

end

defmodule ExlasticLBTest do
  use ExUnit.Case

end
