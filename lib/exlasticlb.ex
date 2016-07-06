import HostTable
import Supervisor.Spec, warn: false

defmodule ExlasticLB do
  @moduledoc """
  """
  use Application

  @doc """
  """
  def starter(children, extra_opts \\ []) do
    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    unconditonal_children = [
      # Define workers and child supervisors to be supervised
    ]
    IO.puts("Children (#{Enum.count(children)} total): #{inspect(children)}")
    opts = extra_opts ++ [strategy: :one_for_one, name: ExlasticLB.Supervisor]
    Supervisor.start_link(
      unconditonal_children ++ children, opts)
  end

  @doc """
  """
  def start(start_type, [mix_env | start_args]) do
      HostTable.user_msg(
        "Application entry: #{inspect({mix_env, start_type, start_args})}")
      cond do
        is_atom(mix_env) ->
          sstart(mix_env, start_args)
        is_binary(mix_env) ->
          sstart(start_type, mix_env)
      end
  end
  # function-header, so no do/ends are needed
  def sstart(mix_env_or_mode, args \\ [])

  # function-clauses that work with pattern matching
  @doc """
  """
  def sstart(:test, []) do
      IO.puts("entry from 'mix test'?")
      starter([])
  end

  @doc """
  """
  def sstart(:dev, start_args) do
    Application.ensure_all_started(:quantum)
    Application.ensure_all_started(:erlcloud)
    Application.ensure_all_started(:logger)
    starter(
      [supervisor(HostTable, start_args),
       supervisor(HostMon, [])])
  end

  @doc """
  """
  def sstart(:cli, config_file) do
    IO.puts("CLI entry: #{config_file}")
    sstart(:dev, [config_file])
  end
end
