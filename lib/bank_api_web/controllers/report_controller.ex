defmodule BankApiWeb.ReportController do
  use BankApiWeb, :controller
  alias BankApi.Handle.Report.HandleReportAdmin

  def saque(conn, params) do
    Map.merge(params, %{"Operation" => "Withdraw"})
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  def transferencia(conn, params) do
    Map.merge(params, %{"Operation" => "Transfer"})
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  def payment(conn, params) do
    Map.merge(params, %{"Operation" => "Payment"})
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  defp handle_response(
         {:ok, return},
         conn,
         view,
         status
       ) do
    conn
    |> put_status(status)
    |> render(view, return: return)
  end

  defp handle_response({:error, return} = _params, conn, _view, _status) do
    conn
    |> put_status(:bad_request)
    |> render("report.json", error: return)
  end
end
