defmodule Crypto do

    # Specify which fields to hash in a block
    @hash_fields [:data, :timestamp, :prev_hash]
  
  
    @doc "Calculate hash of block"
    def hash(%{} = block, counter) do      
      data = block |> Map.take(@hash_fields) |> inspect

      if counter >= 0 do
        (data <> Integer.to_string(counter))
        |> sha256
      else
        data
        |> sha256
      end
    end
  
    @doc "Calculate and put the hash in the block"
    def put_hash(%{} = block, ctr) do
    #   IO.inspect {"put_hash", block, counter}
      %{ block | hash: hash(block, ctr), counter: ctr }
    end
  
  
    # Calculate SHA256 for a binary string
    defp sha256(binary) do
      :crypto.hash(:sha256, binary) |> Base.encode16
    end
  
  end