defmodule BankApi.Handle.HandleTransaction do
  alias BankApi.Multi.Transaction, as: MultiTransaction
  alias BankApi.Handle.Repo.Transaction, as: HandleTransactionRepo

  @moduledoc """
  Modulo de manipulação de dados Transação através do Repo
  """
  def get(%{id: id}) do
    case HandleTransactionRepo.fetch_transaction(id) do
      nil -> {:error, "ID inválido."}
      Transaction -> {:ok, Transaction}
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
    |> MultiTransacao.create()
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
    |> MultiTransacao.create()
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiTransacao.delete()
  end
end
