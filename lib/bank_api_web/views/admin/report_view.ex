defmodule BankApiWeb.Admin.ReportView do
  use BankApiWeb, :view

  def render("report.json", %{
        return: %{
          mensagem: message,
          operation: operation,
          result: result
        }
      }) do
    %{
      mensagem: message,
      operation: operation,
      result: result
    }
  end

  def render("report.json", %{
        return: %{
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          mensagem: "Total durante determinado período entre dois usuários.",
          operation: operation,
          result: result
        }
      }) do
    %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      mensagem: "Total durante determinado período entre dois usuários.",
      operation: operation,
      result: result
    }
  end

  def render("report.json", %{
        return: %{
          mensagem: mensagem,
          operation: operation,
          result: result
        }
      }) do
    %{
      mensagem: mensagem,
      operation: operation,
      result: result
    }
  end

  def render("report.json", %{error: %{mensagem: error}}) do
    %{
      mensagem: error
    }
  end
end
