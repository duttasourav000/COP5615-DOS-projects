defmodule Proj2.SimpleGenServerPushSumNetworkNode do
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add_data(pid, {neighbors, counter_pid, s}) do
    GenServer.cast(pid, {:add_data, neighbors, counter_pid, s})
  end

  def start_average(pid) do
    GenServer.cast(pid, {:start_average, 0, 1})
  end

  def start_average(pid, {:start_average, s_in, w_in}) do
    GenServer.cast(pid, {:start_average, s_in, w_in})
  end

  def get_average(pid) do
    GenServer.call(pid, {:get_average})
  end

  # Server Callbacks

  def init(:ok) do
    # neighbor list, counter_pid, s, w, last_equal_counter
    {:ok, {[], nil, 0, 1, 0}}
  end

  def handle_call({:get_average}, _, {neighbors, counter_pid, s, w, last_equal_counter}) do
    {:reply, s / w, {neighbors, counter_pid, s, w, last_equal_counter}}
  end

  def handle_cast(
        {:add_data, neighbors_in, counter_pid_in, s_in},
        {neighbors, _, _, w, last_equal_counter}
      ) do
    {:noreply, {neighbors ++ neighbors_in, counter_pid_in, s_in, w, last_equal_counter}}
  end

  def handle_cast(
        {:start_average, s_in, w_in},
        {neighbors, counter_pid, s, w, last_equal_counter}
      ) do
    # IO.inspect {s_in, w_in}
    if last_equal_counter < 3 do
      s_out = (s_in + s) / 2.0
      w_out = (w_in + w) / 2.0
      ratio_in = s_in / w_in
      ratio_out = s_out / w_out

      # IO.inspect {self(), s_in, w_in, s_out, w_out, ratio_in, ratio_out}
      last_equal_counter_out =
        cond do
          abs(ratio_out - ratio_in) < 0.0000000001 ->
            last_equal_counter + 1
          true ->
            1
        end

      # spread rumour to a random neighbor      
      random_number = :rand.uniform(length(neighbors))
      GenServer.cast(Enum.at(neighbors, random_number - 1), {:start_average, s_out, w_out})
      # GenServer.cast(self(), {:start_average, s_out, w_out})

      if last_equal_counter_out == 3 do
        # IO.inspect {"terminating actor", self(), s_in, w_in, s_out, w_out, ratio_in, ratio_out}
        send(counter_pid, {:done})
      end

      # Use for permanent failure 
      # if Proj2.Utility.should_fail() do
      #   send(counter_pid, {:done})
      #   Process.exit(self(), :normal)
      # end
      if Proj2.Utility.should_fail() do
        # change sleep time here
        Process.sleep(20)
      end
      {:noreply, {neighbors, counter_pid, s_out, w_out, last_equal_counter_out}}
    else
      {:noreply, {neighbors, counter_pid, s, w, last_equal_counter}}
    end
  end
end
