defmodule BankApiWeb.RelatorioController do
  use BankApiWeb, :controller
  alias BankApi.Handle.Relatorio.HandleRelatorioAdministrador

  def saque(conn, params) do
    Map.merge(params, %{"operacao" => "Saque"})
    |> HandleRelatorioAdministrador.relatorio()
    |> handle_response(conn, "saque.json", :created)
  end

  def transferencia(conn, params) do
    Map.merge(params, %{"operacao" => "Transferencia"})
    |> HandleRelatorioAdministrador.relatorio()
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
    |> render("saque.json", error: retorno)
  end
end
