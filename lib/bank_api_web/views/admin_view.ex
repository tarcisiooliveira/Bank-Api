defmodule BankApiWeb.AdminView do
  use BankApiWeb, :view
  alias BankApi.Admins.Schemas.Admin

  def render("show.json", %{admin: %Admin{email: email}}) do
    %{
      message: email
    }
  end

  def render("sign_in.json", %{token: token}) do
    %{token: token}
  end

  def render("sign_up.json", %{id: id, email: email}) do
    %{admin: %{id: id, email: email}}
  end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
