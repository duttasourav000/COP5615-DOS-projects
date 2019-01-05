defmodule Project4.BitcoinSimulator do
    use Bitwise
    use GenServer

    # Client API

    def  start_link do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def transfer_bitcoin(pid) do
        GenServer.cast(pid, {:transfer_bitcoin})
    end

    def mine_block(pid) do
        GenServer.cast(pid, {:mine_block})
    end

    def add_log(pid, log) do
        GenServer.cast(pid, {:add_log, log})
    end

    def get_user_detail(pid, address) do
        GenServer.call(pid, {:get_user_detail, address})
    end

    def get_all_addresses(pid) do
        GenServer.call(pid, {:get_all_addresses})
    end

    def get_all_logs(pid) do
        GenServer.call(pid, {:get_all_logs})
    end

    def create_graph_data(pid) do
        GenServer.cast(pid, {:create_graph_data})
    end

    def get_graph_data(pid) do
        GenServer.call(pid, {:get_graph_data})
    end

    # Server Callbacks
    
    def init(:ok) do
        miners_temp = for _ <- 1..25, do: Project4.UserNode.start_link()
        miners = for {_, pid} <- miners_temp, do: pid

        users_temp = for _ <- 1..75, do: Project4.UserNode.start_link()
        users = for {_, pid} <- users_temp, do: pid
                
        {:ok, ledger_pid} = Project4.GlobalLedger.start_link()
        Enum.map(miners, fn pid -> Project4.UserNode.start(pid, {ledger_pid}) end)
        Enum.map(users, fn pid -> Project4.UserNode.start(pid, {ledger_pid}) end)

        Process.send_after(self(), :mine_block_info, 2_000)
        Process.send_after(self(), :transfer_bitcoin_info, 3_000)
        Process.send_after(self(), :create_graph_data_info, 10_000)
        {:ok, {miners, users, ledger_pid, [], MapSet.new(), [0]}}
    end

    def handle_info(:mine_block_info, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        pid = self()
        Project4.BitcoinSimulator.mine_block(pid)
        {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_info(:transfer_bitcoin_info, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        pid = self()
        Project4.BitcoinSimulator.transfer_bitcoin(pid)
        {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_info(:create_graph_data_info, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        pid = self()
        Project4.BitcoinSimulator.create_graph_data(pid)
        Process.send_after(self(), :create_graph_data_info, 10_000)
        {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_cast({:mine_block}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        random_index = :rand.uniform(length(miners)) - 1
        Project4.UserNode.add_block(Enum.at(miners, random_index), self())
        
        # address = Project4.UserNode.get_public_address(Enum.at(miners, random_index))
        potential_users_with_money = MapSet.put(potential_users_with_money, Enum.at(miners, random_index))

        Process.send_after(self(), :mine_block_info, 10_000)
        {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_cast({:add_log, log}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        logs = logs ++ [log]
        {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_cast({:transfer_bitcoin}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        potential_user_list = MapSet.to_list(potential_users_with_money)
        random_index_1 = :rand.uniform(length(miners) + length(users)) - 1
        random_user_1 =
            if random_index_1 < length(miners) do
                Enum.at(miners, random_index_1)
            else
                Enum.at(users, random_index_1 - length(miners))
            end
        
        random_user_1 =
            if :rand.uniform() > 0.1 and length(potential_user_list) > 0 do
                Enum.at(potential_user_list, :rand.uniform(length(potential_user_list)) - 1)
            else
                random_user_1
            end

        random_index_2 = :rand.uniform(length(miners) + length(users)) - 1
        random_user_2 =
            if random_index_2 < length(miners) do
                Enum.at(miners, random_index_2)
            else
                Enum.at(users, random_index_2 - length(miners))
            end

        address_1 = Project4.UserNode.get_public_address(random_user_1)
        address_2 = Project4.UserNode.get_public_address(random_user_2)
        if address_1 != address_2 do
            potential_users_with_money = MapSet.put(potential_users_with_money, random_user_2)

            money = :rand.uniform(5)
            Project4.GlobalLedger.transfer(ledger_pid, address_1, address_2, money, self())
            # logs = logs ++ ["Transfer initiated from " + inspect(address_2) + " to " + inspect(address_2) + " of " + inspect(money) + " bitcoins."]
            Process.send_after(self(), :transfer_bitcoin_info, 2_000)
            {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
        else
            {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
        end
    end

    def handle_cast({:create_graph_data}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        s = get_current_sum_of_bitcoins(miners, users, ledger_pid)
        {:noreply, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum ++ [s]}}
    end

    def handle_call({:get_user_detail, address}, _, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        user_pid = get_user_pid(address, miners ++ users)
        if user_pid == nil do 
            {:reply, {nil, nil}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
        else
            balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, address)
            splits = Project4.GlobalLedger.get_balance_splits_for_user(ledger_pid, address)
            {:reply, {address, balance, splits}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
        end
    end

    def handle_call({:get_all_addresses}, _, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        miners_addresses = Enum.map(miners, fn pid -> Project4.UserNode.get_public_address(pid) end)
        users_addresses = Enum.map(users, fn pid -> Project4.UserNode.get_public_address(pid) end)

        {:reply, {miners_addresses, users_addresses}, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_call({:get_all_logs}, _, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        {:reply, logs, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def handle_call({:get_graph_data}, _, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}) do
        {:reply, bitcoins_sum, {miners, users, ledger_pid, logs, potential_users_with_money, bitcoins_sum}}
    end

    def get_user_pid(address, users) do
        if length(users) == 0 do
            nil
        else
            x = hd(users)
            if address == Project4.UserNode.get_public_address(x) do
                x
            else
                get_user_pid(address, tl(users))
            end
        end
    end

    def get_current_sum_of_bitcoins(miners, users, ledger_pid) do
        addresses = Enum.map(miners, fn pid -> Project4.UserNode.get_public_address(pid) end)
        addresses = addresses ++ Enum.map(users, fn pid -> Project4.UserNode.get_public_address(pid) end)
        Enum.sum(Enum.map(addresses, fn address -> Project4.GlobalLedger.get_balance_for_user(ledger_pid, address) end))
    end
end