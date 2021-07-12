defmodule BankApi.Handle.HandleUser do
  alias BankApi.Handle.Repo.User, as: HandleUserRepo
  alias BankApi.Multi.User, as: MultiUser

  @moduledoc """
  Modulo de manipulação de dados User através do Repo
  """
  def get(%{id: _id} = params) do
    case HandleUserRepo.fetch_user(params) do
      nil -> {:error, "Invalid ID or inexistent."}
      user -> {:ok, user}
    end
  end

  def create(
        %{
          name: _name,
          email: _email,
          password: _password,
          password_validation: _password_validation
        } = params
      ) do
    params
    |> MultiUser.create()
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiUser.delete()
  end

  def update(%{id: _id, email: _email} = params) do
    params
    |> MultiUser.update()
  end

  def update(%{id: _id, name: _name} = params) do
    params
    |> MultiUser.update()
  end
end
