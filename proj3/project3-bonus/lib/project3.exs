alias :math, as: Math

defmodule Project3 do
  @moduledoc """
  Documentation for Project3.
  """
  def get_counter_pid(main_pid, n) do
    spawn_link(fn -> Project3.Utility.check_completion(main_pid, n, 0, 0) end)
  end

  def create_chord(pids, neighbor_map, i) do
    if i >= length(pids) do
      nil
    else
      node_pid = Enum.at(pids, i)
      node_id = i
      node_fingers = neighbor_map[node_pid]
      {node_predecessor_pid, node_predecessor_id} =
        if i == 0 do
          {Enum.at(pids, length(pids) - 1), length(pids) - 1}
        else
          {Enum.at(pids, i - 1), i}
        end

      max_value = length(pids)
      Project3.ChordNetworkNode.create(node_pid, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value})

      create_chord(pids, neighbor_map, i + 1)
    end
  end

  def main(args) do
    number_of_nodes = Enum.at(args, 0) |> String.to_integer
    number_of_requests = Enum.at(args, 1) |> String.to_integer

    number_of_nodes = Project3.Utility.get_power_2_round(number_of_nodes, 1)
    IO.inspect {"number_of_nodes (rounded of to the nearest power of 2)", number_of_nodes}

    pids = Project3.Utility.spawn_n_processes(number_of_nodes)
    # IO.inspect pids
    IO.inspect {"length(pids)", length(pids)}
    
    m = Project3.Utility.calculate_m(length(pids), 0)
    IO.inspect {"m", m}

    IO.inspect {"Takes some time calculating the finger table!"}

    neighbor_map = Project3.Utility.get_neighbors_map(pids, m, 0)
    # IO.inspect neighbor_map
    IO.inspect {"Neighbor map created"}

    create_chord(pids, neighbor_map, 0)
    # Enum.map(pids, fn x -> Project3.ChordNetworkNode.print_info(x) end)
    IO.inspect {"Chord created"}

    pid = self()
    total_requests = number_of_nodes * number_of_requests
    counter_pid = get_counter_pid(pid, total_requests)
    Enum.map(pids, fn x -> Project3.ChordNetworkNode.start_requests(x, number_of_requests, counter_pid) end)

    receive do
      {:done, hops_sum} ->
        IO.inspect {"Log2(number_of_nodes)", Math.log2(number_of_nodes)}
        IO.inspect {"Nodes", number_of_nodes, "Average hop count", hops_sum / total_requests}
    end
  end
end

Project3.main(System.argv())