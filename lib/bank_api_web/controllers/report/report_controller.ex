defmodule BankApiWeb.Report.ReportController do
  use BankApiWeb, :controller
  alias BankApi.Handle.Report.HandleReportAdmin

  def withdraw(conn, params) do
    Map.merge(params, %{"operation" => "Withdraw"})
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  def transfer(conn, params) do
    Map.merge(params, %{"operation" => "Transfer"})
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  def payment(conn, params) do
    Map.merge(params, %{"operation" => "Payment"})
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  def report(conn, params) do
    params
    |> HandleReportAdmin.report()
    |> handle_response(conn, "report.json", :created)
  end

  defp handle_response({:ok, return}, conn, view, status) do
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
