
defmodule HostTableTests do
  use ExUnit.Case
  @host_id "i-42"

  test "simple registration" do
    HostTable.start_link();
    HostTable.put_host(@host_id);
    hosts = HostTable.get_hosts()
    assert @host_id in hosts
    actual = HostTable.get_host(@host_id)
    expected = HostTable.get_default_host_config()
    assert actual==expected
  end

  test "read config" do
    #HostTable.start_link(fname)
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
end

defmodule ExlasticLBTest do
  use ExUnit.Case

end
