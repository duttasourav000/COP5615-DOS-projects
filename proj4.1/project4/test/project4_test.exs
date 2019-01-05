defmodule Project4Test do
  use ExUnit.Case
  doctest Project4

  test "greets the world" do
    assert Project4.hello() == :world
  end

  test "create the shared ledger" do
    # create the shared ledged
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()
    assert Process.alive?(ledger_pid)

    {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
    assert length(blockchain) == 1
    assert length(outputs) == 0
    assert length(transactions) == 0
    assert length(unverified_transactions) == 1
  end

  test "create a miner" do
    # create a miner
    {:ok, pid_1} = Project4.UserNode.start_link()
    assert Process.alive?(pid_1)
  end
  
  test "start the miner" do
    # create the shared ledged
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()

    # create a miner
    {:ok, pid_1} = Project4.UserNode.start_link()

    # start the miner
    Project4.UserNode.start(pid_1, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    # Project4.GlobalLedger.print_info(ledger_pid)
    assert Project4.GlobalLedger.validate(ledger_pid) == true
  end

  test "test unspent outputs" do
    # create the shared ledged
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()

    # create a miner
    {:ok, pid_1} = Project4.UserNode.start_link()

    IO.inspect {"Test: Before mining -----"}
    public_address_1 = Project4.UserNode.get_public_address(pid_1)
    IO.inspect {"Test: public_address_1", public_address_1}

    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_1)
    IO.inspect {"Test: unspent_outputs", unspent_outputs}

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_1)
    IO.inspect {"Test: balance", balance}

    # start the miner
    Project4.UserNode.start(pid_1, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    IO.inspect {"Test: After mining -----"}
    public_address_1 = Project4.UserNode.get_public_address(pid_1)
    IO.inspect {"Test: public_address_1", public_address_1}

    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_1)
    IO.inspect {"Test: unspent_outputs", unspent_outputs}

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_1)
    IO.inspect {"Test: balance", balance}
    assert balance == 15
  end

  test "test two blockchain updates" do
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()
    {:ok, pid_1} = Project4.UserNode.start_link()
    public_address_1 = Project4.UserNode.get_public_address(pid_1)
    Project4.UserNode.start(pid_1, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    # public_address_1 = Project4.UserNode.get_public_address(pid_1)
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_1)
    assert length(unspent_outputs) == 1
    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_1)
    assert balance == 15

    # create another miner
    {:ok, pid_2} = Project4.UserNode.start_link()

    public_address_2 = Project4.UserNode.get_public_address(pid_2)
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_outputs) == 0

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 0

    # start the miner
    Project4.UserNode.start(pid_2, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          # these should remail the same as before as blockchain update should fail
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    # no unspent output should be available to the second user
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_outputs) == 0

    # balance should be zero for the second user
    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 0
  end

  test "test transaction failure and success" do
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()
    {:ok, pid_1} = Project4.UserNode.start_link()
    public_address_1 = Project4.UserNode.get_public_address(pid_1)
    Project4.UserNode.start(pid_1, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_1)
    assert length(unspent_outputs) == 1
    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_1)
    assert balance == 15

    # create another miner
    {:ok, pid_2} = Project4.UserNode.start_link()

    public_address_2 = Project4.UserNode.get_public_address(pid_2)
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_outputs) == 0

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 0

    # start the miner
    Project4.UserNode.start(pid_2, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          # these should remail the same as before as blockchain update should fail
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    # no unspent output should be available to the second user
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_outputs) == 0

    # balance should be zero for the second user
    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 0

    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 20)
    receive do
    after
      1000 ->
        {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 10)
    receive do
    after
      1000 ->
        {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(blockchain) == 2
          assert length(outputs) == 3
          assert length(transactions) == 2
          assert length(unverified_transactions) == 1
    end

    Project4.UserNode.add_block(pid_2)
    receive do
    after
      3000 ->
        {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        # IO.inspect {length(blockchain), length(outputs), length(transactions), length(unverified_transactions)}
        # IO.inspect transactions
        # IO.inspect outputs
        assert length(blockchain) == 3
        assert length(outputs) == 4
        assert length(transactions) == 4
        assert length(unverified_transactions) == 0
        
    end
  end

  test "test combine change" do
    {:ok, ledger_pid} = Project4.GlobalLedger.start_link()
    {:ok, pid_1} = Project4.UserNode.start_link()
    public_address_1 = Project4.UserNode.get_public_address(pid_1)
    Project4.UserNode.start(pid_1, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_1)
    assert length(unspent_outputs) == 1
    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_1)
    assert balance == 15

    # create another miner
    {:ok, pid_2} = Project4.UserNode.start_link()

    public_address_2 = Project4.UserNode.get_public_address(pid_2)
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_outputs) == 0

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 0

    # start the miner
    Project4.UserNode.start(pid_2, {ledger_pid})

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          # these should remail the same as before as blockchain update should fail
          assert length(blockchain) == 2
          assert length(outputs) == 1
          assert length(transactions) == 2
          assert length(unverified_transactions) == 0
    end

    # no unspent output should be available to the second user
    unspent_outputs = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_outputs) == 0

    # balance should be zero for the second user
    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 0

    # one big transaction
    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 5)
    receive do
    after
      1000 ->
        {_, _, _, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(unverified_transactions) == 1
    end

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 5

    # smaller transactions
    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 1)
    receive do
    after
      1000 ->
        {_, _, _, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(unverified_transactions) == 2
    end

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 6

    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 2)
    receive do
    after
      1000 ->
        {_, _, _, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(unverified_transactions) == 3
    end

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 8

    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 1)
    receive do
    after
      1000 ->
        {_, _, _, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(unverified_transactions) == 4
    end

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 9

    Project4.GlobalLedger.transfer(ledger_pid, public_address_1, public_address_2, 1)
    receive do
    after
      1000 ->
        {_, _, _, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
        assert length(unverified_transactions) == 5
    end

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 10

    Project4.UserNode.add_block(pid_1)

    receive do
      after
        3000 ->
          {blockchain, outputs, transactions, unverified_transactions} = Project4.GlobalLedger.get_ledger_data(ledger_pid)
          # IO.inspect {length(blockchain), length(outputs), length(transactions), length(unverified_transactions)}
          assert length(blockchain) == 3
          assert length(outputs) == 12
          assert length(transactions) == 8
          assert length(unverified_transactions) == 0
    end

    balance = Project4.GlobalLedger.get_balance_for_user(ledger_pid, public_address_2)
    assert balance == 10

    unspent_output_indices = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
    assert length(unspent_output_indices) == 5

    Project4.GlobalLedger.combine_change(ledger_pid, public_address_2)
    receive do
    after
      1000 ->
        unspent_output_indices = Project4.GlobalLedger.get_unspent_outputs(ledger_pid, public_address_2)
        assert length(unspent_output_indices) == 2
    end
  end
end