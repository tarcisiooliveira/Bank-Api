defmodule BankApi.Handle.Repo.Transacao do
  alias BankApi.Repo
  alias BankApi.Schemas.Transacao

  def fetch_transacao(id) do
    Repo.get(Transacao, id)
  end

  def delete(transacao) do
    Repo.delete(transacao)
  end
end
