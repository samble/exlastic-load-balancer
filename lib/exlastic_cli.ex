defmodule ExlasticLB.CommandLine do
  @moduledoc """
  """

  @doc """
  it's not really clear to me why, but without a block-forever
   call such as the one below the main process will exit, taking
   all the supervision trees with it.  see also:
   https://groups.google.com/forum/#!topic/elixir-lang-talk/N9RZd_8y0sk
  """
  @spec main_loop :: any
  def main_loop do
    IO.puts("entering main-loop")
    :timer.sleep(:infinity) # prevent the main process from exiting
  end

  @doc """
  Entry-point for CLI invocations of exlasticlb (escript entry)
  """
  def main(args) do
      args |> parse_args |> process
      main_loop()
  end

  @doc """
  """
  def parse_args(args) do
      {options, _, _} = OptionParser.parse(args,
        switches: [config: :string])
      options
  end

  @doc """
  """
  def process([]) do
      HostTable.user_msg("No arguments given")
      System.halt(1)
  end

  @doc """
  """
  def process(options) do
    cond do
      options[:config] == nil ->
        IO.puts("--config was not passed")
        System.halt(1)
      true ->
        IO.puts("escript commandline entry")
        ExlasticLB.start(:cli, [options[:config]])
    end
  end
end
