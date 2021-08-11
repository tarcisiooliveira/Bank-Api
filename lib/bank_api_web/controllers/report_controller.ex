defmodule BankApiWeb.ReportController do
  use BankApiWeb, :controller
  alias BankApi.Report.HandleReport
  action_fallback BankApiWeb.FallbackController

  def report(conn, params) do
    with {:ok, result: result} <- HandleReport.report(params) do
      conn
      |> put_status(:not_found)
      |> render("reports.json", result: result)
    end
  end
end
