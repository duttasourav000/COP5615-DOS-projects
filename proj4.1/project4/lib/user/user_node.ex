defmodule Project4.UserNode do
    use Bitwise
    use GenServer

    # Client API

    def  start_link do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def start(pid, {ledger_pid}) do
        GenServer.cast(pid, {:start, {ledger_pid}})
    end

    def add_block(pid) do
        GenServer.cast(pid, {:add_block})
    end

    def print_info(pid) do
        GenServer.cast(pid, {:print_info})
    end

    def combine_outputs(pid) do
        GenServer.cast(pid, {:combine_outputs})
    end

    def get_public_address(pid) do
        GenServer.call(pid, {:get_public_address})
    end

    # Server Callbacks
    
    def init(:ok) do
        pid = self()
        public_address_str = inspect(pid)
        public_address = :crypto.hash(:sha256, public_address_str) |> Base.encode16
        ledger_pid = nil
        {:ok, {pid, public_address, ledger_pid}}
    end

    def handle_cast({:start, {ledger_pid}}, {pid, public_address, _}) do
        IO.inspect {"Started mining genesis block for " <> public_address}
        GenServer.cast(self(), {:add_block})
        
        {:noreply, {pid, public_address, ledger_pid}}
    end

    def handle_cast({:add_block}, {pid, public_address, ledger_pid}) do
        # get ledger data
        {blockchain, outputs, transactions, unverified_transactions} =
            Project4.GlobalLedger.get_ledger_data(ledger_pid)
        
        # add a reward for itself
        value = 15
            
        output = Output.new(public_address, value)
        outputs = outputs ++ [output]

        transaction = Transaction.new([], [length(outputs) - 1], "BlockReward")
        unverified_transactions = unverified_transactions ++ [transaction]
        
        # create a block
        blockchain = Blockchain.insert(blockchain, unverified_transactions, "Block by " <> public_address)

        # update the blockchain
        transactions = transactions ++ unverified_transactions
        GenServer.call(ledger_pid, {:update_ledger_blockchain, public_address, blockchain, transactions, outputs})

        {:noreply, {pid, public_address, ledger_pid}}
    end

    def handle_cast({:print_info}, {pid, public_address, ledger_pid}) do
        IO.inspect {"self", self(), "User details here!!"}
        IO.inspect {"pid", pid}
        IO.inspect {"public_address", public_address}
        IO.inspect {"ledger_pid", ledger_pid}

        {:noreply, {pid, public_address, ledger_pid}}
    end

    def handle_call({:get_public_address}, _, {pid, public_address, ledger_pid}) do
        {:reply, public_address, {pid, public_address, ledger_pid}}
    end
end