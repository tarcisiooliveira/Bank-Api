defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Admins.Schemas.Admin
  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Users.Schemas.User

  def user_factory do
    %User{
      name: "Tarcisio",
      email: sequence(:email, &"tarcisio#{&1}@email.com", start_at: 1000),
      password: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def account_factory do
    %Account{
      balance_account: 10_000,
      user_id: 0
    }
  end

  def admin_factory do
    %Admin{
      email: sequence(:email, &"tarcisio#{&1}@admin.com", start_at: 1000),
      password: "123456",
      password_confirmation: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def transfer_factory do
    %Transaction{
      from_account_id: Ecto.UUID.autogenerate(),
      to_account_id: Ecto.UUID.autogenerate(),
      value: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end

  def withdraw_factory do
    %Transaction{
      from_account_id: Ecto.UUID.autogenerate(),
      value: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end
end
