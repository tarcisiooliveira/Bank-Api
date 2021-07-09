defmodule BankApiWeb.ReportView do
  use BankApiWeb, :view

  def render("report.json", %{
        return: %{
          from_account_id: account_id_1,
          to_account_id: account_id_2,
          mensagem: "Total durante determinado período entre dois usuários.",
          Operation: Operation,
          resultado: resultado
        }
      }) do
    %{
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      mensagem: "Total durante determinado período entre dois usuários.",
      Operation: Operation,
      resultado: resultado
    }
  end

  def render("report.json", %{
        return: %{
          mensagem: mensagem,
          Operation: Operation,
          resultado: resultado
        }
      }) do
    %{
      mensagem: mensagem,
      Operation: Operation,
      resultado: resultado
    }
  end

  def render("report.json", %{error: %{mensagem: error}}) do
    %{
      mensagem: error
    }
  end
end
