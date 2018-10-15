alias :math, as: Math

defmodule Proj2.Full2DNetwork do
  @doc """
    The below functions creates a random 2D network
  """
  def create_random_2d_network(n, algorithm) do
    n_round = get_nearest_square(n)
    pids = Proj2.Utility.spawn_n_processes(n_round, algorithm)
    side = n_round |> Math.sqrt() |> trunc
    get_neighbors_for_2d_network(pids, side, 0, 0)
  end

  def get_neighbors_for_2d_network(pids, side, row, col) do
    adj_map =
      cond do
        row == side ->
          %{}

        col == side ->
          get_neighbors_for_2d_network(pids, side, row + 1, 0)

        true ->
          top =
            if row > 0 do
              [Enum.at(pids, (row - 1) * side + col)]
            else
              []
            end

          right =
            if col < side - 1 do
              [Enum.at(pids, row * side + col + 1)]
            else
              []
            end

          bottom =
            if row < side - 1 do
              [Enum.at(pids, (row + 1) * side + col)]
            else
              []
            end

          left =
            if col > 0 do
              [Enum.at(pids, row * side + col - 1)]
            else
              []
            end

          cur_pid = Enum.at(pids, row * side + col)
          adj_pids = top ++ right ++ bottom ++ left

          Map.merge(
            %{cur_pid => adj_pids},
            get_neighbors_for_2d_network(pids, side, row, col + 1)
          )
      end

    adj_map
  end

  def get_nearest_square(n) do
    (n - 1) |> Math.sqrt() |> trunc |> Kernel.+(1) |> Math.pow(2)
  end
end
