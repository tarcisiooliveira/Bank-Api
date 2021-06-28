defmodule BankApiWeb.RelatorioController do
  use BankApiWeb, :controller
  alias BankApi.Handle.Relatorio.HandleRelatorioAdministrador

  def saque(conn, params) do
    Map.merge(params, %{"operacao" => "Saque"})
    |> HandleRelatorioAdministrador.relatorio()
    |> handle_response(conn, "relatorio.json", :created)
  end

  def transferencia(conn, params) do
    Map.merge(params, %{"operacao" => "Transferência"})
    |> HandleRelatorioAdministrador.relatorio()
    |> handle_response(conn, "relatorio.json", :created)
  end

  def pagamento(conn, params) do
    Map.merge(params, %{"operacao" => "Pagamento"})
    |> HandleRelatorioAdministrador.relatorio()
    |> handle_response(conn, "relatorio.json", :created)
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
    |> render("relatorio.json", error: retorno)
  end
end
