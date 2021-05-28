defmodule BankApi.Handle.HandleUsuario do
  alias BankApi.{Repo, Schemas.Usuario}

  def get(id) do
    case Repo.get_by(Usuario, id: id, visivel: true) do
      nil -> {:error, "ID invalido"}
      usuario -> {:ok, usuario}
    end
  end

  def create(%{"name" => _name, "email" => _email, "password" => _password} = params) do
    params
    |> Usuario.changeset()
    |> Repo.insert()
  end

  def delete(id) do
    case Repo.get_by(Usuario, id: id, visivel: true) do
      nil -> {:error, "ID invalido"}
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
            {:error, "ID invalido"}

          usuario ->
            Usuario.update_changeset(usuario, %{email: email, visivel: true})
            |> Repo.update()
        end
    end
  end

  def update(id, %{name: name}) do
    user = Repo.get_by(Usuario, id: id, visivel: true)
    # IO.inspect(user)

    case user do
      nil ->
        {:error, "ID invalido"}

      usuario ->
        Usuario.update_changeset(usuario, %{name: name, visivel: true})
        |> Repo.update()
    end
  end
end
