defmodule Transaction do
  defstruct [:hash, :input_indices, :output_indices, :data, :timestamp]


  @doc "Build a new block for given data and previous hash"
  def new(input_indices, output_indices, data) do
    %Transaction{
      hash: "transaction hash",
      input_indices: input_indices,
      output_indices: output_indices,
      data: data,
      timestamp: NaiveDateTime.utc_now,
    }
  end
end