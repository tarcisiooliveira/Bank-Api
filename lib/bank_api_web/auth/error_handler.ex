defmodule BankApiWeb.AuthErrorHandler do
  @moduledoc """
  Guardian handler module
  """
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    body = Phoenix.json_library().encode!(%{message: "unauthorized"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
