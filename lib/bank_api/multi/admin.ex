defmodule BankApi.Multi.Admin do
  alias BankApi.Schemas.Admin
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Admin, as: HandleRepoAdmin
  # alias BankApi.Handle.Repo.Operation, as: HandleOperationRepo
  alias Ecto.Changeset

  alias BankApi.Handle.Repo.Admin, as: HandleRepoAdmin

  def create(
        %{email: _email, password: _password, password_confirmation: _password_confirmation} =
          params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:changeset_valido, fn _, _ ->
        case Admin.changeset(params) do
          %Changeset{errors: [password_confirmation: {"Differents password.", _}]} ->
            {:error, :senhas_diferentes}

          %Changeset{errors: [email: {"Email already in use.", _}]} ->
            {:error, :email_ja_cadastrado}

          %Changeset{errors: [email: {"Invalid format email.", _}]} ->
            {:error, :email_formato_invalido}

          %Changeset{errors: [password: {"Password must accountin between 4 and 10 characters.", _}]} ->
            {:error, :password_entre_4_e_10_caracteres}

          %Changeset{errors: [password_confirmation: {"can't be blank", [validation: :required]}]} ->
            {:error, :confirmacao_senha_necessario}

          %Changeset{errors: [password_confirmation: _, password: _]} ->
            {:error, :senhas_diferentes}

          changeset ->
            {:ok, changeset}
        end
      end)
      |> Ecto.Multi.insert(:insert_admin, fn %{changeset_valido: changeset_valido} ->
        changeset_valido
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def delete(%{id: _id} = params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_admin, fn _, _ ->
        case fetch_admin(params) do
          nil -> {:error, :theres_no_admin}
          admin -> {:ok, admin}
        end
      end)
      |> Ecto.Multi.delete(:deleted_admin, fn %{fetch_admin: fetch_admin} ->
        fetch_admin
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def update(%{id: id, email: email}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:try_admin_by_email, fn _, _ ->
        case HandleRepoAdmin.fetch_admin(%{email: email}) do
          nil ->
            {:ok, "Email válido."}

          _ ->
            {:error, "Email already in use."}
        end
      end)
      |> Ecto.Multi.run(:fetch_admin_account, fn _, _ ->
        case HandleRepoAdmin.fetch_admin(%{id: id}) do
          nil ->
            {:error, "Invalid ID or inexistent."}

          admin ->
            {:ok, admin}
        end
      end)
      |> Ecto.Multi.update(:update_admin, fn %{fetch_admin_account: fetch_admin_account} ->
        fetch_admin_account
        |> Admin.update_changeset(%{email: email})
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp fetch_admin(params) do
    params
    |> HandleRepoAdmin.fetch_admin()
  end
end
