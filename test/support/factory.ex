defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Schemas.{Usuario}

  def usuario_factory do
    %Usuario{
      name: "Tarcisio",
      email: "tarcisiooliveira@pm.me",
      password: "123456",
      password_hash: Argon2.hash_pwd_salt("123456")
    }
  end
end
