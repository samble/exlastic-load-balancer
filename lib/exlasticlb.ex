import AWS
import HostTable
import Supervisor.Spec, warn: false
defmodule ExlasticLB do
  use Application

  def main(args) do
      args |> parse_args |> process
      # main() is only used during command-line/escript entry.
      # it's not really clear to me why, but without a block-forever
      # call such as the one below the main process will exit and take
      # all the supervision trees with it.  see also:
      # https://groups.google.com/forum/#!topic/elixir-lang-talk/N9RZd_8y0sk
      IO.puts("entering main-loop")
      # prevent the main process from exiting
      :timer.sleep(:infinity)
  end

  defp parse_args(args) do
      {options, _, _} = OptionParser.parse(args,
        switches: [config: :string]
      )
      options
  end

  def process([]) do
      HostTable.user_msg("No arguments given")
      System.halt(1)
  end

  def process(options) do
    cond do
      options[:config]==nil ->
        IO.puts("--config was not passed")
        System.halt(1)
      true ->
        IO.puts("escript commandline entry")
        #start(:normal, [])
        start(:cli, [options[:config]])
    end
  end


  def starter(children, extra_opts \\ []) do
    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    unconditonal_children = [
      # Define workers and child supervisors to be supervised
    ]
    IO.puts("Children (#{Enum.count(children)} total): #{inspect(children)}")
    opts = extra_opts++[strategy: :one_for_one, name: ExlasticLB.Supervisor]
    Supervisor.start_link(
      unconditonal_children++children, opts)
  end

  def start(start_type, [mix_env | start_args]) do
      HostTable.user_msg(
        "Application entry: #{inspect({mix_env, start_type, start_args})}")
      cond do
        is_atom(mix_env) ->
          sstart(
            mix_env,
            start_args)
        is_binary(mix_env) ->
          sstart(start_type, mix_env)
      end
  end
  # function-header, so no do/ends are needed
  def sstart(mix_env_or_mode, args \\ [])

  # function-clauses that work with pattern matching
  def sstart(:test, []) do
      IO.puts("entry from 'mix test'?")
      starter([])
  end

  def sstart(:dev, start_args) do
    Application.ensure_all_started(:quantum)
    starter([supervisor(HostTable, start_args),])
  end

  def sstart(:cli, config_file) do
    IO.puts("CLI entry: #{config_file}")
    sstart(:dev, [config_file])
  end
end
