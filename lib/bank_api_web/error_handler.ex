defmodule BankApiWeb.Auth.ErrorHandler do
  @moduledoc """
  Handle de error do Plug de acesso. Retorna erro customizado para o usuário,
  não chega a entrar na aplicação.
  """

  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    body = Jason.encode!(%{message: "unauthorized"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
