defmodule BankApi.Multi.Operation do
  alias BankApi.Schemas.Operation
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Operation, as: HandleOperationRepo
  alias Ecto.Changeset

  @moduledoc """
    This Module valid manipulations of Operations and the persist in DataBase or RollBack if something is worng.
  """
  def create(
        %{
          operation_name: _name_operation
        } = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case fetch_operation(params) do
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

  def update(%{id: id, operation_name: operation_name}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case fetch_operation(%{id: id}) do
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

  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case fetch_operation(%{id: id}) do
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

  defp fetch_operation(params) do
    HandleOperationRepo.fetch_operation(params)
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
