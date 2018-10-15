alias :math, as: Math

defmodule Proj2.TorusNetwork do
  @doc """
    The below functions creates a random 2D network
  """
  def create_torus_network(n, algorithm) do
    n_round = Proj2.Full2DNetwork.get_nearest_square(n)
    pids = Proj2.Utility.spawn_n_processes(n_round, algorithm)
    side = n_round |> Math.sqrt() |> trunc
    neighbor_map = Proj2.Full2DNetwork.get_neighbors_for_2d_network(pids, side, 0, 0)
    add_neighbors_for_torus(neighbor_map, pids, side)
  end

  def add_neighbors_for_torus(neighbor_map, pids, side) do
    # Proj2.add_neighbors_for_torus_top_bottom(neighbor_map, pids, side, 0)
    # Proj2.add_neighbors_for_torus_left_right(neighbor_map, pids, side, 0)
    add_neighbors_for_torus_left_right(
      add_neighbors_for_torus_top_bottom(neighbor_map, pids, side, 0),
      pids,
      side,
      0
    )
  end

  def add_neighbors_for_torus_top_bottom(neighbor_map, pids, side, col) do
    if col < side do
      top_pid = Enum.at(pids, col)
      bottom_pid = Enum.at(pids, side * (side - 1) + col)
      new_neighbor_map = add_neighbors_for_torus_top_bottom(neighbor_map, pids, side, col + 1)

      %{
        new_neighbor_map
        | top_pid => new_neighbor_map[top_pid] ++ [bottom_pid],
          bottom_pid => new_neighbor_map[bottom_pid] ++ [top_pid]
      }
    else
      neighbor_map
    end
  end

  def add_neighbors_for_torus_left_right(neighbor_map, pids, side, row) do
    if row < side do
      left_pid = Enum.at(pids, side * row)
      right_pid = Enum.at(pids, side * row + side - 1)
      new_neighbor_map = add_neighbors_for_torus_left_right(neighbor_map, pids, side, row + 1)

      %{
        new_neighbor_map
        | left_pid => new_neighbor_map[left_pid] ++ [right_pid],
          right_pid => new_neighbor_map[right_pid] ++ [left_pid]
      }
    else
      neighbor_map
    end
  end
end
