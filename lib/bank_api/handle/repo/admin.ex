defmodule BankApi.Handle.Repo.Admin do
  alias BankApi.Repo
  alias BankApi.Schemas.Admin

  def fetch_admin(id) do
    Repo.get(Admin, id)
  end

  def fetch_admin_by(%{id: id}) do
    Repo.get_by(Admin, id: id)
  end

  def fetch_admin_by(%{email: email}) do
    Repo.get_by(Admin, email: email)
  end
end
