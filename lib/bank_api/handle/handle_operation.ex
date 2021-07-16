defmodule BankApi.Handle.HandleOperation do
  @moduledoc """
  Module manipule Operations by Repo
  """

  alias BankApi.Schemas.Operation
  alias BankApi.Repo
  alias BankApi.Multi.Operation, as: MultiOperation

  @doc """
  ##Example get Operation by valid_id
    iex> get(%{id: valid_id})
    {:ok, %Operation{}}

  ##Example get - fetch operation by id
    iex> get(%{id: invalid_id})
    {:error, "Invalid ID or inexistent."}
  """
  def get(%{id: id}) do
    case Repo.get_by(Operation, id: id) do
      nil -> {:error, "Invalid ID or inexistent."}
      operation -> {:ok, operation}
    end
  end

  @doc """
  Set Operation, create new Operation
    ##Example
    iex> create(%{operation_name: _name_operation})
    {:ok, %Transaction}

    iex> create(%{from_account_id: from_account_id, operation_id: operation_id, value: value})
    {:ok, %Transaction}

    iex> create(%{from_account_id: from_account_id, to_account_id: to_account_id, operation_id: operation_id, value: value})
    {:error, error}

    iex> create(%{from_account_id: from_account_id, operation_id: operation_id, value: value})
    {:error, error}
  """
  def create(%{operation_name: _name_operation} = params) do
    MultiOperation.create(params)
  end

  @doc """
  Set Operation id and operation_name than update
    ##Example update email
    iex> update(%{id: id, operation_name: "New Operation Name"})
    {:ok, %Operation{}}

    iex> update(%{id: invalid_id, operation_name: "New Operation Name"})
    {:error, %Changeset{}}
  """
  def update(%{id: _id, operation_name: _name_operation} = params) do
    MultiOperation.update(params)
  end
 @doc """
  Get Operation id and remove than from database
    ##Example
    iex> delete(%{id: id})
    {:ok, params}

    iex> delete(%{id: invalid_id})
    {:error, error}
  """
  def delete(%{id: _id} = params) do
    MultiOperation.delete(params)
  end
end
