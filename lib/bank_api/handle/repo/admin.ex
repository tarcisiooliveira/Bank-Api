defmodule BankApi.Handle.Repo.Admin do
  alias BankApi.Repo
  alias BankApi.Schemas.Admin

  def fetch_transacao(id) do
    Repo.get(Admin, id)
  end

  def delete(admin) do
    Repo.delete(admin)
  end
end
