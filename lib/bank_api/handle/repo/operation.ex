defmodule BankApi.Handle.Repo.Operation do
  alias BankApi.Repo
  alias BankApi.Schemas.Operation

  def fetch_operation(%{id: id}) do
    Repo.get_by(Operation, id: id)
  end

  def fetch_operation(%{operation_name: operation_name}) do
    Repo.get_by(Operation, operation_name: operation_name)
  end

  def delete(operation) do
    Repo.delete(operation)
  end
end
