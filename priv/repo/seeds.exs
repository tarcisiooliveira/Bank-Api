# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BankApi.Repo.insert!(%BankApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# params = %{
#   "email" => "tarcisio@admin.com",
#   "password" => "123456",
#   "password_confirmation" => "123456"
# }

# params
# |> Admin.changeset()
# |> Repo.insert()

# User = [
#   %{email: "tarcisio@ymail.com", name: "Tarcisio", password: "123456"},
#   %{email: "cida@ymail.com", name: "Cida", password: "234567"},
#   %{email: "benicio@ymail.com", name: "Benicio", password: "345678"}
# ]

# Enum.each(User, fn pessoa -> User.changeset(pessoa) |> Repo.insert() end)

# tipoAccount = [
#   %{account_type_name: "Corrente"},
#   %{account_type_name: "Poupança"},
#   %{account_type_name: "Digital"}
# ]

# Enum.each(tipoAccount, fn tipo -> TipoAccount.changeset(tipo) |> Repo.insert() end)

# Operation = [
#   %{operation_name: "Withdraw"},
#   %{operation_name: "Depósito"},
#   %{operation_name: "Transfer"},
#   %{operation_name: "Investimento"}
# ]

# Enum.each(Operation, fn unit_operation -> Operation.changeset(unit_operation) |> Repo.insert() end)

# accounts = [
#   %{user_id: 1, account_type_id: 1},
#   %{user_id: 2, account_type_id: 1},
#   %{user_id: 3, account_type_id: 2},
#   %{user_id: 1, account_type_id: 3}
# ]

# Enum.each(accounts, fn unit_accounts -> Account.changeset(unit_accounts) |> Repo.insert() end)

# Transaction = [
#   %{from_account_id: 1, to_account_id: 2, operation_id: 3, value: 60_000},
#   %{from_account_id: 2, to_account_id: 3, operation_id: 3, value: 70_000},
#   %{from_account_id: 3, operation_id: 1, value: 10_000},
#   %{from_account_id: 1, operation_id: 1, value: 50_000}
# ]

# Enum.each(Transaction, fn unit_transacao -> Transaction.changeset(unit_transacao) |> Repo.insert() end)
