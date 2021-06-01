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

alias BankApi.Schemas.{Usuario, Conta, TipoConta, Operacao}
alias BankApi.Repo

usuario = [
  %{email: "tarcisio@ymail.com", nome: "Tarcisio", password: "123456"},
  %{email: "cida@ymail.com", nome: "Cida", password: "234567"},
  %{email: "benicio@ymail.com", nome: "Benicio", password: "345678"}
]

Enum.each(usuario, fn pessoa -> Usuario.changeset(pessoa) |> Repo.insert() end)

tipoConta = [
  %{nome_tipo_conta: "Corrente"},
  %{nome_tipo_conta: "Poupança"},
  %{nome_tipo_conta: "Digital"}
]


Enum.each(tipoConta, fn tipo -> TipoConta.changeset(tipo) |> Repo.insert() end)

operacao = [
  %{nome_operacao: "Saque"},
  %{nome_operacao: "Depósito"},
  %{nome_operacao: "Transferência"},
  %{nome_operacao: "Investimento"}
]


Enum.each(operacao, fn unit_operacao -> Operacao.changeset(unit_operacao) |> Repo.insert() end)

contas = [
  %{usuario_id: 1, tipo_conta_id: 1},
  %{usuario_id: 2, tipo_conta_id: 1},
  %{usuario_id: 3, tipo_conta_id: 2},
  %{usuario_id: 1, tipo_conta_id: 3}
]

Enum.each(contas, fn unit_contas -> Conta.changeset(unit_contas) |> Repo.insert() end)
