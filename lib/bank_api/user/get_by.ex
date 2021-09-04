defmodule BankApi.Users.GetBy do
  alias BankApi.Users.Schemas.User
  alias BankApi.Repo
  alias BankApi.Users.Schemas.User
  alias BankApi.Users.CreateUser

  @spec get_by_id(any) ::
          {:error, :not_found} | {:ok, [%{optional(atom) => any}] | %{optional(atom) => any}}
  def get_by_id(id) do
    case Repo.get_by(User, id: id) |> Repo.preload(:accounts) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
