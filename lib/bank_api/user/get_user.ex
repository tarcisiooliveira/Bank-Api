defmodule BankApi.Users.GetUser do
  @moduledoc """
    GetUser
    Module use Repo and get users and account in database
  """
  alias BankApi.Repo
  alias BankApi.Users.Schemas.User

  def get_by_id(id) do
    case Repo.get_by(User, id: id) |> Repo.preload(:accounts) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
