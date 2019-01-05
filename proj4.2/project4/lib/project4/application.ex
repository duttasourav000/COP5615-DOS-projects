defmodule Project4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    # IO.inspect {"starting..."}
    children = [
      # Start the endpoint when the application starts
      Project4Web.Endpoint,
      # Starts a worker by calling: Project4.Worker.start_link(arg)
      # {Project4.Worker, arg},
      %{
        id: SampleS,
        start: {Project4.BitcoinSimulator, :start_link, []}
      },

      # Project4.BitcoinTimer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Project4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Project4Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
