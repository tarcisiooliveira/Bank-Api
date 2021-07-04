defmodule BankApi.Handle.Repo.TipoConta do
  alias BankApi.Repo
  alias BankApi.Schemas.TipoConta

  def fetch_account_type(%{id: id}) do
    Repo.get_by(TipoConta, id: id)
  end

  def delete(account_type) do
    Repo.delete(account_type)
  end
end
