defmodule BankApi.Handle.Repo.User do
  alias BankApi.Repo
  alias BankApi.Schemas.User

  def fetch_user(%{id: id}) do
    Repo.get_by(User, id: id)
  end

  def fetch_user(%{email: email}) do
    Repo.get_by(User, email: email)
  end
end
