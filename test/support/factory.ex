defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Users.Schemas.User
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Admins.Schemas.Admin

  def user_factory do
    %User{
      name: "Tarcisio",
      email: sequence(:email, &"#{&1}tarcisio@email.com", start_at: 1000),
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
      email: sequence(:email, &"#{&1}tarcisio@admin.com", start_at: 1000),
      password: "123456",
      password_confirmation: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def transfer_factory do
    %Transaction{
      from_account_id: 0,
      to_account_id: 0,
      value: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end

  def withdraw_factory do
    %Transaction{
      from_account_id: 0,
      value: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end
end
