defmodule Proj2 do
  @moduledoc """
  Documentation for Proj2.
  """

  def start_rumour(pids) do
    random_number = :rand.uniform(length(pids))
    Proj2.SimpleGenServerGossipNetworkNode.spread_rumour(Enum.at(pids, random_number - 1))
  end

  def start_average(pids) do
    random_number = :rand.uniform(length(pids))
    Proj2.SimpleGenServerPushSumNetworkNode.start_average(Enum.at(pids, random_number - 1))
  end

  def get_counter_pid(main_pid, n) do
    spawn_link(fn -> Proj2.Utility.check_completion(main_pid, n, 0) end)
  end

  def initialize_and_spread_rumour(neighbor_map, algorithm, main_pid) do
    n = 
      if algorithm == "push-sum" do
        1
      else
        length(Map.keys(neighbor_map))
      end

    counter_pid = get_counter_pid(main_pid, n)

    cond do
      algorithm == "gossip" ->
        Proj2.Utility.add_data_to_gossip_nodes(neighbor_map, counter_pid)
        Map.keys(neighbor_map) |> start_rumour

      algorithm == "push-sum" ->
        # number_map = Proj2.Utility.get_numbers_for_nodes(Map.keys(neighbor_map), "random")
        number_map = Proj2.Utility.get_numbers_for_nodes(Map.keys(neighbor_map), "order")
        # IO.inspect number_map
        Proj2.Utility.add_data_to_push_sum_nodes(neighbor_map, counter_pid, number_map)
        Map.keys(neighbor_map) |> start_average
        number_sum = Enum.reduce(number_map, 0, fn {_k, v}, acc -> v + acc end)
        IO.inspect({"Actual average", number_sum / length(Map.keys(neighbor_map))})
    end
  end

  def show_n_random_averages(pids, n) do
    if n == 0 do
      nil
    else
      # {:reply, average} =
      IO.inspect  Proj2.SimpleGenServerPushSumNetworkNode.get_average(
          Enum.at(pids, :rand.uniform(length(pids)) - 1)
        )

      # IO.inspect(average)
      show_n_random_averages(pids, n - 1)
    end
  end

  @doc """
    Main function of the module
  """
  def main(args) do
    n = String.to_integer(Enum.at(args, 0))
    topology = Enum.at(args, 1)
    algorithm = Enum.at(args, 2)

    main_pid = self()
    t1 = Time.utc_now()

    case topology do
      "full" ->
        neighbor_map = Proj2.FullNetwork.create_full_network(n, algorithm)
        initialize_and_spread_rumour(neighbor_map, algorithm, main_pid)

        receive do
          {:done} ->
            IO.inspect "done"
            if algorithm == "push-sum" do
              show_n_random_averages(Map.keys(neighbor_map), 5)
            end
        end

      "3D" ->
        neighbor_map = Proj2.Full3DNetwork.create_3d_network(n, algorithm)
        initialize_and_spread_rumour(neighbor_map, algorithm, main_pid)

        receive do
          {:done} ->
            if algorithm == "push-sum" do
              show_n_random_averages(Map.keys(neighbor_map), 5)
            end
        end

      "rand2D" ->
        neighbor_map = Proj2.Full2DNetwork.create_random_2d_network(n, algorithm)
        initialize_and_spread_rumour(neighbor_map, algorithm, main_pid)

        receive do
          {:done} ->
            if algorithm == "push-sum" do
              show_n_random_averages(Map.keys(neighbor_map), 5)
            end
        end

      "torus" ->
        neighbor_map = Proj2.TorusNetwork.create_torus_network(n, algorithm)
        initialize_and_spread_rumour(neighbor_map, algorithm, main_pid)

        receive do
          {:done} ->
            if algorithm == "push-sum" do
              show_n_random_averages(Map.keys(neighbor_map), 5)
            end
        end

      "line" ->
        neighbor_map = Proj2.LineNetwork.create_line_network(n, algorithm)
        # IO.inspect neighbor_map
        initialize_and_spread_rumour(neighbor_map, algorithm, main_pid)

        receive do
          {:done} ->
            if algorithm == "push-sum" do
              show_n_random_averages(Map.keys(neighbor_map), 5)
            end
        end

      "impline" ->
        neighbor_map = Proj2.LineNetwork.create_imperfect_line_network(n, algorithm)
        initialize_and_spread_rumour(neighbor_map, algorithm, main_pid)

        receive do
          {:done} ->
            if algorithm == "push-sum" do
              show_n_random_averages(Map.keys(neighbor_map), 5)
            end
        end
    end

    t2 = Time.utc_now()
    IO.inspect(Time.diff(t2, t1, :millisecond))
  end
end

Proj2.main(System.argv())
