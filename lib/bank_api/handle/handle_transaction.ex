defmodule BankApi.Handle.HandleTransaction do
  @moduledoc """
  Module to manipulate Transaction by Repo
  """

  alias BankApi.Multi.Transaction, as: MultiTransaction

  @doc """
  Set users, create new user
    ##Example
    iex> create(%{from_account_id: from_account_id, to_account_id: to_account_id, operation_id: operation_id, value: value})
    {:ok, %Transaction}

    iex> create(%{from_account_id: from_account_id, operation_id: operation_id, value: value})
    {:ok, %Transaction}

    iex> create(%{from_account_id: from_account_id, to_account_id: to_account_id, operation_id: operation_id, value: value})
    {:error, error}

    iex> create(%{from_account_id: from_account_id, operation_id: operation_id, value: value})
    {:error, error}
  """

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

  @doc """
  ##Example delete Transaction by valid_id
    iex> delete(%{id: valid_id})
    {:ok, %Transaction{}}

  ##Example get - fetch user by id
    iex> get(%{id: invalid_id})
    {:error, error}
  """
  def delete(%{id: _id} = params) do
    params
    |> MultiTransaction.delete()
  end

  @doc """
  ##Example get Transaction by valid_id
    iex> get(%{id: valid_id})
    {:ok, %Transaction{}}

  ##Example get - fetch user by id
    iex> get(%{id: invalid_id})
    {:error, "Invalid ID or inexistent."s}
  """
  def get(%{id: id}) do
    case Repo.get_by(Transaction, id: id) do
      nil -> {:error, "nvalid ID or inexistent."}
      transaction -> {:ok, transaction}
    end
  end
end
