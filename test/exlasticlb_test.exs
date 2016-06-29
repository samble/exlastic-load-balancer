defmodule ExlasticLBTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "get AWS cpu usage percent" do
    AWS.cpu_usage_percent('dummy')
    assert true
  end

end
