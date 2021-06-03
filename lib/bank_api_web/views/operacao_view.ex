defmodule BankApiWeb.OperacaoView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Operacao
  alias Ecto.Changeset

  def render("show.json", %{operacao: %Operacao{nome_operacao: _nome_operacao}}) do
    %{
      mensagem: "Tipo Operação encotrado"
      # "Tipo Operacao": %{nome_operacao: nome_operacao}
    }
  end

  def render("create.json", %{operacao: %Operacao{nome_operacao: nome_operacao}}) do
    %{
      mensagem: "Operação Cadastrada",
      Operação: %{nome_operacao: nome_operacao}
    }
  end

  def render("update.json", %{operacao: %Operacao{nome_operacao: nome_operacao}}) do
    %{
      mensagem: "Operação Atualizada",
      Operação: %{nome_operacao: nome_operacao}
    }
  end

  def render("delete.json", %{operacao: %Operacao{nome_operacao: nome_operacao}}) do
    %{
      mensagem: "Operacao #{nome_operacao} removida com sucesso."
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Resultado: "Operação inexistente.",
      Mensagem: "#{error}"
    }
  end

  def render(
        "error.json",
        %{error: %Changeset{errors: [nome_operacao: {"has already been taken", _error}]}} =
          _params
      ) do
    %{error: "Usuario já cadastrado com esse email"}
  end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
