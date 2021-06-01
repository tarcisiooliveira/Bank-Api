defmodule BankApiWeb.TipoContaView do
  use BankApiWeb, :view
  alias BankApi.Schemas.TipoConta

  def render("show.json", %{tipo_conta: %TipoConta{nome_tipo_conta: nome}}) do
    %{
      mensagem: "Show",
      tipo_conta: %{nome_tipo_conta: nome}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("error.json", %{error: error}), do: %{error: "#{error}"}

  def render("create.json", %{tipo_conta: %TipoConta{nome_tipo_conta: nome_tipo_conta}}) do
    %{
      mensagem: "Tipo Conta criado com sucesso!",
      "Tipo Conta": %{nome_tipo_conta: nome_tipo_conta}
    }
  end

  def render("update.json", %{tipo_conta: %TipoConta{nome_tipo_conta: nome_tipo_conta}}) do
    %{
      mensagem: "Tipo Conta alterado com sucesso!",
      "Tipo Conta": %{nome_tipo_conta: nome_tipo_conta}
    }
  end
end
