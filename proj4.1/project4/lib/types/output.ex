defmodule Output do
  defstruct [:owner, :value, :timestamp, :hash]


  @doc "Build a new block for given data and previous hash"
  def new(owner, value) do
    %Output{
      owner: owner,
      value: value,
      timestamp: NaiveDateTime.utc_now,
      hash: "input output hash",
    }
  end

end