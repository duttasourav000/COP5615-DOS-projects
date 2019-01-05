defmodule Project4.BitcoinTimer do
  use Task
  def start_link(_arg) do
    Task.start_link(&mine/0)
    Task.start_link(&transact/0)
  end

  def mine() do
    receive do
    after
      10_000 ->
        {_, pid, _, _} = Enum.at(Supervisor.which_children(Project4.Supervisor), 0)
        Project4.BitcoinSimulator.mine_block(pid)
        mine()
    end
  end
  
  def transact() do
    receive do
    after
        1_000 ->
            {_, pid, _, _} = Enum.at(Supervisor.which_children(Project4.Supervisor), 0)
            Project4.BitcoinSimulator.transfer_bitcoin(pid)
            transact()
    end
end

#   defp get_price() do
#     # Call API & Persist
#     IO.puts "To the moon!"
#   end
end