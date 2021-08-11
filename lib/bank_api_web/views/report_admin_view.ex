defmodule BankApiWeb.ReportView do
  use BankApiWeb, :view
  alias BankApi.Admins.Schemas.Admin

  def render("show.json", %{admin: %Admin{email: email}}) do
    %{
      message: email
    }
  end

  def render("sing_in.json", _params) do
    %{message: "message"}
  end

  def render("sing_up.json", params) do
    %{message: params}
  end

  def render(
        "create.json",
        %{admin: %{insert_admin: %Admin{email: email, id: id}}}
      ) do
    %{
      message: "Admin Created.",
      admin: %{email: email, id: id}
    }
  end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
