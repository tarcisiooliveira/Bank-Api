defmodule BankApiWeb.AdminView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Admin

  def render("show.json", %{admin: %Admin{email: email}}) do
    %{
      mensagem: email
    }
  end

  def render("sing_in.json", _params) do
    %{mensagem: "mensagem"}
  end

  def render("create.json", %{
        admin: %Admin{email: email, password_hash: password_hash},
        token: token
      }) do
    %{
      mensagem: "Administrador Cadastrado",
      admin: %{email: email, password_hash: password_hash},
      token: token
    }
  end

  def render("update.json",
        admin: %Admin{
          email: "admin@admin.com"
        }
      ) do
    %{
      mensagem: "Admin Atualizada"
    }
  end

  def render("delete.json",
        admin: %Admin{
          email: "admin@admin.com"
        }
      ) do
    %{
      mensagem: "Admin removida"
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Resultado: "Admin inexistente.",
      Mensagem: "#{error}"
    }
  end

  def render(
        "error.json",
        %{error: error}
      ) do
    %{error: error}
  end
end
