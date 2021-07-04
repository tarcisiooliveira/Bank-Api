defmodule BankApi.Handle.Repo.Operacao do
  alias BankApi.Repo
  alias BankApi.Schemas.Operacao

  def fetch_operation(%{id: id}) do
    Repo.get_by(Operacao, id: id)
  end

  def fetch_operation(%{nome_operacao: nome_operacao}) do
    Repo.get_by(Operacao, nome_operacao: nome_operacao)
  end

  def delete(operation) do
    Repo.delete(operation)
  end
end
