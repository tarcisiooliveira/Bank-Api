defmodule BankApiWeb.SignView do
  use BankApiWeb, :view
  alias Ecto.Changeset

  def render("sign_in_admin.json", %{token: token}) do
    %{message: %{token: token}}
  end

  def render("sign_up.json", %{id: id, email: email}) do
    IO.inspect("@@@@@@@@")
    :timer.sleep(2000)
    %{
      message: "Admin created.",
      Admin: %{
        id: id,
        email: email
      }
    }
  end

  def render("sign_up_admin.json", %{
        error: %Changeset{errors: [email: {"Email already in use.", _}]}
      }) do
    %{
      message: "Admin error.",
      error: "Email already in use."
    }
  end

  def render("sign_up_admin.json", %{error: error}) do
    %{
      message: "Admin error.",
      error: error
    }
  end

  def render("sign_in_user.json", %{token: token}) do
    %{message: %{token: token}}
  end

  def render("sign_up_user.json", %{
        error: %Changeset{errors: [email: {"Email already in use.", _}]}
      }) do
    %{
      message: "User error.",
      error: "Email already in use."
    }
  end

  def render("sign_up_user.json", %{error: error}) do
    %{
      message: "User error.",
      error: error
    }
  end
end
