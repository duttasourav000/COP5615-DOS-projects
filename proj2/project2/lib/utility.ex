defmodule Proj2.Utility do
  def spawn_n_processes(n, mode) do
    if n == 0 do
      []
    else
      # pid = spawn_link(&Proj2.hello/0)
      pid =
        cond do
          mode == "gossip" ->
            {:ok, pid} = Proj2.SimpleGenServerGossipNetworkNode.start_link()
            pid

          mode == "push-sum" ->
            {:ok, pid} = Proj2.SimpleGenServerPushSumNetworkNode.start_link()
            pid
        end

      [pid] ++ spawn_n_processes(n - 1, mode)
    end
  end

  def check_completion(parent, n, c) do
    receive do
      {:done} ->
        # IO.inspect {"check_completion", c}
        if c + 1 == n do
          send(parent, {:done})
        else
          check_completion(parent, n, c + 1)
        end
    end
  end

  def add_data_to_gossip_nodes(neighbor_map, counter_pid) do
    Enum.each(neighbor_map, fn {k, v} ->
      Proj2.SimpleGenServerGossipNetworkNode.add_data(k, {v, counter_pid})
    end)
  end

  def add_data_to_push_sum_nodes(neighbor_map, counter_pid, number_map) do
    Enum.each(neighbor_map, fn {k, v} ->
      Proj2.SimpleGenServerPushSumNetworkNode.add_data(k, {v, counter_pid, number_map[k]})
    end)
  end

  def get_numbers_for_nodes([head | tail], sequence_type) do
    if sequence_type == "order" do
      if length(tail) == 0 do
        %{head => length(tail) + 1}
      else
        Map.merge(get_numbers_for_nodes(tail, sequence_type), %{head => length(tail) + 1})
      end
    else
      if length(tail) == 0 do
        %{head => :rand.uniform(10000)}
      else
        Map.merge(get_numbers_for_nodes(tail, sequence_type), %{head => :rand.uniform(10000)})
      end
    end
  end
end
