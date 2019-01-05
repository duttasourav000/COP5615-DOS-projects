defmodule Project4 do
  @moduledoc """
  Documentation for Project4.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project4.hello()
      :world

  """
  def hello do
    :world
  end

  def main do
    # create the shared ledged
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()

    # create a miner
    {:ok, pid_1} = Project4.UserNode.start_link()
    IO.inspect {"Created node", pid_1}

    # start the miner
    Project4.UserNode.start(pid_1, {ledger_pid})

    receive do
      after
        3000 ->
          IO.inspect Project4.GlobalLedger.print_info(ledger_pid)
    end
    
    # Project4.UserNode.add_block(pid_1, "data1_2")
    # Project4.UserNode.print_info(pid_1)
    


    # {:ok, pid_2} = Project4.UserNode.start_link()
    # Project4.UserNode.add_block(pid_2, "data2_1")
    # Project4.UserNode.add_block(pid_2, "data2_2")
    # Project4.UserNode.print_info(pid_2)

    receive do
      {:done} ->
        IO.inspect {"Done!"}
      after
        5000 ->
          IO.inspect "End"
          # Project4.UserNode.print_info(pid_1)
          # Project4.UserNode.validate(pid_1)
    end  
  end
end

# Project4.main()