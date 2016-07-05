import AWS
import Mock

defmodule TestCommon do
  def noop(args\\nil) do args end
end

defmodule AWSTests do
  use ExUnit.Case

  # run only these tests with "mix test --only aws"
  @moduletag :aws

  @real_instance "i-1902ba9f"

  test "get AWS cpu usage percent" do
    Application.ensure_all_started(:erlcloud)
    IO.puts inspect AWS.get_cpu_metrics(@real_instance)
    assert true
  end

end

defmodule ELBCLITests do
  use ExUnit.Case

  # run only these tests with "mix test --only cli"
  @moduletag :cli

  #@tag :skip
  test "application entrypoint and bad cli arguments" do
    mocks = [
      {System, [], [halt:      TestCommon.noop]},
      {EBCLI,  [], [main_loop: TestCommon.noop]}]
    with_mocks(mocks) do
      ELBCLI.main(["--bad","arguments"])
        assert called System.halt(1)
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
    #mocks = [
    #  {AWS,  [], [get_cpu_usage: TestCommon.noop]}]
    #with_mocks(mocks) do
    #  HostTable.update_host(@host_id)
    #  assert called AWS.get_cpu_usage(@host_id)
    #  end
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
