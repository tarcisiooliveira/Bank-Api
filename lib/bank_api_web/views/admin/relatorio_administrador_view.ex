defmodule BankApiWeb.RelatorioView do
  use BankApiWeb, :view

  def render("saque.json", %{
        retorno: %{
          mensagem: "Total de saque durante determinado período por determinado usuario.",
          email: email,
          resultado: resultado
        }
      }) do
    %{
      mensagem: "Total de saque durante determinado período por determinado usuario.",
      email: email,
      resultado: resultado
    }
  end

  def render("saque.json", %{
        retorno: %{
          mensagem: "Total de saque durante todo o período",
          resultado: resultado
        }
      }) do
    %{
      mensagem: "Total de saque durante todo o período",
      resultado: resultado
    }
  end

  def render("saque.json", %{
        retorno: %{
          mensagem: "Total de saque realizado por determinado email",
          resultado: resultado
        }
      }) do
    %{
      mensagem: "Total de saque realizado por determinado email",
      resultado: resultado
    }
  end

  def render("saque.json", %{
        retorno: %{
          mensagem: "Total de saque durante determinado período por todos usuários.",
          resultado: resultado
        }
      }) do
    %{
      mensagem: "Total de saque durante determinado período por todos usuários.",
      resultado: resultado
    }
  end
end
