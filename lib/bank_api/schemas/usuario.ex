defmodule BankApi.Schemas.Usuario do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Schemas.Conta
  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "usuarios" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :contas, Conta
    timestamps()
  end

  @required [:email, :name, :password]
  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required)
    |> validate_required(@required)
  end

end
