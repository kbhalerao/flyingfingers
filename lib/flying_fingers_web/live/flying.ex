defmodule FlyingFingersWeb.Flying do
  @moduledoc """
    Interface for non-administrative users.
    Sends updated estimates and subscribes to updates from
    pubsub server.
  """
  use FlyingFingersWeb, :live_view
  alias Phoenix.PubSub
  alias FlyingFingers.Data

  @topic "problemstatement"

  @doc """
  Subscribe, and initialize the state.
  """
  def mount(_params, _session, socket) do
    PubSub.subscribe(FlyingFingers.PubSub, @topic)
    problem = Data.get_problem(FFData)
    estimate = %{"developer" => "Developer", "days" => 2}

    socket =
      socket
      |> assign(:form, to_form(estimate))
      |> assign(:problem, problem)

    {:ok, socket}
  end

  def handle_event("save", response, socket) do
    Data.add_response(FFData, response)

    socket =
      socket
      |> put_flash(:info, "Your estimate for this task was sent")

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    socket =
      socket
      |> assign(:problem, msg)

    {:noreply, socket}
  end
end
