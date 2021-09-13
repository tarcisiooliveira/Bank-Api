defmodule BankApi.UserTest do
  @moduledoc """
    Module test Admin
  """
  use BankApiWeb.ConnCase, async: false

  import BankApi.Factory

  alias BankApi.User.SignIn
  alias BankApi.Users.CreateUser

  describe "SIGN UP" do
    test "assert create an user" do
      params = %{
        name: "Tarcisio",
        email: "tarcisio@email.com",
        password: "123456",
        password_confirmation: "123456"
      }

      {:ok, %{insert_user: user, insert_account: account}} = CreateUser.create(params)
      assert "tarcisio@email.com" = user.email
      assert "123456" = user.password_confirmation
      assert 10_000 = account.balance_account
    end

    test "invalid email create an user" do
      params = %{
        name: "Tarcisio",
        email: "useruser.com",
        password: "123456",
        password_confirmation: "123456"
      }

      {:error, %Ecto.Changeset{errors: [email: {message, _}], valid?: false}} =
        CreateUser.create(params)

      assert "Email format invalid." = message
    end

    test "error, different password confirmation" do
      params = %{
        name: "Tarcisio",
        email: "user@user.com",
        password: "123456",
        password_confirmation: "1234561"
      }

      {:error, %Ecto.Changeset{errors: [password_confirmation: {message, _}]}} =
        CreateUser.create(params)

      assert "Passwords are different." = message
    end

    test "dont send password confirmation" do
      params = %{
        name: "Tarcisio",
        email: "user@user.com",
        password: "123456"
      }

      {:error, %Ecto.Changeset{errors: [password_confirmation: {message, _}]}} =
        CreateUser.create(params)

      assert "can't be blank" = message
    end

    test "dont send password confirmation and email" do
      params = %{
        name: "Tarcisio",
        password: "123456"
      }

      {:error,
       %Ecto.Changeset{
         errors: [
           email: {email, _},
           password_confirmation: {password_confirmation, _}
         ]
       }} = CreateUser.create(params)

      assert "can't be blank" = email
      assert "can't be blank" = password_confirmation
    end

    test "no one parameters" do
      params = %{}

      {:error,
       %Ecto.Changeset{
         errors: [
           email: {email, [validation: :required]},
           name: {name, [validation: :required]},
           password: {password, [validation: :required]},
           password_confirmation: {password_confirmation, [validation: :required]}
         ]
       }} = CreateUser.create(params)

      assert "can't be blank" = name
      assert "can't be blank" = email
      assert "can't be blank" = password
      assert "can't be blank" = password_confirmation
    end
  end

  describe "SIGN IN" do
    test "assert sign in" do
      user =
        insert(:user,
          email: "user@user.com",
          password: "123456",
          password_confirmation: "123456"
        )

      assert {:ok, _token} =
               SignIn.authenticate(%{
                 "email" => "user@user.com",
                 "password" => "123456"
               })
    end

    test "error invalid email sign in" do
      user =
        insert(:user,
          email: "user@user.com",
          password: "123456",
          password_confirmation: "123456"
        )

      assert {:error, :unauthorized} =
               SignIn.authenticate(%{
                 "email" => "error@user.com",
                 "password" => "123456"
               })
    end

    test "error invalid password sign in" do
      user =
        insert(:user,
          email: "user@user.com",
          password: "123456",
          password_confirmation: "123456"
        )

      assert {:error, :unauthorized} =
               SignIn.authenticate(%{
                 "email" => "user@user.com",
                 "password" => "1234562"
               })
    end
  end
end
