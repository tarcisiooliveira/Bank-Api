defmodule BankApiWeb.ReportView do
  use BankApiWeb, :view
  alias BankApi.Admins.Schemas.Admin

  def render("show.json", %{admin: %Admin{email: email}}) do
    %{
      message: email
    }
  end

  def render(
        "reports.json",
        params
      ) do
    %{
      result: %{transfer: params.result.transfer, withdraw: params.result.withdraw}
    }
  end

  def render(
        "show.json",
        params
      ) do
    %{
      result: params
    }
  end

  def render(
        "create.json",
        %{admin: %{insert_admin: %Admin{email: email, id: id}}}
      ) do
    %{
      admin: %{email: email, id: id}
    }
  end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
