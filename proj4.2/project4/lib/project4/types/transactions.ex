defmodule Transactions do

  @doc "Build a new block for given data and previous hash"
  def new do
    []
  end

  @doc "Check if a block is valid"

  def add_transaction(transactions, transaction) when is_list(transaction) do
    [ transactions | transaction ]
  end
end