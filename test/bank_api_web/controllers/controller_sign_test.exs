defmodule BankApiWeb.ControllerSignTest do
  @moduledoc """
  Module test Sign In and Sign Up
  """

  use BankApiWeb.ConnCase, async: true

  import BankApi.Factory

  test "assert sig_up_admin test", %{conn: conn} do
    params = %{
      "email" => "admin@gmail.com",
      "password" => "123456",
      "password_validation" => "123456"
    }

    response =
      conn
      |> post(Routes.sign_path(conn, :sign_up_admin, params))
      |> json_response(:ok)

    assert %{
             "message" => "Admin created.",
             "Admin" => %{"email" => "admin@gmail.com", "id" => _9696}
           } = response
  end

  test "assert sig_in_admin test", %{conn: conn} do
    insert(:admin, email: "admin@gmail.com", password: "123456", password_validation: "123456")

    params = %{
      "email" => "admin@gmail.com",
      "password" => "123456"
    }

    response =
      conn
      |> post(Routes.sign_path(conn, :sign_in_admin, params))
      |> json_response(:ok)

    assert %{
             "message" => _token
           } = response
  end

  test "assert sig_in_user test", %{conn: conn} do
    insert(:user, email: "user@gmail.com", password: "123456")

    params = %{
      "email" => "user@gmail.com",
      "password" => "123456"
    }

    response =
      conn
      |> post(Routes.sign_path(conn, :sign_in_user, params))
      |> json_response(:ok)

    assert %{
             "message" => _token
           } = response
  end
end
