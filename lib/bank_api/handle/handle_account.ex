defmodule BankApi.Handle.HandleAccount do
  @moduledoc """
  Module to manipulate Account by Repo
  """

  alias BankApi.Multi.Account, as: MultiAccount
  alias BankApi.Schemas.Account
  alias BankApi.Repo

  @doc """
  ##Example get Account
    iex> get(%{id: valid_id})
    {:ok, %Account{}}

    ##Example get - fetch Account by id
    iex> get(%{id: invalid_id})
    {:error, "Invalid ID or inexistent."}
  """
  def get(%{id: _id} = params) do
    case Repo.get_by(Account, params) do
      nil -> {:error, "Invalid ID or inexistent."}
      account -> {:ok, account}
    end
  end

  @doc """
  Set account parameters, create new Account
    ##Example
    iex> create(%{balance_account: balance_account, user_id: user_id, account_type_id: account_type_id})
    {:ok, %Account}

    iex> create(%{balance_account: -100, user_id: user_id, account_type_id: account_type_id})
    {:error, reason}
  """
  def create(params) do
    params
    |> MultiAccount.create()
  end

  @doc """
  Set Account id and update balance_account
    ##Example update balance_account
    iex> update(%{id: _id, balance_account: _balance_account})
    {:ok, %Account{}}

    iex> update(%{id: invalid_id, balance_account: _balance_account})
    {:error, %Changeset{}}
  """
  def update(%{id: _id, balance_account: _balance_account} = params) do
    params
    |> MultiAccount.update()
  end

  @doc """
  Get Account id and remove than from database
    ##Example
    iex> delete(%{id: id})
     {:ok, params}

    iex> delete(%{id: invalid_id})
    {:error, error}
  """
  def delete(%{id: _id} = params) do
    params
    |> MultiAccount.delete()
  end
end
