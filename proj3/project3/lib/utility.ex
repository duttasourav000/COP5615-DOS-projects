defmodule Project3.Utility do
    use Bitwise
    def check_completion(parent, n, c, hop_sum) do
        receive do
          {:done, hops} ->
            # IO.inspect {"check_completion", c}
            if c + 1 == n do
              send(parent, {:done, hop_sum + hops})
            else
              check_completion(parent, n, c + 1, hop_sum + hops)
            end
        end
    end

    def pow_2(n) do
        cond do
            n == 0 ->
                1
            n == 1 ->
                2
            Integer.mod(n, 2) == 1 ->
                p = pow_2(Integer.floor_div(n, 2))
                p * p * 2
            true ->
                p = pow_2(Integer.floor_div(n, 2))
                p * p
        end
    end

    def spawn_n_processes(n) do
        if n == 0 do
          []
        else
            {:ok, pid} = Project3.ChordNetworkNode.start_link()
            [pid] ++ spawn_n_processes(n - 1)
        end
    end

    def belongs_to_left_open_right_closed(n, l, r, max_value) do
        max_key = max_value - 1
        min_key = 0
        condition_value = 
            if r <= l do
                (n > l and n <= max_key) or (n >= min_key and n <= r)
            else
                n > l and n <= r
            end

        condition_value
    end

    def belongs_to_left_open_right_open(n, l, r, max_value) do
        max_key = max_value - 1
        min_key = 0
        condition_value = 
            if r <= l do
                (n > l and n <= max_key) or (n >= min_key and n < r)
            else
                n > l and n < r
            end

        condition_value
    end

    def get_neighbors(pids, index, i, m, fingers, max_value) do
        if i >= m do
            fingers
        else
            s = 1 <<< i
            final_index = Integer.mod(index + s, max_value)
            fingers = List.replace_at(fingers, i, {Enum.at(pids, final_index), final_index})
            get_neighbors(pids, index, i + 1, m, fingers, max_value)
        end
    end

    def get_power_2_round(n, c) do
        # IO.inspect {"c", c}
        if c >= n do
            c
        else
            get_power_2_round(n, c <<< 1)
        end
    end

    def calculate_m(value, i) do
        if (1 <<< i) >= value do
            i
        else
            calculate_m(value, i + 1)
        end
    end

    def get_neighbors_map(pids, m, i) do
        if length(pids) == i do
            %{}
        else
            fingers = List.duplicate({nil, -1}, m)
            current_pid_neighbors = get_neighbors(pids, i, 0, m, fingers, length(pids))

            node = Enum.at(pids, i)
            Map.merge(
                %{node => current_pid_neighbors},
                get_neighbors_map(pids, m, i + 1)
            )
        end
    end  
end