defmodule BankApiWeb.RelatorioView do
  use BankApiWeb, :view

  def render("saque.json", %{
        retorno: %{
          origem: email1,
          destino: email2,
          mensagem: "Total durante determinado período entre dois usuários.",
          operacao: operacao,
          resultado: resultado
        }
      }) do
    %{
      origem: email1,
      destino: email2,
      mensagem: "Total durante determinado período entre dois usuários.",
      operacao: operacao,
      resultado: resultado
    }
  end

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
