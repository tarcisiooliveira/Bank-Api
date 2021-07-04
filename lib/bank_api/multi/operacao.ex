defmodule BankApi.Multi.Operacao do
  alias BankApi.Schemas.{Operacao, Conta}
  alias BankApi.Repo
  # alias BankApi.Handle.Repo.Conta, as: HandleContaRepo
  alias BankApi.Handle.Repo.Operacao, as: HandleOperacaoRepo
  alias Ecto.Changeset

  def create(
        %{
          nome_operacao: _nome_operacao
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

          %Changeset{errors: [nome_operacao: {"can't be blank", _}]} ->
            {:error, :nome_operacao_necessario}
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

  def update(%{id: id, nome_operacao: nome_operacao}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_operation, fn _, _ ->
        case fetch_operation(%{id: id}) do
          nil -> {:error, :operation_not_exists}
          operation -> {:ok, operation}
        end
      end)
      |> Ecto.Multi.update(:update_operacao, fn %{fetch_operation: fetch_operation} ->
        Operacao.update_changeset(fetch_operation, %{nome_operacao: nome_operacao})
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
    HandleOperacaoRepo.fetch_operation(params)
  end

  defp create_changest(params) do
    params
    |> Operacao.changeset()
  end
end
