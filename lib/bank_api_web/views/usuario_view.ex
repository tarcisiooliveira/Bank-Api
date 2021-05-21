defmodule BankApiWeb.UsuariosView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Usuario

  def render("show.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      usuario: %{id: id, name: name, email: email}
    }
  end

  def render("show.json", %{error: error}) do
    %{
      error: error
    }
  end

  def render("create.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      usuario: %{id: id, name: name, email: email}
    }
  end

  def render("delete.json", %{error: mensagem}), do: %{error: "#{mensagem}"}

  def render("delete.json", %{usuario: %Usuario{id: id, name: name, email: email}}) do
    %{
      message: "Usuario Removido",
      usuario: %{
        id: id,
        name: name,
        email: email
      }
    }
  end

  def render("error.json", %{error: error}), do: %{error: "#{error}"}
end
