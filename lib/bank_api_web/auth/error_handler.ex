defmodule BankApiWeb.Auth.ErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    # IO.inspect(type)
    body = Jason.encode!(%{messagem: "Autorização Negada"})
    send_resp(conn, 401, body)
  end

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{messagem: to_string(type)})
    send_resp(conn, 401, body)
  end
end
