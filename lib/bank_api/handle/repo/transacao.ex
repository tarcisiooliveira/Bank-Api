defmodule BankApi.Handle.Repo.Transacao do
  alias BankApi.Repo
  alias BankApi.Schemas.Transacao

  def fetch_transaction(id) do
    Repo.get(Transacao, id)
  end

  def delete(transaction) do
    Repo.delete(transaction)
  end
end
