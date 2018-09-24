defmodule Proj1Master do
  @moduledoc """
  Documentation for Proj1.
  """

  def remove_first_element([head|tail]) do
      tail
  end

  def scheduler(n, k, batch_size, machine_pool, active_machine_count, parent_pid) do
    scheduler_pid = self()
    if n > 0 do  
        if length(machine_pool) > 0 do
            cur_batch_size = min(batch_size, n)
            # spawn_link(fn -> check_sequence_range(scheduler_pid, n - cur_batch_size + 1, n, k, Enum.at(machine_pool, 0)) end)
            # Node.spawn(Enum.at(machine_pool, 0), fn -> check_sequence_range(scheduler_pid, n - cur_batch_size + 1, n, k, Enum.at(machine_pool, 0)) end)
            Node.spawn_link(Enum.at(machine_pool, 0), Proj1, :check_sequence_range, [scheduler_pid, n - cur_batch_size + 1, n, k, Enum.at(machine_pool, 0)])
            scheduler(n - cur_batch_size, k, batch_size, remove_first_element(machine_pool), active_machine_count + 1, parent_pid)
        end
    end

    if active_machine_count > 0 do
        receive do
            {:done, machine_id} -> 
                scheduler(n, k, batch_size, machine_pool ++ [machine_id], active_machine_count - 1, parent_pid)
        end
    else
        send parent_pid, {:done}
    end
  end

  def add_nodes([head | machine_ids]) do
    IO.inspect Node.connect head
    if length(machine_ids) > 0 do
        add_nodes(machine_ids)
    end
  end

  def main(args) do
    Node.start String.to_atom(Enum.at(args, 2))
    Node.set_cookie String.to_atom(Enum.at(args, 3))
    # IO.inspect {Node.self, Node.get_cookie}

    machine_ids = [:"mc_d_1@172.17.0.2", :"mc_d_2@172.17.0.3", :"mc_d_3@172.17.0.4", :"mc_d_4@172.17.0.5", :"mc_d_5@172.17.0.6"]
    parent = self()
    Proj1Master.add_nodes(machine_ids)

    IO.inspect Node.list
    
    n = String.to_integer(Enum.at(args, 0))
    k = String.to_integer(Enum.at(args, 1))
    batch_size = 1000000
    machine_count = length(Node.list)
    machine_ids = Node.list

    spawn_link(fn -> scheduler(n, k, batch_size, machine_ids, 0, parent) end)
    receive do
        {:done} -> nil
    end
  end
end

Proj1Master.main(System.argv)