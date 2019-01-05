defmodule Blockchain do
    use Bitwise

    @doc "Create a new blockchain with a zero block"
    def new do
      [ Crypto.put_hash(Block.zero, -1) ]
    end
  
    # def insert_zero_block(random_data) do
    #   block =
    #     Block.zero
    #   block = %{ block | data: block.data <> random_data }
    #     |> Crypto.put_hash(-1)

    #   block = get_proof_of_work(block, 0, get_max_counter())

    #   [block]
    # end

    @doc "Insert given data as a new block in the blockchain"
    def insert(blockchain, transactions, data) when is_list(blockchain) do
      %Block{hash: prev} = List.last(blockchain)

    #   IO.inspect Crypto.put_hash("asd", -1)
      block =
        data
        |> Block.new(transactions, prev)
        |> Crypto.put_hash(-1)
  
      block = get_proof_of_work(block, 0, get_max_counter())

      blockchain ++ [block]
    end
  
    def get_max_counter() do
        {max_counter, _} = Integer.parse("FFFFFFFFFFFFFFFFFFFF", 16)
        max_counter
    end

    def get_target_bits() do
        4
    end
  
    def get_proof_of_work(block, counter, max_counter) do
        if counter < max_counter do
            shifts = 256 - get_target_bits()
		    target = 1 <<< shifts
		    {current_hash_int, _} = Integer.parse(block.hash, 16)
            # IO.inspect block.hash

            # IO.inspect {"current_hash_int", current_hash_int, current_hash_int |> Integer.to_string(2) |> String.pad_leading(256, "0"), "target", target, target |> Integer.to_string(2) |> String.pad_leading(256, "0")}

            if current_hash_int < target do
                # IO.inspect {"proof_of_work", counter}
			    # IO.inspect {"current_hash_int", current_hash_int, current_hash_int |> Integer.to_string(2) |> String.pad_leading(256, "0"), "target", target, target |> Integer.to_string(2) |> String.pad_leading(256, "0")}
                
                block
            else
                # IO.inspect "counter increase"
                get_proof_of_work(block |> Crypto.put_hash(counter + 1), counter + 1, max_counter)
            end
        else
            block
        end
    end

    @doc "Validate the complete blockchain"
    def valid?(blockchain) when is_list(blockchain) do
      zero = Enum.reduce_while(Enum.reverse(blockchain), nil, fn prev, current ->
        cond do
          current == nil ->
            {:cont, prev}
  
          Block.valid?(current, prev) ->
            {:cont, prev}
  
          true ->
            {:halt, false}
        end
      end)
  
      if zero, do: Block.valid?(zero), else: false
    end
  end
  