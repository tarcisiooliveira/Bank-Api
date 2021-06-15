defmodule BankApi.Handle.HandleAdmin do
  alias BankApi.Schemas.Admin
  alias BankApi.Repo

  @moduledoc """
  Modulo de manipulação de dados Operação através do Repo
  """
  def get(id) do
    case Repo.get_by(Admin, id: id) do
      nil -> {:error, "ID Inválido ou inexistente"}
      admin -> {:ok, admin}
    end
  end

  def create(
        %{
          "email" => _email,
          "password" => _senha,
          "password_confirmation" => _password_confirmation
        } = params
      ) do
    params
    |> Admin.changeset()
    |> Repo.insert()
  end

  def create(
        %{
          "email" => _email,
          "password" => _senha
        } = _params
      ) do
    {:error, "Campo Confirmação de Senha não informado"}
  end

  def update(id, %{email: email}) do
    case Repo.get_by(Admin, email: email) do
      %Admin{} ->
        {:error, "Email já cadastrado."}

      _ ->
        case Repo.get_by(Admin, id: id) do
          nil ->
            {:error, "ID inválido"}

          admin ->
            Admin.update_changeset(admin, %{email: email})
            |> Repo.update()
        end
    end
  end

  def delete(id) do
    case Repo.get_by(Admin, id: id) do
      nil -> {:error, "ID Inválido ou inexistente"}
      admin -> Repo.delete(admin)
    end
  end
end
