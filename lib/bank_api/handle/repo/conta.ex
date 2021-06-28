defmodule BankApi.Handle.Repo.Conta do
  alias BankApi.Repo
  alias BankApi.Schemas.Conta

  def get_account(id) do
    Repo.get(Conta, id)
  end

  def delete(conta) do
    Repo.delete(conta)
  end
end
