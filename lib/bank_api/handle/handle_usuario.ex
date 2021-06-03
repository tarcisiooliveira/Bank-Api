defmodule BankApi.Handle.HandleUsuario do
  alias BankApi.{Repo, Schemas.Usuario}

  @moduledoc """
  Modulo de manipulação de dados Usuario através do Repo
  """
  def get(id) do
    case Repo.get_by(Usuario, id: id, visivel: true) do
      nil -> {:error, "ID inválido"}
      usuario -> {:ok, usuario}
    end
  end

  def create(%{"nome" => _name, "email" => _email, "password" => _password} = params) do
    params
    |> Usuario.changeset()
    |> Repo.insert()
  end

  def delete(id) do
    case Repo.get_by(Usuario, id: id, visivel: true) do
      nil -> {:error, "ID inválido"}
      usuario -> Usuario.update_changeset(usuario, %{visivel: false}) |> Repo.update()
    end
  end

  def update(id, %{email: email}) do
    case Repo.get_by(Usuario, email: email, visivel: true) do
      %Usuario{} ->
        {:error, "Email já cadastrado."}

      _ ->
        case Repo.get_by(Usuario, id: id, visivel: true) do
          nil ->
            {:error, "ID inválido"}

          usuario ->
            Usuario.update_changeset(usuario, %{email: email, visivel: true})
            |> Repo.update()
        end
    end
  end

  def update(id, %{nome: nome}) do
    user = Repo.get_by(Usuario, id: id, visivel: true)

    case user do
      nil ->
        IO.puts("Error")
        {:error, "ID inválido"}

      usuario ->
        Usuario.update_changeset(usuario, %{nome: nome, visivel: true})
        |> Repo.update()
    end
  end
end
