defmodule Project4Web.UserController do
  use Project4Web, :controller

  def index(conn, _params) do
    # render(conn, "index.html")
    {miners_addresses, users_addresses} = get_all_addresses()
    json(conn, %{"miners_addresses": miners_addresses, "users_addresses": users_addresses})
  end

  def get_details(conn, _params) do
    # render(conn, "index.html")
    {_, user_id} = Map.fetch(_params, "user_id")
    # IO.inspect {"----------------", user_id}
    {user_address, balance, splits} = get_user_detail(user_id)
    json(conn, %{"user_address": user_address, "balance": balance, "splits": splits})
  end

  def get_all_addresses() do
    {name, pid, _, _} = Enum.at(Supervisor.which_children(Project4.Supervisor), 0)
    # IO.inspect {name, pid}
    {miners_addresses, users_addresses} = Project4.BitcoinSimulator.get_all_addresses(pid)
    {miners_addresses, users_addresses}
  end

  def get_user_detail(address) do
    {name, pid, _, _} = Enum.at(Supervisor.which_children(Project4.Supervisor), 0)
    # IO.inspect {name, pid}
    {user_address, balance, splits} = Project4.BitcoinSimulator.get_user_detail(pid, address)
    {user_address, balance, splits}
  end
end
