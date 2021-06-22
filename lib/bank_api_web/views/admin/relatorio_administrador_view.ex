defmodule BankApiWeb.RelatorioView do
  use BankApiWeb, :view

  def render("relatorio.json", %{
        retorno: %{
          conta_origem_id: conta_id_1,
          conta_destino_id: conta_id_2,
          mensagem: "Total durante determinado período entre dois usuários.",
          operacao: operacao,
          resultado: resultado
        }
      }) do
    %{
      conta_origem_id: conta_id_1,
      conta_destino_id: conta_id_2,
      mensagem: "Total durante determinado período entre dois usuários.",
      operacao: operacao,
      resultado: resultado
    }
  end

  def render("relatorio.json", %{
        retorno: %{
          mensagem: mensagem,
          operacao: operacao,
          resultado: resultado
        }
      }) do
    %{
      mensagem: mensagem,
      operacao: operacao,
      resultado: resultado
    }
  end

  def render("relatorio.json", %{error: %{mensagem: error}}) do
    %{
      mensagem: error
    }
  end
end
