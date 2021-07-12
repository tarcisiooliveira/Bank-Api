defmodule BankApi.Handle.HandleAccount do
  alias BankApi.Multi.Account, as: MultiAccount
  alias BankApi.Handle.Repo.Account, as: HandleRepoAccount

  @moduledoc """
  Modulo de manipulação de dados Account
  """
  def get(%{id: _id} = params) do
    case HandleRepoAccount.fetch_account(params) do
      nil -> {:error, "Invalid ID or inexistent."}
      account -> {:ok, account}
    end
  end

  @spec create(%{:account_type_id => any, :user_id => any, optional(any) => any}) ::
          {:error, any} | {:ok, any}
  def create(params) do
    params
    |> MultiAccount.create()
  end

  def update(%{id: _id, balance_account: _balance_account} = params) do
    params
    |> MultiAccount.update()
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiAccount.delete()
  end
end
