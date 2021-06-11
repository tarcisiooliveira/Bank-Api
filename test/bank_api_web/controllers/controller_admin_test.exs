defmodule BankApi.ControllerAdminTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{Admin}
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Modulo de teste do Controlador de Admin
  """

  describe "create" do
    test "Test criacao admin com token", %{conn: conn} do
      # params1 = %{"email" => "admin1@admin.com",
      # "password" => "123456",
      # "password_confirmation" => "123456"}
      params2 = %{"email" => "admin2@admin.com",
      "password" => "123456",
      "password_confirmation" => "123456"}

      # {:ok, admin}=Admin.changeset(params1)
      # |> BankApi.Repo.insert()
      # |> IO.inspect()
      # IO.inspect("============================")
      # Guardian.encode_and_sign(admin)
      # |> IO.inspect()


      response =
        conn
        |> post(Routes.admin_path(conn, :create, params2))
        |> json_response(:created)

        assert %{
          "admin" => %{"email" => "admin2@admin.com", "password_hash" => _password_hash},
          "mensagem" => "Administrador Cadastrado",
          "token" => _token
        } = response
    end

  end
end
