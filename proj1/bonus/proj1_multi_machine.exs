alias :math, as: Math

defmodule Proj1 do
  @moduledoc """
  Documentation for Proj1.
  """

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

  @doc """
    Checks if a sum of squares of the numbers in the sequence is equal to a perfect square

    Listens for :msgkey with parameters parent id, n and k

    ## Examples
      (n)^2 + (n+1)^2 ... (n + k - 1)^2 = (x)^2
      Returns true is x is a whole number
  """
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

  def check_sequence_range(parent_monitor, start_n, end_n, k, machine_id) do
    # IO.inspect ["s", start_n, "-", end_n]
    parent = self()
    monitor = spawn_link(fn -> check_completion(parent, end_n - start_n + 1, 0) end)

    Enum.map(start_n..end_n, fn(x) -> 
            pid = spawn_link(&Proj1.check_sequence/0)
            send pid, {:check, monitor, x, k}
        end)
    
    receive do
        {:done} -> send parent_monitor, {:done, machine_id}
    end
  end
end