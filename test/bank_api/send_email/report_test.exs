defmodule BankApi.SendEmailTest do
  use BankApi.DataCase, async: true
  alias BankApi.SendEmail.SendEmail

  describe "send email/1" do
    test "assert send email" do
      assert :ok = SendEmail.send()
    end
  end
end
