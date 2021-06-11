defmodule BankApi.Handle.HandleAdmin do
  alias BankApi.Schemas.Admin
  alias BankApi.Repo

  @moduledoc """
  Modulo de manipulação de dados Operação através do Repo
  """
  def get(id) do
    case Repo.get_by(Admin, id: id) do
      nil -> {:error, "ID Inválido ou inexistente"}
      admin -> {:ok, admin}
    end
  end

  def create(params) do
    case Admin.changeset(params) |> Repo.insert() do
      {:error, changeset} -> {:error, changeset}
      {:ok, admin} -> {:ok, admin}
    end
  end

  def update(_id, _params) do
    # case Repo.get_by(Conta, id: id) do
    #   nil ->
    #     {:error, "ID Inválido ou inexistente"}

    #   conta ->
    #     Conta.update_changeset(conta, %{saldo_conta: saldo_conta})
    #     |> Repo.update()
    # end
    :ok
  end

  def delete(_id) do
    # case Repo.get_by(Conta, id: id) do
    #   nil -> {:error, "ID Inválido ou inexistente"}
    #   conta -> Repo.delete(conta)
    # end
  end
end
