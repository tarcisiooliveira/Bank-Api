defmodule BankApi.Handle.Repo.AccountType do
  alias BankApi.Repo
  alias BankApi.Schemas.AccountType

  @moduledoc """
    This Module is responsable to fetch Account Type informations on DataBase.
  """
  def fetch_account_type(%{id: id}) do
    Repo.get_by(AccountType, id: id)
  end

  def fetch_account_type(%{account_type_name: account_type_name}) do
    Repo.get_by(AccountType, account_type_name: account_type_name)
  end

  def delete(account_type) do
    Repo.delete(account_type)
  end
end
