defmodule BankApi.Multi.User do
  alias BankApi.Schemas.User
  alias BankApi.Repo
  alias BankApi.Handle.Repo.User, as: HandleUserRepo
  alias Ecto.Changeset

  def create(
        %{
          email: _email,
          name: _name,
          password: _password,
          password_validation: _password_validation
        } = params
      ) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:create_user_changeset, fn _, _ ->
        case create_user(params) do
          %Changeset{valid?: true} = changeset ->
            {:ok, changeset}

          %Changeset{errors: [email: {error, _}]} ->
            {:error, error}
        end
      end)
      |> Ecto.Multi.insert(:insert_user, fn %{
                                              create_user_changeset: create_user_changeset
                                            } ->
        create_user_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def update(%{id: id, email: email}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_user_by_id, fn _, _ ->
        case fetch_user(%{id: id}) do
          nil -> {:error, :user_not_exists}
          user -> {:ok, user}
        end
      end)
      |> Ecto.Multi.run(:fetch_user_by_email, fn _, _ ->
        case fetch_user(%{email: email}) do
          nil -> {:ok, :theres_no_email}
          _ -> {:error, :email_already_exist}
        end
      end)
      |> Ecto.Multi.run(:user_changeset, fn _, %{fetch_user_by_id: fetch_user_by_id} ->
        fetch_user_by_id
        |> update_changeset(%{email: email})
        |> case do
          %Changeset{valid?: true} = changeset ->
            {:ok, changeset}

          _ ->
            {:error, "Error changeset"}
        end
      end)
      |> Ecto.Multi.update(:update_operation, fn %{user_changeset: user_changeset} ->
        user_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def update(%{id: id, name: name}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_user, fn _, _ ->
        case fetch_user(%{id: id}) do
          nil -> {:error, :user_not_exists}
          user -> {:ok, user}
        end
      end)
      |> Ecto.Multi.run(:user_changeset, fn _, %{fetch_user: fetch_user} ->
        {:ok,
         fetch_user
         |> update_changeset(%{name: name})}

        # |> case do
        #   %Changeset{valid?: true} = changeset ->
        #     IO.inspect(changeset)

        # end
      end)
      |> Ecto.Multi.update(:update_operation, fn %{user_changeset: user_changeset} ->
        user_changeset
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def delete(%{id: id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:fetch_user, fn _, _ ->
        case fetch_user(%{id: id}) do
          nil -> {:error, :user_not_found}
          user -> {:ok, user}
        end
      end)
      |> Ecto.Multi.delete(:delete_user, fn %{fetch_user: fetch_user} ->
        fetch_user
      end)

    case Repo.transaction(multi) do
      {:ok, params} -> {:ok, params}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp create_user(params) do
    params
    |> User.changeset()
  end

  defp fetch_user(%{id: _id} = params) do
    params
    |> HandleUserRepo.fetch_user()
  end

  defp fetch_user(%{email: _email} = params) do
    params
    |> HandleUserRepo.fetch_user()
  end

  defp update_changeset(user, params) do
    user
    |> User.update_changeset(params)
  end
end
