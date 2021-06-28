defmodule BankApi.Handle.Repo.Usuario do
  alias BankApi.Repo
  alias BankApi.Schemas.Usuario

  def fetch_usuario(id) do
    Repo.get(Usuario, id)
  end

  def delete(usuario) do
    Repo.delete(usuario)
  end
end
