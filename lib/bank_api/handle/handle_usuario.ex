defmodule BankApi.Handle.HandleUsuario do
  alias BankApi.{Repo, Schemas.Usuario}
  alias BankApi.Handle.Repo.Usuario, as: HandleUsuarioRepo

  @moduledoc """
  Modulo de manipulação de dados Usuario através do Repo
  """
  def get(id) do
    case HandleUsuarioRepo.fetch_user(%{id: id, visivel: true}) do
      nil -> {:error, "ID Inválido ou inexistente."}
      usuario -> {:ok, usuario}
    end
  end

  def create(%{nome: _nome, email: _email, password: _password} = params) do
    params
    |> Usuario.changeset()
    |> Repo.insert()
  end

  def delete(id) do
    case HandleUsuarioRepo.fetch_user(%{id: id, visivel: true}) do
      nil -> {:error, "ID Inválido ou inexistente."}
      usuario -> Usuario.update_changeset(usuario, %{visivel: false}) |> Repo.update()
    end
  end

  def update(id, %{email: email}) do
    case HandleUsuarioRepo.fetch_user(%{email: email, visivel: true}) do
      %Usuario{} ->
        {:error, "Email já cadastrado."}

      _ ->
        case HandleUsuarioRepo.fetch_user(%{id: id, visivel: true}) do
          nil ->
            {:error, "ID Inválido ou inexistente."}

          usuario ->
            Usuario.update_changeset(usuario, %{email: email, visivel: true})
            |> Repo.update()
        end
    end
  end

  def update(id, %{nome: nome}) do
    user = HandleUsuarioRepo.fetch_user(%{id: id, visivel: true})

    case user do
      nil ->
        {:error, "ID Inválido ou inexistente."}

      usuario ->
        Usuario.update_changeset(usuario, %{nome: nome, visivel: true})
        |> Repo.update()
    end
  end
end
