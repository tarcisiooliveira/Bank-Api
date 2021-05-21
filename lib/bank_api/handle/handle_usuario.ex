defmodule BankApi.Handle.HandleUsuario do
  alias BankApi.{Repo, Schemas.Usuario}

  def get(id) do
    case Repo.get_by(Usuario, [id: id, visivel: :true]) do
      nil -> {:error, "Invalid ID"}
      usuario -> {:ok, usuario}
    end
  end

  def create(%{"name" => _name, "email" => _email, "password" => _password} = params) do
    params
    |> Usuario.changeset()
    |> Repo.insert()
  end

  def delete(id) do
    case Repo.get_by(Usuario, [id: id, visivel: :true]) do
      nil -> {:error, "Invalid ID"}
      usuario -> Usuario.update_changeset(usuario, %{visivel: false}) |> Repo.update()
    end
  end
end
