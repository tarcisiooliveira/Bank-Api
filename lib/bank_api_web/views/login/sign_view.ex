defmodule BankApiWeb.SignView do
  use BankApiWeb, :view

  def render("sign_in.json", %{token: token}) do
    %{message: %{token: token}}
  end
  def render("sign_up.json", %{token: token}) do
    %{message: %{token: token}}
  end
end
