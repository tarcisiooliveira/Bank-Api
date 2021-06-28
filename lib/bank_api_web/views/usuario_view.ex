defmodule BankApiWeb.UsuarioView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Usuario

  def render("show.json", %{usuario: %Usuario{id: id, nome: nome, email: email}}) do
    %{
      mensagem: "Show",
      usuario: %{id: id, nome: nome, email: email}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("update.json", %{usuario: %Usuario{id: id, nome: nome, email: email}}) do
    %{
      mensagem: "Usuário atualizado com sucesso!",
      usuario: %{id: id, nome: nome, email: email}
    }
  end

  def render("create.json", %{usuario: %Usuario{id: id, nome: nome, email: email}}) do
    %{
      mensagem: "Usuário criado com sucesso!",
      usuario: %{id: id, nome: nome, email: email}
    }
  end

  def render("create.json", params) do
    %{
      mensagem: "Erro",
      email: "Email já cadastrado"
    }
  end

  def render("delete.json", %{error: mensagem}), do: %{error: "#{mensagem}"}

  def render("delete.json", %{usuario: %Usuario{id: id, nome: nome, email: email}}) do
    %{
      message: "Usuario Removido",
      # usuario:
      id: id,
      nome: nome,
      email: email
    }
  end

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
