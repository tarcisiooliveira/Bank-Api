defmodule BankApiWeb.ReportControllerTest do
  @moduledoc """
  Module test Report Controller
  """
  use BankApiWeb.ConnCase, async: false
  import BankApi.Factory
  alias BankApiWeb.Auth.GuardianAdmin
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Users.Schemas.User

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]
    admin = insert(:admin)

    {:ok, token, _claims} = GuardianAdmin.encode_and_sign(admin)

    %User{id: user_id1} = insert(:user)
    %User{id: user_id2} = insert(:user)
    %User{id: user_id3} = insert(:user)

    %Account{id: account_id_1} = insert(:account, user_id: user_id1)

    %Account{id: account_id_2} = insert(:account, user_id: user_id2)

    %Account{id: account_id_3} = insert(:account, user_id: user_id3)

    insert(:withdraw,
      from_account_id: account_id_1,
      value: 100,
      inserted_at: NaiveDateTime.utc_now()
    )

    insert(:withdraw,
      from_account_id: account_id_1,
      value: 100,
      inserted_at: ~N[2021-06-14 16:50:03]
    )

    insert(:withdraw,
      from_account_id: account_id_2,
      value: 100,
      inserted_at: ~N[2021-06-15 02:17:10]
    )

    insert(:transfer,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      value: 100,
      inserted_at: ~N[2021-07-16 02:17:10]
    )

    insert(:transfer,
      from_account_id: account_id_1,
      to_account_id: account_id_2,
      value: 100,
      inserted_at: ~N[2021-07-16 02:17:10]
    )

    insert(:transfer,
      from_account_id: account_id_1,
      to_account_id: account_id_3,
      value: 100,
      inserted_at: ~N[2021-08-01 02:17:10]
    )

    insert(:transfer,
      from_account_id: account_id_2,
      to_account_id: account_id_3,
      value: 100,
      inserted_at: ~N[2021-08-04 02:17:10]
    )

    insert(:transfer,
      from_account_id: account_id_2,
      to_account_id: account_id_3,
      value: 100,
      inserted_at: ~N[2021-08-05 02:17:10]
    )

    insert(:transfer,
      from_account_id: account_id_2,
      to_account_id: account_id_3,
      value: 100,
      inserted_at: ~N[2020-08-05 02:17:10]
    )

    {:ok,
     value: %{
       account_id_1: account_id_1,
       account_id_2: account_id_2,
       account_id_3: account_id_3,
       token: token
     }}
  end

  test "transaction in all period", state do
    params = %{"period" => "all"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"result" => %{"transfer" => 600, "withdraw" => 300}} =
             Jason.decode!(response.resp_body)
  end

  test "all transcations today", state do
    params = %{"period" => "today"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"result" => %{"transfer" => 0, "withdraw" => 100}} = Jason.decode!(response.resp_body)
  end

  test "all transcations this on month", state do
    params = %{"period" => "month"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"result" => %{"transfer" => 300, "withdraw" => 100}} = Jason.decode!(response.resp_body)
  end

  test "all transcations different month", state do
    params = %{"period" => "month", "month" => "08"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"result" => %{"transfer" => 300, "withdraw" => 100}} = Jason.decode!(response.resp_body)
  end

  test "transaction in 2020", state do
    params = %{"period" => "year", "year" => "2020"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"result" => %{"transfer" => 100, "withdraw" => 0}} = Jason.decode!(response.resp_body)
  end

  test "erro when past invalid parameter", state do
    params = %{"period" => "todays"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"error" => %{"message" => ["Invalid Parameters"]}} =
             Jason.decode!(response.resp_body)
  end

  test "erro when past invalids parameters", state do
    params = %{"period" => "year", "years" => "2020"}

    response =
      state[:conn]
      |> put_req_header("authorization", "Bearer " <> state[:value].token)
      |> post(Routes.report_path(state[:conn], :report, params))

    assert %{"error" => %{"message" => ["Invalid Parameters"]}} =
             Jason.decode!(response.resp_body)
  end
end
