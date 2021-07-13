defmodule BankApi.Handle.HandleOperation do
  @moduledoc """
  Modulo de manipulação de dados Operação através do Repo
  """

  alias BankApi.Schemas.Operation
  alias BankApi.Repo
  alias BankApi.Multi.Operation, as: MultiOperation

  def get(%{id: id}) do
    case Repo.get_by(Operation, id: id) do
      nil -> {:error, "Invalid ID or inexistent."}
      operation -> {:ok, operation}
    end
  end

  def create(%{operation_name: _name_operation} = params) do
    MultiOperation.create(params)
  end

  def update(%{id: _id, operation_name: _name_operation} = params) do
    MultiOperation.update(params)
  end

  def delete(%{id: _id} = params) do
    MultiOperation.delete(params)
  end
end
