defmodule BankApi.Handle.Repo.TipoConta do
  alias BankApi.Repo
  alias BankApi.Schemas.TipoConta

  def fetch_tipo_conta(id) do
    Repo.get(TipoConta, id)
  end

  def delete(tipo_conta) do
    Repo.delete(tipo_conta)
  end
end
