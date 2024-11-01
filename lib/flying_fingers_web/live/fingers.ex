defmodule FlyingFingers.Data do
  use GenServer
  alias Phoenix.PubSub

  @topic "problemstatement"

  # Client

  def start_link(_default \\ %{}) do
    problem = get_blank_problem()
    PubSub.broadcast(FlyingFingers.PubSub, @topic, problem)
    GenServer.start_link(__MODULE__, problem, name: FFData)
  end


  @doc """
  Add a new response of the form
  %{"developer" => string(), "days" => number()}
  """
  def add_response(pid, obj) do
    GenServer.cast(pid, {:add_response, obj})
  end


  @doc """
  Retrieve all responses
  """
  def get_problem(pid) do
    GenServer.call(pid, :get_problem)
  end


  def set_problem(pid, statement) do
    GenServer.cast(pid, {:set_problem, statement})
  end


  @doc """
  Reset the state to default
  """
  def reset_problem(pid, statement \\ nil) do
    GenServer.cast(pid, {:reset_problem, statement})
  end

  def reveal(pid) do
    GenServer.cast(pid, {:reveal})
  end
  # Server (callbacks)


  defp get_blank_problem(statement \\ "A problem statement")  do
    %{
      "statement" => statement,
      "reveal" => false,
      "responses" => %{}
    }
  end

  @impl true
  def init(map) do
    {:ok, map}
  end

  @impl true
  def handle_call(:get_problem, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:reset_problem, statement}, _state) do
    problem = case statement do
      nil -> get_blank_problem()
      s   -> get_blank_problem(s)
    end
    cast_broadcast(problem)
  end

  @impl true
  def handle_cast({:add_response, %{"developer" => d, "days" => n}}, state) do
    responses = Map.put(Map.get(state, "responses"), d, n)
    newstate = Map.put(state, "responses", responses)
    cast_broadcast(newstate)
  end

  @impl true
  def handle_cast({:set_problem, statement}, state) do
    newstate = Map.put(state, "statement", statement)
    cast_broadcast(newstate)
  end

  @impl true
  def handle_cast({:reveal}, state) do
    newstate = Map.put(state, "reveal", true)
    cast_broadcast(newstate)
  end

  defp cast_broadcast(newstate) do
    PubSub.broadcast(FlyingFingers.PubSub, @topic, newstate)
    {:noreply, newstate}
  end
end
