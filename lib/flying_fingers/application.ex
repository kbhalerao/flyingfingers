defmodule FlyingFingers.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlyingFingersWeb.Telemetry,
      FlyingFingers.Repo,
      {DNSCluster, query: Application.get_env(:flying_fingers, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FlyingFingers.PubSub},
      FlyingFingers.Data,
      # Start the Finch HTTP client for sending emails
      {Finch, name: FlyingFingers.Finch},
      # Start a worker by calling: FlyingFingers.Worker.start_link(arg)
      # {FlyingFingers.Worker, arg},
      # Start to serve requests, typically the last entry
      FlyingFingersWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlyingFingers.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlyingFingersWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
