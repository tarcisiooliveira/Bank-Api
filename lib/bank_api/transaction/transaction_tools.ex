defmodule BankApi.Transaction.TransactionTools do
  @moduledoc """
  Tools used in
  """
  alias BankApi.Repo
  alias BankApi.Transactions.Schemas.Transaction

  def get_by_id(id) do
    case Repo.get_by(Transaction, id: id) do
      nil -> {:error, :not_found}
      transaction -> {:ok, transaction}
    end
  end
end
