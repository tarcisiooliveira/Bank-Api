defmodule BankApiWeb.WelcomeController do
  use BankApiWeb, :controller

  def index(conn, _params) do
    text(conn, "Bem-Vindo a WebBank API JSON")
  end


end
