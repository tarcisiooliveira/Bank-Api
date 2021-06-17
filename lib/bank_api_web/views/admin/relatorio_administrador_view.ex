defmodule BankApiWeb.RelatorioView do
  use BankApiWeb, :view

  def render("saque.json", %{
        retorno: %{
          mensagem: mensagem,
          operacao: operacao,
          email: email,
          resultado: resultado
        }
      }) do
    %{
      mensagem: mensagem,
      operacao: operacao,
      email: email,
      resultado: resultado
    }
  end

  def render("saque.json", %{
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

  def render("saque.json", %{error: %{mensagem: error}}) do
    %{
      mensagem: error
    }
  end
end
