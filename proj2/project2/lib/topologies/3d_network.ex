alias :math, as: Math

defmodule Proj2.Full3DNetwork do
  @doc """
    The below functions creates a random 3D network
  """
  def create_3d_network(n, algorithm) do
    side = get_number_for_nearest_cube(n, 1)
    n_round = side |> Math.pow(3) |> trunc
    # IO.inspect {side, n_round}
    pids = Proj2.Utility.spawn_n_processes(n_round, algorithm)
    # IO.inspect {"length", length(pids)}
    # IO.inspect Enum.slice(pids, 60, 10)
    get_neighbors_for_3d_network(pids, side, 0)
  end

  def get_neighbors_for_3d_network(pids, side, z) do
    if z == side do
      %{}
    else
      neighbor_map = get_neighbors_for_3d_network(pids, side, z + 1)

      cur_neighbor_map =
        Proj2.Full2DNetwork.get_neighbors_for_2d_network(
          Enum.slice(pids, z * side * side, (z + 1) * side * side),
          side,
          0,
          0
        )

      neighbor_map = Map.merge(neighbor_map, cur_neighbor_map)

      merge_3d_neighbor_planes(
        neighbor_map,
        Enum.slice(pids, z * side * side, side * side),
        Enum.slice(pids, (z + 1) * side * side, side * side)
      )
    end
  end

  def merge_3d_neighbor_planes(neighbor_map, map_1_pids, map_2_pids) do
    # IO.inspect {"merge_3d_neighbor_map", neighbor_map}
    # IO.inspect {"merge_3d_neighbor_map", map_1_pids}
    # IO.inspect {"merge_3d_neighbor_map", map_2_pids}
    cond do
      length(map_1_pids) == 0 ->
        neighbor_map

      length(map_2_pids) == 0 ->
        neighbor_map

      true ->
        merge_3d_neighbor_planes_internal(neighbor_map, map_1_pids, map_2_pids)
    end
  end

  def merge_3d_neighbor_planes_internal(neighbor_map, [head_1 | map_1_pids], [head_2 | map_2_pids]) do
    if length(map_1_pids) != length(map_2_pids) do
      IO.inspect {"Invalid", length(map_1_pids), length(map_2_pids)}
    end

    if length(map_1_pids) == 0 do
      %{
        %{neighbor_map | head_1 => neighbor_map[head_1] ++ [head_2]}
        | head_2 => neighbor_map[head_2] ++ [head_1]
      }
    else
      # IO.inspect {head_1, head_2, neighbor_map[head_1], neighbor_map[head_2]}
      merge_3d_neighbor_planes_internal(
        %{
          %{neighbor_map | head_1 => neighbor_map[head_1] ++ [head_2]}
          | head_2 => neighbor_map[head_2] ++ [head_1]
        },
        map_1_pids,
        map_2_pids
      )
    end
  end

  def get_number_for_nearest_cube(n, start) do
    start_cube = start |> Math.pow(3) |> trunc

    if start_cube >= n do
      start
    else
      get_number_for_nearest_cube(n, start + 1)
    end
  end
end
