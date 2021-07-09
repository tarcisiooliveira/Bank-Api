defmodule BankApi.Handle.HandleTransaction do
  alias BankApi.Multi.Transaction, as: MultiTransaction
  alias BankApi.Handle.Repo.Transaction, as: HandleTransactionRepo

  @moduledoc """
  Modulo to manipulate Transaction by Repo
  """
  def get(%{id: _id}=params) do
    case HandleTransactionRepo.fetch_transaction(params) do
      nil -> {:error, "ID inválido."}
      transaction -> {:ok, transaction}
    end
  end

  def create(%{
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        operation_id: operation_id,
        value: value
      }) do
    %{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      operation_id: operation_id,
      value: value
    }
    |> MultiTransaction.create()
  end

  def create(%{
        from_account_id: from_account_id,
        operation_id: operation_id,
        value: value
      }) do
    %{
      from_account_id: from_account_id,
      operation_id: operation_id,
      value: value
    }
    |> MultiTransaction.create()
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiTransaction.delete()
  end
end
