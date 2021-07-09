defmodule BankApi.Handle.Repo.Transaction do
  alias BankApi.Repo
  alias BankApi.Schemas.Transaction

  def fetch_transaction(id) do
    Repo.get(Transaction, id)
  end

  def delete(transaction) do
    Repo.delete(transaction)
  end
end
