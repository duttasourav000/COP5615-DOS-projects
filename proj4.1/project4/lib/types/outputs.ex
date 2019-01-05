defmodule Outputs do

  @doc "Build a new output list"
  def new do
    []
  end

  def add_output(outputs, output) when is_list(outputs) do
    [ outputs | output ]
  end

end