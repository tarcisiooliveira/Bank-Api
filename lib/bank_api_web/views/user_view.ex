defmodule BankApiWeb.UserView do
  use BankApiWeb, :view
  alias BankApi.Schemas.User

  def render("show.json", %{user: %User{id: id, name: name, email: email}}) do
    %{
      mensagem: "Show",
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
      mensagem: "Usuário atualizado com sucesso!",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        user: %{insert_user: %User{id: id, name: name, email: email}}
      }) do
    %{
      mensagem: "Usuário criado com sucesso!",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        user: %{update_operation: %User{id: id, name: name, email: email}}
      }) do
    %{
      mensagem: "Usuário criado com sucesso!",
      user: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        error: %Ecto.Changeset{errors: [email: {"has already been taken", _}]}
      }) do
    %{
      message: "Email já cadastrado."
    }
  end

  def render("delete.json", %{error: :user_not_found}), do: %{error: "User not found."}
  def render("delete.json", %{error: mensagem}), do: %{error: "#{mensagem}"}

  def render("delete.json", %{user: %{delete_user: %User{id: id, name: name, email: email}}}) do
    %{
      message: "User Removido",
      # User:
      id: id,
      name: name,
      email: email
    }
  end

  def render("error.json", %{error: :email_already_exist}), do: %{error: "Email já cadastrado."}

  def render("error.json", %{
        error: %Ecto.Changeset{errors: [email: {"has already been taken", _}]}
      }),
      do: %{error: "Email já cadastrado."}

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
