defmodule BankApiWeb.ReportControllerTest do
  @moduledoc """
  Module test Report Controller
  """
  use BankApiWeb.ConnCase, async: true
  import BankApi.Factory
  alias BankApiWeb.Auth.GuardianAdmin
  alias BankApi.Accounts.Schemas.Account
  alias BankApi.Users.Schemas.User
  alias BankApi.Report.HandleReport

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
     valores: %{
       account_id_1: account_id_1,
       account_id_2: account_id_2,
       account_id_3: account_id_3,
       token: token
     }}
  end

  test "all transcations today", %{conn: _conn} do
    result =
      %{period: :today}
      |> HandleReport.report()

    assert {:ok, [result: 100]} = result
  end

  test "all transcations this month", %{conn: _conn} do
    result =
      %{period: :month}
      |> HandleReport.report()

    assert {:ok, [result: 400]} = result
  end

  test "all transcations different month", %{conn: _conn} do
    result =
      %{period: :month, month: "08"}
      |> HandleReport.report()

    assert {:ok, [result: 400]} = result
  end

  test "transaction in all period", %{conn: _conn} do
    result =
      %{period: :all}
      |> HandleReport.report()

    assert {:ok, [result: 900]} = result
  end

  test "transaction in 2020", %{conn: _conn} do
    result =
      %{period: :year, year: "2020"}
      |> HandleReport.report()

    assert {:ok, [result: 100]} = result
  end

  test "erro when past invalid parameter", %{conn: _conn} do
    result =
      %{period: :todays}
      |> HandleReport.report()

    assert {:error, :invalid_parameters} = result
  end

  test "erro when past invalids parameters", %{conn: _conn} do
    result =
      %{period: :year, years: "2020"}
      |> HandleReport.report()

    assert {:error, :invalid_parameters} = result
  end
end
