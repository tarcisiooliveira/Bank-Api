defmodule BankApi.Handle.HandleAdmin do
  alias BankApi.Multi.Admin, as: MultiAdmin
  alias BankApi.Handle.Repo.Admin, as: HandleRepoAdmin

  @moduledoc """
  Modulo de manipulação de dados Admin
  """
  def get(id) do
    case HandleRepoAdmin.fetch_admin(%{id: id}) do
      nil -> {:error, "ID Inválido ou inexistente"}
      admin -> {:ok, admin}
    end
  end

  def create(params) do
    params
    |> MultiAdmin.create()
  end

  def update(id, %{email: email}) do
    MultiAdmin.update(%{id: id, email: email})
  end

  def delete(id) do
    case HandleRepoAdmin.fetch_admin(%{id: id}) do
      nil -> {:error, "ID Inválido ou inexistente"}
      admin -> HandleRepoAdmin.delete(admin)
    end
  end
end
