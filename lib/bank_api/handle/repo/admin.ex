defmodule BankApi.Handle.Repo.Admin do
  alias BankApi.Repo
  alias BankApi.Schemas.Admin

  def fetch_admin(%{id: id}) do
    Repo.get_by(Admin, id: id)
  end

  def fetch_admin_email(%{email: email}) do
    Repo.get_by(Admin, email: email)
  end

  def delete(admin) do
    Repo.delete(admin)
  end

  # def update(admin, %{id: id}) do
  #   Admin.update_changeset(admin, params)
  #   |> Repo.update()
  # end
  def update(admin, params) do
    Admin.update_changeset(admin, params)
  end
end
