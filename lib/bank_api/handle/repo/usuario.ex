defmodule BankApi.Handle.Repo.Usuario do
  alias BankApi.Repo
  alias BankApi.Schemas.Usuario

  def fetch_user(%{id: id}) do
    Repo.get_by(Usuario, id: id, visivel: true)
  end

  def fetch_user(%{email: email}) do
    Repo.get_by(Usuario, email: email, visivel: true)
  end

  def delete(usuario) do
    Repo.delete(usuario)
  end
end

# "error" => "ID inválido ou inexistente."
