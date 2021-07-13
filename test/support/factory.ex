defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Schemas.{User, AccountType, Operation, Account, Transaction, Admin}

  def user_factory do
    %User{
      name: "Tarcisio",
      email: sequence(:email, &"tarcisio#{&1}@gmail.com", start_at: 1000),
      password: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def admin_factory do
    %Admin{
      email: "tarcisio@admin.com",
      password: "123456",
      password_validation: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def operation_factory do
    %Operation{
      operation_name: "Transfer"
    }
  end

  def account_factory do
    %Account{
      balance_account: 100_000,
      user_id: 0,
      account_type_id: 0
    }
  end

  def account_type_factory do
    %AccountType{
      account_type_name: "Savings Account"
    }
  end

  def transaction_factory do
    %Transaction{
      from_account_id: 0,
      to_account_id: 0,
      operation_id: 0,
      value: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end

  def withdraw_transaction_factory do
    %Transaction{
      from_account_id: 0,
      operation_id: 0,
      value: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end

  def transaction_payment_factory do
    %Transaction{
      from_account_id: 0,
      operation_id: 0,
      value: 0,
      inserted_at: DateTime.utc_now()
    }
  end
end
