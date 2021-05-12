defmodule BankApi.Schemas.Conta do
  use Ecto.Schema
  alias BankApi.Schemas.{Usuario, TipoConta, Moeda, Transacao, Operacao}

    schema "usuarios" do
      field :saldo_conta,    :integer, null: false

      belongs_to(:trainer, Usuario)
      belongs_to(:tipo_conta, TipoConta)
      belongs_to(:moeda, Moeda)
      belongs_to(:transacao, Transacao)
      belongs_to(:operacao, Operacao)
      timestamps()
    end

end
