defmodule BankApi.Handle.Repo.Conta do
  alias BankApi.Repo
  alias BankApi.Schemas.Conta

  def fetch_account(%{id: id}) do
    Repo.get_by(Conta, id: id)
  end
end
