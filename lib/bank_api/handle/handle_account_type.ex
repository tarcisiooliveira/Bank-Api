defmodule BankApi.Handle.HandleAccountType do
  @moduledoc """
  Modulo de manipulação de dados Account Type através do Repo
  """

  alias BankApi.{Repo, Schemas.AccountType}
  alias BankApi.Multi.AccountType, as: MultiAccountType

  def get(%{id: id}) do
    case Repo.get_by(AccountType, id: id) do
      nil -> {:error, "Invalid ID or inexistent."}
      account_type -> {:ok, account_type}
    end
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiAccountType.delete()
  end

  def create(%{account_type_name: _name_account_type} = params) do
    params
    |> MultiAccountType.create()
  end

  def update(%{id: _id, account_type_name: _name_account_type} = params) do
    params
    |> MultiAccountType.update()
  end
end
