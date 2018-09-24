alias :math, as: Math

defmodule Proj1 do

  @doc """
    Given a number n, returns sum of squares from 1 to n
  """
  def get_sum_of_squares(n) do
    div((n * (n + 1) * (2 * n + 1)), 6)
  end

  @doc """
    Given a number returns true if the number is a perfect square
  """
  def is_perfect_square(n) do
    (Float.floor(Math.sqrt(n)) - Math.sqrt(n)) == 0.0
  end

  def check_sequence() do
    receive do
        {:check, monitor, n, k} ->
            if is_perfect_square(get_sum_of_squares(n + k - 1) - get_sum_of_squares(n - 1)) do
                IO.puts n
            end
            
            send monitor, {:done}
    end
  end

  def check_completion(parent, n, c) do
    receive do
        {:done} -> 
            if c + 1 == n do
                send parent, {:done}
            else
                check_completion(parent, n, c + 1)
            end
    end
  end

  def main(args) do
    # IO.puts System.get_env("ELIXIR_ERL_OPTIONS")
    # IO.puts System.get_env("ELIXIR_ERL_OPTS")
    # IO.inspect args

    parent = self()
    # check_sequence(parent, String.to_integer(Enum.at(args, 0)), String.to_integer(Enum.at(args, 1)))
    monitor = spawn_link(fn -> check_completion(parent, String.to_integer(Enum.at(args, 0)), 0) end)
    n = String.to_integer(Enum.at(args, 0))
    k = String.to_integer(Enum.at(args, 1))
    # Enum.map(1..n, fn(x) -> spawn_link(fn -> check_sequence(monitor, x, k) end) end)
    Enum.map(1..n, fn(x) -> 
                        pid = spawn_link(&Proj1.check_sequence/0)
                        send pid, {:check, monitor, x, k}
                    end)
    
    # # pids = Enum.map(1..String.to_integer(Enum.at(args, 0)), fn (_) -> spawn_link(&Proj1.check_sequence/0) end)
    # for i <- 1..String.to_integer(Enum.at(args, 0)), do: send Enum.at(pids, i-1), {:msgkey, monitor, i, String.to_integer(Enum.at(args, 1))}
    
    receive do
        {:done} -> nil
    end
  end
end

Proj1.main(System.argv)