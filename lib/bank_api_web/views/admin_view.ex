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

  def render(
        "create.json",
        %{
          conn: %Plug.Conn{params: %{"email" => email}},
          admin: %{changeset_valido: :paramentros_validos}
        }
      ) do
    %{
      mensagem: "Administrador Cadastrado",
      email: email
    }
  end

  def render("create.json", %{error: error}) do
    %{
      mensagem: "Administrador Não Cadastrado",
      error: error
    }
  end

  def render(
        "update.json",
        %{
          admin: %Admin{
            email: email
          }
        }
      ) do
    %{
      mensagem: "Admininstrador Atualizado",
      email: email
    }
  end

  def render(
        "delete.json",
        %{
          admin: %Admin{
            email: email
          }
        }
      ) do
    %{
      mensagem: "Administrador removido",
      email: email
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Erro: "Administrador não removido.",
      Resultado: error
    }
  end

  def render(
        "error.json",
        %{error: :confirmacao_senha_necessario}
      ) do
    %{error: "Verifique os parametros."}
  end

  def render(
        "error.json",
        %{error: error} = _params
      ) do
    %{error: error}
  end
end
