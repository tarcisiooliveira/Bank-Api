defmodule BankApiWeb.AdminView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Admin
  alias Ecto.Changeset

  def render("show.json", %{admin: %Admin{email: email}}) do
    %{
      mensagem: email
    }
  end

  def render("sing_in.json", _params) do
    %{mensagem: "mensagem"}
  end

  def render(
        "create.json",
        %{
          admin: %{changeset_valido: %Changeset{changes: %{email: email}}}
        }
      ) do
    %{
      mensagem: "Admin recorded.",
      email: email
    }
  end

  def render("create.json", %{error: error}) do
    %{
      mensagem: "Admin not recorded.",
      error: error
    }
  end

  def render(
        "update.json",
        %{
          admin: %{
            update_admin: %Admin{
              email: email
            }
          }
        }
      ) do
    %{
      mensagem: "Admin updated.",
      email: email
    }
  end

  def render(
        "delete.json",
        %{
          admin: %{
            deleted_admin: %Admin{
              email: email
            }
          }
        }
      ) do
    %{
      mensagem: "Admin deleted.",
      email: email
    }
  end

  def render("delete.json", %{error: :theres_no_admin}) do
    %{
      Erro: "Admin not deleted.",
      Result: "Invalid ID or inexistent."
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Erro: "Admin not deleted.",
      Result: error
    }
  end

  def render(
        "error.json",
        %{error: :confirmacao_senha_necessario}
      ) do
    %{error: "Verify parameters."}
  end

  def render(
        "error.json",
        %{error: error} = _params
      ) do
    %{error: error}
  end
end
