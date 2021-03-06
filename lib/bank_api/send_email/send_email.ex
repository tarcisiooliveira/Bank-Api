defmodule BankApi.SendEmail.SendEmail do
  @moduledoc """
    Module SendEmail send notifications to Uses about transaction finished.
  """
  @spec send :: :ok
  def send do
    :timer.sleep(100)
    IO.puts("Email sent")
  end
end
