defmodule BankApi.Handle.HandleAdmin do
  @moduledoc """
  Modulo de manipulação de dados Admin
  """

  alias BankApi.Multi.Admin, as: MultiAdmin
  alias BankApi.Handle.Repo.Admin, as: HandleRepoAdmin

  def get(id) do
    id
    |> String.to_integer()
    |> HandleRepoAdmin.fetch_admin()
    |> case do
      nil -> {:error, "Invalid ID or inexistent."}
      admin -> {:ok, admin}
    end
  end

  def create(params) do
    params
    |> MultiAdmin.create()
  end

  def update(%{id: _id, email: _email} = params) do
    params
    |> MultiAdmin.update()
  end

  def delete(%{id: _id} = params) do
    MultiAdmin.delete(params)
  end
end
