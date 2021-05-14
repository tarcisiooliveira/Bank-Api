defmodule BankApi.Schemas.Usuario do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Conta

  #Schema com o mesmo nome da tabela
  schema "usuarios" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many(:conta, Conta)
    timestamps()
  end

  @request_params [:email, :name, :password]

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @request_params)
    |> validate_required(@request_params)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
