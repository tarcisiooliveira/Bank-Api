defmodule BankApiWeb.UserSignView do
  use BankApiWeb, :view

  def render(
        "sign_up.json",
        %{
          user_id: user_id,
          email: email,
          account_id: account_id,
          balance_account: balance_account
        } = _params
      ) do
    %{
      message: "User created sucessfuly!",
      user: %{email: email, user_id: user_id},
      account: %{account_id: account_id, balance_account: balance_account}
    }
  end

  def render("sign_in_user.json", %{token: token} = _params) do
    %{message: token}
  end

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
