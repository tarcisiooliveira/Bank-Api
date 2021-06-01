defmodule BankApiWeb.Usuario.SchemaUsuarioTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.Usuario

  # import Phoenix.View

  describe "changeset/1" do
    test "quando todos os parametros sao validos, retorna um changeset valido" do
      params = %{email: "tarcisio@ymail.com", nome: "Tarcisio", password: "123456"}
      response = Usuario.changeset(params)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{
                 email: "tarcisio@ymail.com",
                 nome: "Tarcisio",
                 password: "123456",
                 password_hash: _something
               },
               errors: [],
               data: %BankApi.Schemas.Usuario{},
               valid?: true
             } = response
    end

    test "passa email errado e retorna changeset invalido" do
      params = %{email: "tarcisioymail.com", nome: "Tarcisio", password: "123456"}
      response = Usuario.changeset(params)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{email: "tarcisioymail.com", nome: "Tarcisio", password: "123456"},
               errors: [email: {"has invalid format", [validation: :format]}],
               data: %BankApi.Schemas.Usuario{},
               valid?: false
             } = response
    end

    test "quando passa nome faltando, retorna changeset falso" do
      params = %{email: "tarcisio@ymail.com", password: "123456"}
      response = Usuario.changeset(params)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{email: "tarcisio@ymail.com", password: "123456"},
               errors: [nome: {"can't be blank", [validation: :required]}],
               data: %BankApi.Schemas.Usuario{},
               valid?: false
             } = response
    end

    test "quando passa senha faltando, retorna changeset falso" do
      params = %{email: "tarcisio@ymail.com", nome: "Tarcisio"}
      response = Usuario.changeset(params)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{email: "tarcisio@ymail.com", nome: "Tarcisio"},
               errors: [password: {"can't be blank", [validation: :required]}],
               data: %BankApi.Schemas.Usuario{},
               valid?: false
             } = response
    end
  end
end
