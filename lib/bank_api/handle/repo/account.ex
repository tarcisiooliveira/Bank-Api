defmodule BankApi.Handle.Repo.Account do
  @moduledoc """
    This Module is responsable to fetch Account informations on DataBase.
  """

  alias BankApi.Repo
  alias BankApi.Schemas.Account

  def fetch_account(%{id: id}) do
    Repo.get_by(Account, id: id)
  end
end
