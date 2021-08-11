defmodule BankApiWeb.ControllerAccountTest do
  @moduledoc """
  Module test Account Controller
  """

  use BankApiWeb.ConnCase, async: true

  alias BankApi.Users.Schemas.User
  alias BankApi.Accounts.Schemas.Account
  alias BankApiWeb.Auth.GuardianAdmin
  alias BankApi.Multi.Account, as: MultiAccount
  import BankApi.Factory

  setup do
    [conn: "Phoenix.ConnTest.build_conn()"]

    admin = insert(:admin)

    {:ok, token, _claims} = GuardianAdmin.encode_and_sign(admin)

    {:ok,
     value: %{
       token: token
     }}
  end

  describe "UPDATE" do
    test "assert update - update balance to value higher than zero." do
      %User{id: user_id} = insert(:user)

      %Account{id: id} = insert(:account, user_id: user_id)
      assert %Account{balance_account: 10_000} = BankApi.Repo.get_by(Account, id: id)

      %{balance_account: 3_000, id: id}
      |> MultiAccount.update()

      assert %Account{balance_account: 3_000} = BankApi.Repo.get_by(Account, id: id)
    end

    test "assert update - update balance to value equal zero." do
      %User{id: user_id} = insert(:user)
      %Account{id: id} = insert(:account, user_id: user_id)

      response =
        %{balance_account: 0, id: id}
        |> MultiAccount.update()

      assert {:ok, %{ammount_non_negative: :ammount_positive_value}} = response
    end

    test "assert update - try withdraw insufficente ammount." do
      %User{id: user_id} = insert(:user)
      %Account{id: id} = insert(:account, user_id: user_id)

      response =
        %{balance_account: 10_001, id: id}
        |> MultiAccount.update()

      assert {:ok, %{ammount_non_negative: :ammount_positive_value}} = response
    end

    test "error update - try update balance to value lower than zero" do
      %User{id: user_id} = insert(:user)
      %Account{id: id} = insert(:account, user_id: user_id)

      response =
        %{balance_account: -1, id: id}
        |> MultiAccount.update()

      assert {:error, :ammount_negative_value} = response
    end
  end
end
