defmodule FlyingFingersWeb.Setup do
  use FlyingFingersWeb, :live_view
  alias FlyingFingers.Data
  alias Phoenix.PubSub

  @topic "problemstatement"

  def mount(_params, _session, socket) do
    PubSub.subscribe(FlyingFingers.PubSub, @topic)
    problem = Data.get_problem(FFData)
    estimate = %{"developer" => "Coordinator", "days" => 2}

    socket =
      socket
      |> assign(:formp, to_form(problem))
      |> assign(:formr, to_form(problem))
      |> assign(:form, to_form(estimate))
      |> assign(:problem, problem)

    # Data.increment_developers(FFData)

    {:ok, socket}
  end

  def handle_event("update", %{"statement" => s}, socket) do
    Data.set_problem(FFData, s)
    {:noreply, socket}
  end

  def handle_event("reset", _reset, socket) do
    Data.reset_problem(FFData)
    {:noreply, socket}
  end

  def handle_event("save", response, socket) do
    Data.add_response(FFData, response)

    socket =
      socket
      |> put_flash(:info, "Your estimate for this task was sent")

    {:noreply, socket}
  end

  def handle_event("reveal", _reveal, socket) do
    Data.reveal(FFData)
    {:noreply, socket}
  end

  def handle_info(problem, socket) do
    socket =
      socket
      |> assign(:problem, problem)
      |> assign(:formp, to_form(problem))
      |> assign(:formr, to_form(problem))

    {:noreply, socket}
  end
end
