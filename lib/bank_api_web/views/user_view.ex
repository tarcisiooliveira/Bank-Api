defmodule BankApiWeb.UserView do
  use BankApiWeb, :view
  alias BankApi.Schemas.User

  def render("show.json", %{user: %User{id: id, name: name, email: email}}) do
    %{
      message: "Show",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("update.json", %{
        user: %{update_operation: %User{id: id, name: name, email: email}}
      }) do
    %{
      message: "User updated successfuly!",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        user: %{insert_user: %User{id: id, name: name, email: email}}
      }) do
    %{
      message: "User created sucessfuly!",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        user: %{update_operation: %User{id: id, name: name, email: email}}
      }) do
    %{
      message: "User created sucessfuly!",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        error: %Ecto.Changeset{errors: [email: {"has already been taken", _}]}
      }) do
    %{
      message: "Email already in use."
    }
  end

  def render("delete.json", %{error: :user_not_found}), do: %{error: "User not found."}
  def render("delete.json", %{error: message}), do: %{error: "#{message}"}

  def render("delete.json", %{user: %{delete_user: %User{id: id, name: name, email: email}}}) do
    %{
      message: "User deleted",
      # User:
      id: id,
      name: name,
      email: email
    }
  end

  def render("error.json", %{error: :email_already_exist}), do: %{error: "Email already in use."}

  def render("error.json", %{
        error: %Ecto.Changeset{errors: [email: {"has already been taken", _}]}
      }),
      do: %{error: "Email already in use."}

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
