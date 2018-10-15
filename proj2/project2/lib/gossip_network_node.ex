defmodule Proj2.SimpleGenServerGossipNetworkNode do
  use GenServer

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add_data(pid, {neighbors, counter_pid}) do
    GenServer.cast(pid, {:add_data, neighbors, counter_pid})
  end

  def listen_rumour(pid) do
    GenServer.cast(pid, {:listen_rumour})  
  end

  def spread_rumour(pid) do
    GenServer.cast(pid, {:spread_rumour})
  end

  # Server Callbacks

  def init(:ok) do
    {:ok, {[], 0, nil}}
  end
  
  # def handle_info(:done, _) do
	# 	IO.inspect "shutting down"
	# 	{:stop, :normal, {[], 0, nil}}
  # end
  
  def handle_cast({:add_data, neighbors_in, counter_pid}, {neighbors, count, _}) do
    {:noreply, {neighbors ++ neighbors_in, count, counter_pid}}
  end

  def handle_cast({:listen_rumour}, {neighbor_list, count, counter_pid}) do
    # IO.inspect {"listen"}
    {:noreply, {neighbor_list, count + 1, counter_pid}}
  end

  def handle_cast({:spread_rumour}, {neighbor_list, count, counter_pid}) do
    # if count > 1 do
    #   IO.inspect {"count", count}
    # end

    # IO.inspect {"Cast", self(), count}
    if count < 10 && Enum.any?(neighbor_list, fn p -> Process.alive? p end) do
      # spread rumour to a random neighbor
      # IO.inspect count
      random_number = :rand.uniform(length(neighbor_list))
      random_neighbor = Enum.at(neighbor_list, random_number - 1)
      if Process.alive? random_neighbor do
        # IO.inspect {"self", self(), count, "sent", random_neighbor}
        GenServer.cast(random_neighbor, {:listen_rumour})
      end

      if count == 0 do
        # IO.inspect "Done"
        send(counter_pid, {:done})
      end

      GenServer.cast(self(), {:spread_rumour})
      {:noreply, {neighbor_list, count, counter_pid}}
    else
      # IO.inspect {"shutdown", self()}
      # Kernel.send(self(), :done)
      Process.exit(self(), :normal)
      {:noreply, {neighbor_list, count, counter_pid}}
    end
  end
end
