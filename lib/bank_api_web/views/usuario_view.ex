defmodule BankApiWeb.UsuariosView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Usuario

  def render("show.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      mensagem: "Show",
      usuario: %{id: id, name: name, email: email}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("update.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      mensagem: "Usuário atualizado com sucesso!",
      usuario: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      mensagem: "Usuário criado com sucesso!",
      usuario: %{id: id, name: name, email: email}
    }
  end

  def render("create.json", %{
        error: %Ecto.Changeset{
          errors: [
            email: {_motivo, [constraint: :unique, constraint_name: "usuarios_email_index"]}
          ]
        }
      }) do
    %{
      mensagem: "Erro",
      email: "Email já cadastrado"
      # informacao: unique,
      # constrain: texto
    }
  end

  def render("delete.json", %{error: mensagem}), do: %{error: "#{mensagem}"}

  def render("delete.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      message: "Usuario Removido",
      # usuario:
      id: id,
      name: name,
      email: email
    }
  end

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
