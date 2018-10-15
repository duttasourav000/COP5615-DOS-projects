defmodule Proj2.FullNetwork do
  @doc """
    The below functions create a fully connected network
  """
  def create_full_network(n, algorithm) do
    pids = Proj2.Utility.spawn_n_processes(n, algorithm)
    get_neighbors_for_full_network(pids, 0)
  end

  def get_neighbors_for_full_network(nodes, index) do
    if length(nodes) == index do
      %{}
    else
      {node, rest_nodes} = List.pop_at(nodes, index)

      Map.merge(
        %{node => rest_nodes},
        Proj2.FullNetwork.get_neighbors_for_full_network(nodes, index + 1)
      )
    end
  end
end
