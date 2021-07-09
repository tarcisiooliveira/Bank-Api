defmodule BankApiWeb.ControllerTransacaoTest do
  use BankApiWeb.ConnCase, async: false
  use ExUnit.Case
  alias BankApi.Schemas.{Account, TipoAccount, User, Account, Operation, Transaction}
  alias BankApi.Repo
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    %TipoAccount{id: id_account_type} = insert(:account_type, account_type_name: "Poupança")

    %User{id: id_User1} = insert(:User)
    %User{id: id_User2} = insert(:User)
    %User{id: id_User3} = insert(:User)

    %Account{id: from_account_id} =
      insert(:Account, user_id: id_User1, account_type_id: id_account_type)

    %Account{id: account_destino_id1} =
      insert(:Account, user_id: id_User2, account_type_id: id_account_type)

    %Account{id: account_destino_id2} =
      insert(:Account, user_id: id_User3, account_type_id: id_account_type)

    %Operation{id: operation_id} = insert(:Operation)

    {:ok,
     valores: %{
       from_account_id: from_account_id,
       to_account_id: account_destino_id1,
       account_destino_id2: account_destino_id2,
       operation_id: operation_id,
       token: token
     }}
  end

  test "assert get - Exibe os dados de payments.", state do
    %Operation{id: id_operation} = insert(:Operation, operation_name: "Payment")

    %Transaction{id: id} =
      insert(:Transaction,
        from_account_id: state[:valores].from_account_id,
        to_account_id: state[:valores].to_account_id,
        operation_id: id_operation,
        value: 650
      )

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.transaction_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Transaction founded",
             "Transaction" => %{
               "from_account_id" => state[:valores].from_account_id,
               "to_account_id" => state[:valores].to_account_id,
               "operation_id" => id_operation,
               "value" => 650
             }
           } == response
  end

  test "assert get - Exibe os dados de um saque quando é informado parametros validos", state do
    %Operation{id: id_operation} = insert(:Operation, operation_name: "Withdraw")

    %Transaction{id: id} =
      insert(:withdraw_transaction,
        from_account_id: state[:valores].from_account_id,
        operation_id: id_operation,
        value: 700
      )

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.transaction_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Transaction founded",
             "Transaction" => %{
               "from_account_id" => state[:valores].from_account_id,
               "operation_id" => id_operation,
               "value" => 700
             }
           } == response
  end

  test "assert get - Retorna os dados de uma Transaction quando passado ID valido",
       state do
    %Operation{id: id_operation} = insert(:Operation, operation_name: "Withdraw")

    params = %{
      "from_account_id" => state[:valores].from_account_id,
      "operation_id" => id_operation,
      "value" => 900
    }

    {:ok, %Transaction{id: id}} =
      params
      |> Transaction.changeset()
      |> BankApi.Repo.insert()

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> get(Routes.transaction_path(state[:conn], :show, id))
      |> json_response(:ok)

    assert %{
             "mensagem" => "Transaction founded",
             "Transaction" => %{
               "from_account_id" => state[:valores].from_account_id,
               "operation_id" => id_operation,
               "value" => 900
             }
           } == response
  end

  test "assert ok insert/4 - Todos parametros estão ok, cria Transaction entre duas accounts",
       state do
    params = %{
      "from_account_id" => state[:valores].from_account_id,
      "to_account_id" => state[:valores].to_account_id,
      "operation_id" => state[:valores].operation_id,
      "value" => 600
    }

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.transaction_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Transaction" => %{
               "from_account_id" => state[:valores].from_account_id,
               "to_account_id" => state[:valores].to_account_id,
               "operation_id" => state[:valores].operation_id,
               "value" => 600
             },
             "mensagem" => "Transação Realizada com Sucesso"
           } == response
  end

  test "assert ok insert - Todos parametros estão ok, User faz um saque", state do
    %Operation{id: operation_id} = insert(:Operation, operation_name: "Withdraw")

    params = %{
      "from_account_id" => state[:valores].from_account_id,
      "operation_id" => operation_id,
      "value" => 1000
    }

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:valores].token)
      |> post(Routes.transaction_path(state[:conn], :create, params))
      |> json_response(:created)

    assert %{
             "Transaction" => %{
               "from_account_id" => state[:valores].from_account_id,
               "operation_id" => operation_id,
               "value" => 1000
             },
             "mensagem" => "Transação Realizada com Sucesso"
           } == response
  end

  describe "delete/1" do
    test "delete ok - remove  transação de saque cadastrada na base de dados", state do
      %Operation{id: operation_id} = insert(:Operation, operation_name: "Withdraw")

      params = %{
        "from_account_id" => state[:valores].from_account_id,
        "operation_id" => operation_id,
        "value" => 1000
      }

      total_antes = Repo.aggregate(Transaction, :count)

      {:ok, parametros} =
        params
        |> Transaction.changeset()
        |> BankApi.Repo.insert()

      total_depois = Repo.aggregate(Transaction, :count)
      assert total_antes < total_depois

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.transaction_path(state[:conn], :delete, parametros.id))
        |> json_response(:ok)

      assert %{
               "Transaction" => %{
                 "from_account_id" => state[:valores].from_account_id,
                 "operation_id" => operation_id,
                 "value" => 1000
               },
               "mensagem" => "Transação Removida com Sucesso"
             } == response

      total_mais_a_frente = Repo.aggregate(Transaction, :count)
      assert total_antes == total_mais_a_frente
    end

    test "delete error - tenta remover transação inexistente", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.transaction_path(state[:conn], :delete, 987_654_321))
        |> json_response(:not_found)

      assert %{
               "error" => "Invalid ID or inexistent."
             } = response
    end
  end
end
