defmodule BankApi.Multi.Operation do
  @moduledoc """
    This Module valid manipulations of Operations and the persist in DataBase or RollBack if something is worng.
  """

  alias BankApi.Schemas.Operation
  alias BankApi.Repo
  alias Ecto.Changeset

  @doc """
  Validate and persist an Operation

  ## Parameters
    `operation_name` - String Name of Operations

  ## Examples

      iex> create(%{operation_name: operation_name})
      {:ok, %{create_transaction: %Operation{}}}

      iex> create(%{operation_name: operation_name_already_exist})
      {:error, :operation_already_exists}
  """
  def create(
        %{
          operation_name: operation_name
        } = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case Repo.get_by(Operation, operation_name: operation_name) do
          nil -> {:ok, :operation_not_exists}
          _ -> {:error, :operation_already_exists}
        end
      end)
      |> Ecto.Multi.run(:operation_changeset, fn _, _ ->
        case create_changest(params) do
          %Changeset{valid?: true} = changeset ->
            {:ok, changeset}

          %Changeset{errors: [operation_name: {error, _}]} ->
            {:error, error}
        end
      end)
      |> Ecto.Multi.insert(:create_transaction, fn %{operation_changeset: operation_changeset} ->
        operation_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Update an Operation

  ## Parameters
    `id` - Id of Operation
    `operation_name` - String Name of a new Operation

  ## Examples

      iex> update(%{id: id, operation_name: operation_name})
      {:ok, %{update_operation: %Operation{}}}

      iex> create(%{id: id, operation_name: operation_name_already_exist})
      {:error, :operation_already_exists}
  """
  def update(%{id: id, operation_name: operation_name}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation_name, fn _, _ ->
        case Repo.get_by(Operation, operation_name: operation_name) do
          nil -> {:ok, :operation_name_do_not_exists}
          _operation -> {:error, :operation_name_already_exists}
        end
      end)
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case Repo.get_by(Operation, id: id) do
          nil -> {:error, :operation_not_exists}
          operation -> {:ok, operation}
        end
      end)
      |> Ecto.Multi.run(:create_operation_changeset, fn _, %{fetch_operation: fetch_operation} ->
        fetch_operation
        |> update_changest(%{operation_name: operation_name})
        |> case do
          nil -> {:error, :error_update_changeset}
          operation -> {:ok, operation}
        end
      end)
      |> Ecto.Multi.update(:update_operation, fn %{
                                                   create_operation_changeset:
                                                     create_operation_changeset
                                                 } ->
        create_operation_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Delete an Operation

  ## Parameters
    `id` - Id of Operation

  ## Examples

      iex> delete(%{id: id})
      {:ok, %{delete_operation: %Operation{}}}

      iex> create(%{id: invalid_id})
      {:error, :operation_not_exists}
  """
  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case Repo.get_by(Operation, id: id) do
          nil -> {:error, :operation_not_exists}
          operation -> {:ok, operation}
        end
      end)
      |> Ecto.Multi.delete(:delete_operation, fn %{fetch_operation: fetch_operation} ->
        fetch_operation
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp update_changest(operation, %{operation_name: _name_operation} = params) do
    operation
    |> Operation.update_changeset(params)
  end

  defp create_changest(params) do
    params
    |> Operation.changeset()
  end
end
