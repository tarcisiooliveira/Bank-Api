defmodule BankApi.Handle.HandleConta do
  alias BankApi.Schemas.Conta
  alias BankApi.Repo

  @moduledoc """
  Modulo de manipulação de dados Operação através do Repo
  """
  def get(id) do
    case Repo.get_by(Conta, id: id) do
      nil -> {:error, "ID Inválido ou inexistente"}
      conta -> {:ok, conta}
    end
  end

  def create(params) do
    case Conta.changeset(params) |> Repo.insert() do
      {:error, changeset} -> {:error, changeset}
      {:ok, conta} -> {:ok, conta}
    end
  end

  def update(id, %{saldo_conta: saldo_conta} = _params) do
    case Repo.get_by(Conta, id: id) do
      nil ->
        {:error, "ID Inválido ou inexistente"}

      conta ->
        Conta.update_changeset(conta, %{saldo_conta: saldo_conta})
        |> Repo.update()
    end
  end

  def delete(id) do
    case Repo.get_by(Conta, id: id) do
      nil -> {:error, "ID Inválido ou inexistente"}
      conta -> Repo.delete(conta)
    end
  end
end
