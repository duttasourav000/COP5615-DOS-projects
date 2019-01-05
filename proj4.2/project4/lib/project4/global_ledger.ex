defmodule Project4.GlobalLedger do
    use Bitwise
    use GenServer

    # Client API

    def  start_link do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def get_ledger_data(pid, delete_unverified_transactions) do
        GenServer.call(pid, {:get_ledger_data, delete_unverified_transactions})
    end

    # Client API for blockchain

    def print_info(pid) do
        GenServer.cast(pid, {:print_info})
    end

    def get_balance_for_user(pid, address) do
        GenServer.call(pid, {:get_balance_for_user, address})
    end

    def update_ledger_blockchain(pid, public_address, blockchain) do
        GenServer.call(pid, {:update_ledger_blockchain, public_address, blockchain})
    end

    def validate(pid) do
        GenServer.call(pid, {:validate})
    end

    def get_unspent_outputs(pid, public_address_1) do
        GenServer.call(pid, {:get_unspent_outputs, public_address_1})
    end

    def get_balance_splits_for_user(pid, public_address) do
        GenServer.call(pid, {:get_balance_splits_for_user, public_address})
    end
    
    # Client API for transactions

    def add_transaction(pid, transaction) do
        GenServer.cast(pid, {:add_transaction, transaction})
    end

    def print_transaction_info(pid) do
        GenServer.cast(pid, {:print_transaction_info})
    end

    def transfer(pid, from, to, value, logger_pid) do
        GenServer.cast(pid, {:transfer, from, to, value, logger_pid})
    end

    def combine_change(pid, public_address) do
        GenServer.cast(pid, {:combine_change, public_address})
    end

    # Client API for input and outputs

    def add_input(pid, input) do
        GenServer.cast(pid, {:add_input, input})
    end

    def add_output(pid, output) do
        GenServer.cast(pid, {:add_output, output})
    end

    # Server Callbacks
    
    def init(:ok) do
        blockchain = Blockchain.new
        input_outputs = Outputs.new
        transactions = Transactions.new
        unverified_transactions = Transactions.new
        unverified_transactions = unverified_transactions ++ [Transaction.new([], [], "Coinbase transaction!")]

        {:ok, {blockchain, input_outputs, transactions, unverified_transactions}}
    end

    def handle_cast({:combine_change, public_address}, {blockchain, outputs, transactions, unverified_transactions}) do
        {unspent_change_indices, change} = get_unspent_change_for_user(blockchain, outputs, unverified_transactions, public_address)
        if change > 0 do
            change_output = Output.new(public_address, change)
            outputs = outputs ++ [change_output]

            transaction = Transaction.new(unspent_change_indices, [length(outputs) - 1], "Combined changes of value " <> inspect(change))
            unverified_transactions = unverified_transactions ++ [transaction]

            # IO.inspect {"Success: Combined changes of value " <> inspect(change)}
            {:noreply, {blockchain, outputs, transactions, unverified_transactions}}
        else
            {:noreply, {blockchain, outputs, transactions, unverified_transactions}}
        end
    end

    def handle_cast({:transfer, from, to, value, logger_pid}, {blockchain, outputs, transactions, unverified_transactions}) do
        Project4.BitcoinSimulator.add_log(logger_pid, "Transaction initiated: from " <> from <> " to " <> to <> " for " <> inspect(value) <> " bitcoins.")

        unspent_output_indices = get_unspent_outputs_for_user(blockchain, outputs, unverified_transactions, from)
        {input_indices, change, is_possible} = get_transaction_inputs(unspent_output_indices, outputs, value)

        if is_possible do
            outputs =
                if change > 0 do
                    change_output = Output.new(from, change)
                    transfer_output = Output.new(to, value)
                    outputs = outputs ++ [change_output] ++ [transfer_output]
                else
                    transfer_output = Output.new(to, value)
                    outputs = outputs ++ [transfer_output]
                end

            transaction = Transaction.new(input_indices, [length(outputs) - 1, length(outputs) - 2], "Transferred " <> inspect(value) <> " from " <> from <> " to " <> to <> ".")
            unverified_transactions = unverified_transactions ++ [transaction]

            # IO.inspect {"Transaction successful from " <> from <> " to " <> to <> "."}
            Project4.BitcoinSimulator.add_log(logger_pid, "Transaction successful: from " <> from <> " to " <> to <> " for " <> inspect(value) <> " bitcoins.")
            {:noreply, {blockchain, outputs, transactions, unverified_transactions}}
        else
            # IO.inspect {"Transaction denied from " <> from <> " to " <> to <> ". Insufficient balance!!"}
            Project4.BitcoinSimulator.add_log(logger_pid, "Transaction denied: Insufficient balance!! from " <> from <> " to " <> to <> " for " <> inspect(value) <> " bitcoins.")
            {:noreply, {blockchain, outputs, transactions, unverified_transactions}}
        end
    end

    def handle_cast({:print_info}, {blockchain, outputs, transactions, unverified_transactions}) do
        IO.inspect {"self", self(), "Ledger details here!!"}
        
        IO.inspect {"---- Blockchain ----"}
        IO.inspect {blockchain}

        IO.inspect {"---- Transactions ----"}
        IO.inspect {transactions}
        
        IO.inspect {"---- Outputs ----"}
        IO.inspect {outputs}
        
        IO.inspect {"---- Unverified transactions ----"}
        IO.inspect {unverified_transactions}
        
        {:noreply, {blockchain, outputs, transactions, unverified_transactions}}
    end

    def handle_call({:get_ledger_data, delete_unverified_transactions}, _, {blockchain, outputs, transactions, unverified_transactions}) do
        if delete_unverified_transactions do
            {:reply, {blockchain, outputs, transactions, unverified_transactions}, {blockchain, outputs, transactions, Transactions.new}}
        else
            {:reply, {blockchain, outputs, transactions, unverified_transactions}, {blockchain, outputs, transactions, unverified_transactions}}
        end
    end

    def handle_call({:update_ledger_blockchain, public_address, new_blockchain, new_transactions, new_outputs}, _, {blockchain, outputs, transactions, unverified_transactions}) do
        {blockchain, outputs, transactions, unverified_transactions, success} = 
            if length(new_blockchain) == length(blockchain) + 1 do
                IO.inspect {"Blockchain updated successfully by " <> public_address <> "!!!"}
                {new_blockchain, new_outputs, new_transactions, Transactions.new , true}
            else
                IO.inspect {"Blockchain update failed by " <> public_address <> "!!!"}
                {blockchain, outputs, transactions, unverified_transactions, false}
            end
        
        {:reply, success, {blockchain, outputs, transactions, unverified_transactions}}
    end
    
    def handle_call({:get_unspent_outputs, public_address}, _, {blockchain, outputs, transactions, unverified_transactions}) do
        unspent_output_indices = get_unspent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address)
        {:reply, unspent_output_indices, {blockchain, outputs, transactions, unverified_transactions}}
    end

    def handle_call({:validate}, _, {blockchain, outputs, transactions, unverified_transactions}) do
        is_valid = Blockchain.valid?(blockchain)
        {:reply, is_valid, {blockchain, outputs, transactions, unverified_transactions}}
    end

    def handle_call({:get_balance_for_user, public_address}, _, {blockchain, outputs, transactions, unverified_transactions}) do
        balance = get_balance_for_user_int(blockchain, outputs, unverified_transactions, public_address)
        {:reply, balance, {blockchain, outputs, transactions, unverified_transactions}}
    end

    def handle_call({:get_balance_splits_for_user, public_address}, _, {blockchain, outputs, transactions, unverified_transactions}) do
        balance_splits = get_balance_splits_int(blockchain, outputs, unverified_transactions, public_address)
        {:reply, balance_splits, {blockchain, outputs, transactions, unverified_transactions}}
    end

    def is_owner?(output, owner) do
        output.owner == owner
    end

    def get_unspent_change_for_user(blockchain, outputs, unverified_transactions, public_address) do
        unspent_output_indices = get_unspent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address)
        filter_unspent_output_indices(unspent_output_indices, outputs)
    end

    def filter_unspent_output_indices(unspent_output_indices, outputs) do
        if length(unspent_output_indices) == 0 do
            {[], 0}
        else
            i = hd(unspent_output_indices)
            ch = Enum.at(outputs, i).value

            if ch <= 2 do
                {rest_indices, rest_change} = filter_unspent_output_indices(tl(unspent_output_indices), outputs)
                {[i] ++ rest_indices, ch + rest_change}
            else
                filter_unspent_output_indices(tl(unspent_output_indices), outputs)
            end
        end    
    end

    def get_unspent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address) do
        output_indices = get_all_outputs_for_user(blockchain, outputs, unverified_transactions, public_address)
        input_indices = get_all_spent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address)
        unspent_output_indices = MapSet.to_list(MapSet.difference(MapSet.new(output_indices), MapSet.new(input_indices)))
        unspent_output_indices
    end

    def get_all_outputs_for_user(blockchain, outputs, unverified_transactions, public_address) do
        if length(blockchain) == 0 do
            []
        else
            block = hd(blockchain)
            output_indices = for t <- block.transactions, do: for o <- t.output_indices, is_owner?(Enum.at(outputs, o), public_address), do: o
            output_indices = output_indices ++ (for t <- unverified_transactions, do: for o <- t.output_indices, is_owner?(Enum.at(outputs, o), public_address), do: o)
            List.flatten(output_indices ++ get_all_outputs_for_user(tl(blockchain), outputs, unverified_transactions, public_address))
        end
    end

    def get_all_spent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address) do
        if length(blockchain) == 0 do
            []
        else
            block = hd(blockchain)
            input_indices = for t <- block.transactions, do: for o <- t.input_indices, is_owner?(Enum.at(outputs, o), public_address), do: o
            input_indices = input_indices ++ (for t <- unverified_transactions, do: for o <- t.input_indices, is_owner?(Enum.at(outputs, o), public_address), do: o)
            List.flatten(input_indices ++ get_all_spent_outputs_for_user(tl(blockchain), outputs, unverified_transactions, public_address))
        end
    end

    def get_transaction_inputs(unspent_output_indices, outputs, value) do
        cond do
         value <= 0 ->
            {[], 0 - value, true}
         length(unspent_output_indices) == 0 ->
            {[], 0, false}
         true ->
            head = hd(unspent_output_indices)
            deduct = Enum.at(outputs, head)
            {indices, change, is_possible} = get_transaction_inputs(tl(unspent_output_indices), outputs, value - deduct.value)
            {[head] ++ indices, change, is_possible}
        end
    end

    def get_balance_for_user_int(blockchain, outputs, unverified_transactions, public_address) do
        unspent_output_indices = get_unspent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address)
        Enum.sum(for t <- unspent_output_indices, do: Enum.at(outputs, t).value)
    end

    def get_balance_splits_int(blockchain, outputs, unverified_transactions, public_address) do
        unspent_output_indices = get_unspent_outputs_for_user(blockchain, outputs, unverified_transactions, public_address)
        for t <- unspent_output_indices, do: Enum.at(outputs, t).value
    end
end