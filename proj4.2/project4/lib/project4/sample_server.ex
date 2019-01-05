defmodule Project4.SampleServer do
    use Bitwise
    use GenServer

    # Client API

    def  start_link do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def get_public_address(pid) do
        GenServer.call(pid, {:get_public_address})
    end

    # Server Callbacks
    
    def init(:ok) do
        pid = self()
        public_address_str = inspect(pid)
        public_address = :crypto.hash(:sha256, public_address_str) |> Base.encode16
        {:ok, {public_address}}
    end

    def handle_call({:get_public_address}, _, {public_address}) do
        {:reply, public_address, {public_address}}
    end
end