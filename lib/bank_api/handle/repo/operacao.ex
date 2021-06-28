defmodule BankApi.Handle.Repo.Operacao do
  alias BankApi.Repo
  alias BankApi.Schemas.Operacao

  def get_account(id) do
    Repo.get(Operacao, id)
  end

  def delete(operacao) do
    Repo.delete(operacao)
  end
end
