defmodule Proj2.LineNetwork do
  @doc """
    The below functions creates a line network
  """
  def create_line_network(n, algorithm) do
    pids = Proj2.Utility.spawn_n_processes(n, algorithm)
    get_neighbors_for_line_network(pids, 0)
  end

  @doc """
    The below functions creates an imperfect line network
  """
  def create_imperfect_line_network(n, algorithm) do
    pids = Proj2.Utility.spawn_n_processes(n, algorithm)
    neighbor_map = get_neighbors_for_line_network(pids, 0)
    add_random_neighbors_for_line_network(pids, neighbor_map, 0)
  end

  def add_random_neighbors_for_line_network(pids, neighbor_map, index) do
    len_pids = length(pids)

    if index < len_pids do
      random_number = :rand.uniform(len_pids)
      cur_pid = Enum.at(pids, index)
      random_pid = Enum.at(pids, random_number - 1)

      add_random_neighbors_for_line_network(
        pids,
        %{neighbor_map | cur_pid => neighbor_map[cur_pid] ++ [random_pid]},
        index + 1
      )
    else
      neighbor_map
    end
  end

  def get_neighbors_for_line_network(nodes, index) do
    if length(nodes) == index do
      %{}
    else
      cur_pid = Enum.at(nodes, index)

      cur_node_neighbor =
        cond do
          index == 0 ->
            if length(nodes) > 1 do
              %{cur_pid => [Enum.at(nodes, index + 1)]}
            else
              %{}
            end

          index == length(nodes) - 1 ->
            if length(nodes) > 1 do
              %{cur_pid => [Enum.at(nodes, index - 1)]}
            else
              %{}
            end

          true ->
            %{
              cur_pid => [Enum.at(nodes, index - 1), Enum.at(nodes, index + 1)]
            }
        end

      Map.merge(cur_node_neighbor, get_neighbors_for_line_network(nodes, index + 1))
    end
  end
end
