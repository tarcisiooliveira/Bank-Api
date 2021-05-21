defmodule BankApiWeb.Usuario.ControllerUsuarioTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.Usuario
  alias BankApi.Repo

  test "quando todos parametros estão ok, cria usuario no banco" do
    params = %{email: "tarcisio@ymail.com", name: "Tarcisio", password: "123456"}
    count_before = Repo.aggregate(Usuario, :count)
    response = Usuario.changeset(params) |> Repo.insert()
    count_after = Repo.aggregate(Usuario, :count)
    assert {:ok, %Usuario{name: "Tarcisio", email: "tarcisio@ymail.com"}} = response
    assert count_after > count_before
  end

  test "quando já existe usuario com aquele email, retorna erro" do
    %{email: "tarcisio@ymail.com", name: "Tarcisio", password: "123456"}
    |> Usuario.changeset()
    |> Repo.insert()

    {:error, %Ecto.Changeset{errors: saida}} =
      %{email: "tarcisio@ymail.com", name: "Tar", password: "123456"}
      |> Usuario.changeset()
      |> Repo.insert()

    assert [
             email:
               {"has already been taken",
                [constraint: :unique, constraint_name: "usuarios_email_index"]}
           ] = saida
  end
end
