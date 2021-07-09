defmodule BankApiWeb.ControllerAccountTest do
  use BankApiWeb.ConnCase, async: true
  alias BankApi.Schemas.{User, TipoAccount, Account}
  import BankApi.Factory
  alias BankApiWeb.Auth.Guardian

  @moduledoc """
  Modulo de teste do Controlador de Account
  """

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    {:ok,
     valores: %{
       token: token
     }}
  end

  describe "SHOW" do
    test "assert get - Exibe os dados de uma Account quando informado ID correto + token", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)
      %Account{id: account_id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.account_path(state[:conn], :show, account_id))
        |> json_response(:ok)

      assert %{
               "Account" => %{
                 "balance_account" => 100_000,
                 "account_type_id" => ^account_type_id,
                 "user_id" => ^user_id
               },
               "mensagem" => "Tipo Account encotrado."
             } = response
    end

    test "error show - exibe mensagem de erro quando não tem token de acesso", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)
      %Account{id: account_id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> get(Routes.account_path(state[:conn], :show, account_id))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end

    test "error get - Exibe os dados de uma Account quando informado ID errado", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> get(Routes.account_path(state[:conn], :show, 951_951))
        |> json_response(:not_found)

      assert %{"error" => "Invalid ID or inexistent."} = response
    end
  end

  describe "CREATE" do
    test "insert Account - Cadastra Account quando todos parametros estão OK", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      params = %{
        "balance_account" => 100_000,
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.account_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "Account" => %{
                 "balance_account" => 100_000,
                 "account_type_id" => _83,
                 "user_id" => _147
               },
               "mensagem" => "Account Cadastrada."
             } = response
    end

    test "assert ok insert Account - Cadastra Account faltando balance, default 100_000", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      params = %{
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.account_path(state[:conn], :create, params))
        |> json_response(:created)

      assert %{
               "Account" => %{
                 "balance_account" => 100_000,
                 "account_type_id" => _83,
                 "user_id" => _147
               },
               "mensagem" => "Account Cadastrada."
             } = response
    end

    test "erro insert Account - Exibe mensagem de erro quando passa balance negativo.", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      params = %{
        "balance_account" => -10_000,
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> post(Routes.account_path(state[:conn], :create, params))
        |> json_response(404)

      assert %{"error" => "Saldo inválido, ele deve ser maior ou igual a zero."} = response
    end

    test "erro insert Account - tenta inserir User sem token de acesso.", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      params = %{
        "balance_account" => -10_000,
        "user_id" => user_id,
        "account_type_id" => account_type_id
      }

      response =
        state[:conn]
        |> post(Routes.account_path(state[:conn], :create, params))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end

  describe "UPDATE" do
    test "assert update - atualiza balance para value válido maior que zero.", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => 5_000}))
        |> json_response(:created)

      assert %{
               "mensagem" => "Account Atualizada.",
               "Account" => %{"account_ID" => _id_User, "balance_account" => 5000}
             } = response
    end

    test "assert update - atualiza balance para value válido igual a zero.", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => 0}))
        |> json_response(:created)

      assert %{
               "mensagem" => "Account Atualizada.",
               "Account" => %{"account_ID" => _id_User, "balance_account" => 0}
             } = response
    end

    test "error update - tenta atualizar balance para value menor que zero", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => -1}))
        |> json_response(404)

      assert %{"error" => "Saldo inválido, ele deve ser maior ou igual a zero."} = response
    end

    test "error update - Tenta atualizar balance sem token de acesso", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> patch(Routes.account_path(state[:conn], :update, id, %{"balance_account" => -1}))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end

  describe "DELETE" do
    test "assert delete - Deleta Account quando ID é passado corretamente", state do
      %User{id: user_id} = insert(:User)
      %TipoAccount{id: account_type_id} = insert(:account_type)

      %Account{id: id} = insert(:Account, user_id: user_id, account_type_id: account_type_id)

      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.account_path(state[:conn], :delete, id))
        |> json_response(:ok)

      assert %{
               "Account" => %{"ID_User" => ^user_id, "account_type" => ^account_type_id},
               "mensagem" => "Account removida."
             } = response
    end

    test "error delete - Tenta deletar Account com id inexistente", state do
      response =
        state[:conn]
        |> put_req_header("authorization", "Bearer " <> state[:valores].token)
        |> delete(Routes.account_path(state[:conn], :delete, 951_951_951))
        |> json_response(:not_found)

      assert %{"error" => "Invalid ID or inexistent."} = response
    end

    test "error delete - Tenta deletar Account sem token de acesso", state do
      response =
        state[:conn]
        |> delete(Routes.account_path(state[:conn], :delete, 951_951_951))

      assert %{resp_body: "{\"messagem\":\"Authorization Denied\"}", status: 401} = response
    end
  end
end
