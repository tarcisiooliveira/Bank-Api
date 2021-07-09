defmodule BankApi.Handle.Repo.Account do
  alias BankApi.Repo
  alias BankApi.Schemas.Account

  def fetch_account(%{id: id}) do
    Repo.get_by(Account, id: id)
  end
end
