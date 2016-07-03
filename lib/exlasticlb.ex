import AWS
import HostTable

defmodule ExlasticLB do
  use Application

  def main(args) do
      args |> parse_args |> process
  end

  defp parse_args(args) do
      {options, _, _} = OptionParser.parse(args,
        switches: [config: :string]
      )
      options
  end

  def process([]) do
      Terminal.user_msg("No arguments given")
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
        start(:cli,options[:config])
    end
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(start_type, start_args) do
      import Supervisor.Spec, warn: false
      IO.puts("application entry")
      IO.puts("#{inspect({start_type, start_args})}")
      unconditonal_children = [
        # Define workers and child supervisors to be supervised
      ]
      conditional_children = cond do
        start_type==:cli ->
          IO.puts("app/cli entry")
          [worker(HostTable, start_args)]
        start_type == :normal->
          IO.puts("entry from 'mix test' or 'mix run'?")
          IO.puts("for command-line tool, use 'mix escript.build && ./exlasticlb --config config.json'")
          []
        true ->
          IO.puts("unrecognized entry-type: '#{start_type}'")
          []
      end
      children = conditional_children++unconditonal_children
      IO.puts("Children (#{Enum.count(children)} total): #{inspect(children)}")
      opts = [strategy: :one_for_one, name: ExlasticLB.Supervisor]
      Supervisor.start_link(children, opts)
  end

end
