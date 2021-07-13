defmodule BankApiWeb.Report.ReportView do
  use BankApiWeb, :view

  def render("report.json", %{
        return: %{
          message: message,
          operation: operation,
          result: result
        }
      }) do
    %{
      message: message,
      operation: operation,
      result: result
    }
  end

  def render("report.json", %{
        return: %{
          message: message,
          result: result
        }
      }) do
    %{
      message: message,
      result: result
    }
  end

  def render("report.json", %{error: %{message: error}}) do
    %{
      message: error
    }
  end
end
