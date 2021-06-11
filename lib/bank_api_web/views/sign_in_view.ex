defmodule BankApiWeb.SignInView do
  use BankApiWeb, :view


  def render("sign_in.json", %{token: token}) do
    # IO.inspect(params)
    %{mensagem: %{token: token}}
  end
end
