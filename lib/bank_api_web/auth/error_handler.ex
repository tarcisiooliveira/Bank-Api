defmodule BankApiWeb.Auth.ErrorHandler do
  @moduledoc """
  Handle de error do Plug de acesso. Retorna erro customizado para o usuário,
  não chega a entrar na aplicação.
  """

  import Plug.Conn


  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    body = Jason.encode!(%{messagem: "Authorization Denied"})
    send_resp(conn, 401, body)
  end

  def auth_error(conn, {:unauthorized, _reason}, _opts) do
    body = Jason.encode!(%{messagem: "Authorization Denied"})
    send_resp(conn, 401, body)
  end

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{messagem: to_string(type)})
    send_resp(conn, 401, body)
  end
end
