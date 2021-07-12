defmodule BankApi.SendEmail.SendEmail do
  @moduledoc """
    Module SendEmail send notifications to Uses about transaction finished.
  """
  def send(from_account, to_account_id, operation_id) do
    IO.puts(
      "Operation #{operation_id}, from Account #{from_account} to Account #{to_account_id}"
    )
  end

  def send(from_account, operation_id) do
    IO.puts("Operation #{operation_id}, from Account #{from_account}")
  end
end
