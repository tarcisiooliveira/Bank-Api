defmodule BankApi.Handle.Repo.Transaction do
  @moduledoc """
    This Module is responsable to fetch Transaction informations on DataBase.
  """

  alias BankApi.Repo
  alias BankApi.Schemas.Transaction

  def fetch_transaction(%{id: id}) do
    Repo.get_by(Transaction, id: id)
  end

  def delete(transaction) do
    Repo.delete(transaction)
  end
end
