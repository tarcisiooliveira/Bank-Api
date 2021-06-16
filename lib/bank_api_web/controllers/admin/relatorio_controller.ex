defmodule BankApiWeb.RelatorioController do
  use BankApiWeb, :controller
  alias BankApi.Handle.Relatorio.HandleRelatorioAdministrador

  def saque(conn, params) do
    params
    |> HandleRelatorioAdministrador.saque()
    |> handle_response(conn, "saque.json", :created)
  end

  defp handle_response(
         {:ok, retorno},
         conn,
         view,
         status
       ) do
    conn
    |> put_status(status)
    |> render(view, retorno: retorno)
  end

  defp handle_response({:error, retorno} = _params, conn, _view, _status) do
    conn
    |> put_status(:bad_request)
    |> render("error.view", error: retorno)
  end

  # defp handle_response({:error, error} = result, conn, view, status) do
  #   result
  # end
end
