defmodule BankApiWeb.ControllerTransactionTest do
  use BankApiWeb.ConnCase, async: false
  use ExUnit.Case
  alias BankApi.Schemas.{Account, AccountType, User, Account, Operation, Transaction}
  alias BankApi.Repo
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    %AccountType{id: id_account_type} = insert(:account_type, account_type_name: "Poupança")

    %User{id: id_User1} = insert(:user)
    %User{id: id_User2} = insert(:user)
    %User{id: id_User3} = insert(:user)

    %Account{id: from_account_id} =
      insert(:account, user_id: id_User1, account_type_id: id_account_type)

    %Account{id: account_destino_id1} =
      insert(:account, user_id: id_User2, account_type_id: id_account_type)

    %Account{id: account_destino_id2} =
      insert(:account, user_id: id_User3, account_type_id: id_account_type)

    %Operation{id: operation_id} = insert(:operation)

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
    %Operation{id: id_operation} = insert(:operation, operation_name: "Payment")

    %Transaction{id: id} =
      insert(:transaction,
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

  test "assert get - Exibe os dados de um withdraw quando é informado parametros validos",
       state do
    %Operation{id: id_operation} = insert(:operation, operation_name: "Withdraw")

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
    %Operation{id: id_operation} = insert(:operation, operation_name: "Withdraw")

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

  test "assert ok insert transaction/4 - All parameters ok, create a transaction between two Acccounts",
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
             "mensagem" => "Transaction finished successfully"
           } == response
  end

  test "assert ok insert - Todos parametros estão ok, User faz um withdraw", state do
    %Operation{id: operation_id} = insert(:operation, operation_name: "Withdraw")

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
             "mensagem" => "Transaction finished successfully"
           } == response
  end

  describe "delete/1" do
    test "delete ok - remove withdraw transaction  recorded at database", state do
      %Operation{id: operation_id} = insert(:operation, operation_name: "Withdraw")

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
               "mensagem" => "Transaction deleted successfully."
             } == response

      total_mais_a_frente = Repo.aggregate(Transaction, :count)
      assert total_antes == total_mais_a_frente
    end

    test "delete error - try remove inexistent transaction", state do
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
