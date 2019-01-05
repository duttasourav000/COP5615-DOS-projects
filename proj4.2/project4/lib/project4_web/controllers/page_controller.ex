defmodule Project4Web.PageController do
  use Project4Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def bitcoinssum(conn, _params) do
    bitcoins = get_bitcoin_sum_data()
    json(conn, %{"bitcoins": bitcoins})
  end

  def get_bitcoin_sum_data() do
    {name, pid, _, _} = Enum.at(Supervisor.which_children(Project4.Supervisor), 0)
    # IO.inspect {name, pid}
    Project4.BitcoinSimulator.get_graph_data(pid)
  end
end
