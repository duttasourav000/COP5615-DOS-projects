defmodule Block do
    defstruct [:data, :transactions, :timestamp, :prev_hash, :counter, :hash]
  
  
    @doc "Build a new block for given data and previous hash"
    def new(data, transactions, prev_hash) do
      %Block{
        data: data,
        transactions: transactions,
        prev_hash: prev_hash,
        counter: -1,
        timestamp: NaiveDateTime.utc_now,
      }
    end
  
  
    @doc "Build the initial block of the chain"
    def zero do
      %Block{
        data: "ZERO_DATA",
        transactions: Transactions.new,
        prev_hash: "ZERO_HASH",
        timestamp: NaiveDateTime.utc_now,
      }
    end
  
    @doc "Check if a block is valid"
    def valid?(%Block{} = block) do
      Crypto.hash(block, block.counter) == block.hash
    end

    def valid?(%Block{} = block, %Block{} = prev_block) do
      (block.prev_hash == prev_block.hash) && valid?(block)
    end
  end