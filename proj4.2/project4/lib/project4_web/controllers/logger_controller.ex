defmodule Project4Web.LoggerController do
  use Project4Web, :controller

  def index(conn, _params) do
    # render(conn, "index.html")
    logs = get_all_logs()
    json(conn, %{"all_logs": logs})
  end

  def get_all_logs() do
    {name, pid, _, _} = Enum.at(Supervisor.which_children(Project4.Supervisor), 0)
    # IO.inspect {name, pid}
    logs = Project4.BitcoinSimulator.get_all_logs(pid)
    logs
  end
end
