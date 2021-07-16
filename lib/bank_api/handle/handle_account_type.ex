defmodule BankApi.Handle.HandleAccountType do
  @moduledoc """
  Modulo de manipulação de dados Account Type através do Repo
  """

  alias BankApi.{Repo, Schemas.AccountType}
  alias BankApi.Multi.AccountType, as: MultiAccountType

  @doc """
  ##Example get AccountType by valid_id
    iex> get(%{id: valid_id})
    {:ok, %AccountType{}}

  ##Example get - fetch user by id
    iex> get(%{id: invalid_id})
    {:error, "Invalid ID or inexistent."}
  """
  def get(%{id: id}) do
    case Repo.get_by(AccountType, id: id) do
      nil -> {:error, "Invalid ID or inexistent."}
      account_type -> {:ok, account_type}
    end
  end

  @doc """
  Get AccountType id and remove than from database
    ##Example
    iex> delete(%{id: id})
     {:ok, params}

    iex> delete(%{id: invalid_id})
    {:error, error}
  """
  def delete(%{id: _id} = params) do
    params
    |> MultiAccountType.delete()
  end

  @doc """
  Set AccountType parameters, create new AccountType
    ##Example
    iex> create(%{account_type_name: _name_account_type})
    {:ok, %AccountType}

  """
  def create(%{account_type_name: _name_account_type} = params) do
    params
    |> MultiAccountType.create()
  end

  @doc """
  Set AccountType id and account_type_name than update balance_account
    ##Example update account_type_name
    iex> update(%{id: _id, account_type_name: _name_account_type})
    {:ok, %AccountType{}}
  """
  def update(%{id: _id, account_type_name: _name_account_type} = params) do
    params
    |> MultiAccountType.update()
  end
end
