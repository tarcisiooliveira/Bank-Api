defmodule BankApi.AdminTest do
  @moduledoc """
    Module test Admin
  """
  use BankApiWeb.ConnCase, async: false

  alias BankApi.Admins.SignUp
  alias BankApi.Admins.SignIn
  import BankApi.Factory

  describe "SIGN UP" do
    test "assert create and admin" do
      params = %{
        email: "admin@admin.com",
        password: "123456",
        password_confirmation: "123456"
      }

      {:ok, %{insert_admin: admin}} = SignUp.create(params)
      assert "admin@admin.com" = admin.email
      assert "123456" = admin.password_confirmation
    end

    test "invalid email create and admin" do
      params = %{
        email: "adminadmin.com",
        password: "123456",
        password_confirmation: "123456"
      }

      {:error, %Ecto.Changeset{errors: [email: {message, _}]}} = SignUp.create(params)
      assert "Email format invalid." = message
    end

    test "different password confirmation" do
      params = %{
        email: "admin@admin.com",
        password: "123456",
        password_confirmation: "1234561"
      }

      {:error, %Ecto.Changeset{errors: [password_confirmation: {message, _}]}} =
        SignUp.create(params)

      assert "Differents password." = message
    end

    test "dont send password confirmation" do
      params = %{
        email: "admin@admin.com",
        password: "123456"
      }

      {:error, %Ecto.Changeset{errors: [password_confirmation: {message, _}]}} =
        SignUp.create(params)

      assert "can't be blank" = message
    end

    test "dont send password confirmation and email" do
      params = %{
        password: "123456"
      }

      {:error,
       %Ecto.Changeset{
         errors: [
           email: {email, _},
           password_confirmation: {password_confirmation, _}
         ]
       }} = SignUp.create(params)

      assert "can't be blank" = email
      assert "can't be blank" = password_confirmation
    end

    test "no one parameters" do
      params = %{}

      {:error,
       %Ecto.Changeset{
         errors: [
           email: {email, _},
           password: {password, _},
           password_confirmation: {password_confirmation, _}
         ]
       }} = SignUp.create(params)

      assert "can't be blank" = email
      assert "can't be blank" = password
      assert "can't be blank" = password_confirmation
    end
  end

  describe "SIGN IN" do
    test "assert sign in" do
      insert(:admin,
        email: "admin@admin.com",
        password: "123456",
        password_confirmation: "123456"
      )

      assert {:ok, _token} =
               SignIn.authenticate(%{
                 "email" => "admin@admin.com",
                 "password" => "123456"
               })
    end

    test "error invalid email sign in" do
      insert(:admin,
        email: "admin@admin.com",
        password: "123456",
        password_confirmation: "123456"
      )

      {:error, message} =
        SignIn.authenticate(%{
          "email" => "unknow@admin.com",
          "password" => "123456"
        })

      assert message == :unauthorized
    end

    test "error valid email and wrong password sign in" do
      insert(:admin,
        email: "admin@admin.com",
        password: "123456",
        password_confirmation: "123456"
      )

      {:error, message} =
        SignIn.authenticate(%{
          "email" => "admin@admin.com",
          "password" => "1234567"
        })

      assert message == :unauthorized
    end
  end
end
