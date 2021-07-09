defmodule BankApi.Handle.Repo.TipoAccount do
  alias BankApi.Repo
  alias BankApi.Schemas.AccountType

  def fetch_account_type(%{id: id}) do
    Repo.get_by(TipoAccount, id: id)
  end

  def fetch_account_type(%{account_type_name: account_type_name}) do
    Repo.get_by(TipoAccount, account_type_name: account_type_name)
  end

  def delete(account_type) do
    Repo.delete(account_type)
  end
end
