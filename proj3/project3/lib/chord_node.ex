defmodule Project3.ChordNetworkNode do
    use GenServer

    # Client API

    def  start_link do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    def create(pid, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}) do
        GenServer.cast(pid, {:create, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}})
    end

    def start_requests(pid, num_requests, counter_pid) do
        GenServer.cast(pid, {:start_requests, num_requests, counter_pid})    
    end

    def start_request(pid, counter_pid) do
        GenServer.cast(pid, {:start_request, counter_pid})    
    end

    def print_info(pid) do
        GenServer.cast(pid, {:print_info})
    end

    def find_successor(pid, id_in, hop, counter_pid) do
        GenServer.cast(pid, {:find_successor, id_in, hop, counter_pid})
    end

    # Server Callbacks
    
    def init(:ok) do
        # {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id}
        {:ok, {nil, -1, [], nil, -1, 0}}
    end



    def handle_info({:make_next_request, i, num_requests, counter_pid}, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}) do
        if i < num_requests do
            pid = self()
            spawn fn -> GenServer.cast(pid, {:start_request, counter_pid}) end
            Process.send_after(self(), {:make_next_request, i + 1, num_requests, counter_pid}, 1000)
        else
            nil
        end
        {:noreply, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}}
    end

    
    
    def handle_cast({:find_successor, id_in, hop, counter_pid}, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}) do
        {_, successor_id} = Enum.at(node_fingers, 0)
        if Project3.Utility.belongs_to_left_open_right_closed(id_in, node_id, successor_id, max_value) do
            send(counter_pid, {:done, hop})
            # IO.inspect "Found"
        else
            n_dash_pid = closest_preceding_node(length(node_fingers) - 1, node_pid, node_id, id_in, node_fingers, max_value)
            # if n_dash_pid == self() do
            #     send(counter_pid, {:done, hop})
            #     IO.inspect "Not found"
            # end

            GenServer.cast(n_dash_pid, {:find_successor, id_in, hop + 1, counter_pid})
        end

        {:noreply, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}}
    end

    def handle_cast({:create, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}}, {_, _, _, _, _, _}) do
        {:noreply, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}}
    end

    def handle_cast({:print_info}, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}) do
        IO.inspect {"self", self(), "node_pid", node_id, "node_id", node_id, "node_predecessor_pid", node_predecessor_pid, "node_predecessor_id", node_predecessor_id, "max_value", max_value, node_fingers}
        {:noreply, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}}
    end

    def handle_cast({:start_requests, num_requests, counter_pid}, state) do
        Process.send_after(self(), {:make_next_request, 0, num_requests, counter_pid}, 100)
        {:noreply, state}
    end

    def handle_cast({:start_request, counter_pid}, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}) do
        rn = :rand.uniform(max_value) - 1
        IO.inspect {self(), "Sent a search request for", rn}
        GenServer.cast(node_pid, {:find_successor, rn, 0, counter_pid})
         
        {:noreply, {node_pid, node_id, node_fingers, node_predecessor_pid, node_predecessor_id, max_value}}
    end

    def closest_preceding_node(m, node_pid, node_id, id, fingers, max_value) do
        if m < 0 do
            node_pid
        else
            {successor_pid, successor_id} = Enum.at(fingers, m)
            if Project3.Utility.belongs_to_left_open_right_open(successor_id, node_id, id, max_value) do
                successor_pid
            else
                closest_preceding_node(m - 1, node_pid, node_id, id, fingers, max_value)
            end
        end
    end
end