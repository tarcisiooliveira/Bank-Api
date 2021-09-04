defmodule BankApi.Users.GetUser do
  alias BankApi.Users.Schemas.User
  alias BankApi.Repo

  def get_by_id(id) do
    case Repo.get_by(User, id: id) |> Repo.preload(:accounts) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
