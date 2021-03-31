defmodule Home73k.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Home73kWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Home73k.PubSub},
      # Start the Endpoint (http/https)
      Home73kWeb.Endpoint,
      # Start a worker by calling: Home73k.Worker.start_link(arg)
      # {Home73k.Worker, arg}
      Home73k.Blog
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Home73k.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Home73kWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
