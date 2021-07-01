defmodule BankApi.Multi.Admin do
  alias BankApi.Schemas.Admin
  alias BankApi.Repo
  alias BankApi.Handle.Repo.Admin, as: HandleRepoAdmin
  alias BankApi.Handle.Repo.Operacao, as: HandleOperacaoRepo
  alias Ecto.Changeset

  def create(params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:changeset_valido, fn _, _ ->
        Admin.changeset(params)

        case Admin.changeset(params) do
          %Changeset{errors: [password_confirmation: {"Senhas diferentes.", _}]} ->
            {:error, :senhas_diferentes}

          %Changeset{errors: [email: {"Email já em uso.", _}]} ->
            {:error, :email_ja_cadastrado}

          %Changeset{errors: [email: {"Email formato inválido", _}]} ->
            {:error, :email_formato_invalido}

          %Changeset{errors: [password: {"Password deve conter entre 4 e 10 caracteres.", _}]} ->
            {:error, :password_entre_4_e_10_caracteres}

          %Changeset{errors: [password_confirmation: {"can't be blank", [validation: :required]}]} ->
            {:error, :confirmacao_senha_necessario}

          %Changeset{errors: [password_confirmation: _, password: _]} ->
            {:error, :senhas_diferentes}

          _ ->
            {:ok, :paramentros_validos}
        end
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def update(%{id: id, email: email}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:try_admin_by_email, fn _, _ ->
        case HandleRepoAdmin.fetch_admin_email(%{email: email}) do
          nil ->
            {:ok, "Email válido."}

          admin ->
            {:error, "Email já em uso."}
        end
      end)
      |> Ecto.Multi.run(:fetch_admin_account, fn _, _ ->
        case HandleRepoAdmin.fetch_admin(%{id: id}) do
          nil ->
            {:error, "ID inválido"}

          admin ->
            {:ok, admin}
        end
      end)
      |> Ecto.Multi.update(:update_admin, fn %{fetch_admin_account: fetch_admin_account} ->
        case HandleRepoAdmin.update(fetch_admin_account, %{email: email}) do
          %Admin{} = admin ->
            admin

          %Changeset{} = changeset ->
            changeset
        end
      end)

    case Repo.transaction(multi) do
      {:ok, params} ->
        {:ok, params}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  # defp cria_transacao(conta_origem_id, conta_destino_id, operacao, valor) do
  #   %Admin{

  #   }
  #   |> Admin.changeset()
  # end

  # defp cria_transacao(conta_origem_id, operacao, valor) do
  #   %{conta_origem_id: conta_origem_id, operacao_id: String.to_integer(operacao), valor: valor}
  #   |> Admin.changeset()
  # end

  # defp buscar_conta(id) do
  #   case HandleContaRepo.get_account(id) do
  #     nil -> {:error, :conta_nao_encontrada}
  #     account -> {:ok, account}
  #   end
  # end

  # defp buscar_operacao(operacao_id) do
  #   case HandleOperacaoRepo.get_account(operacao_id) do
  #     nil -> {:error, :operacao_nao_encontrada}
  #     account -> {:ok, account}
  #   end
  # end

  # defp is_mesma_conta?(id_origem, id_destino) do
  #   id_origem == id_destino
  # end

  # defp is_valor_negativo?(value) do
  #   if value == 0 or Decimal.new(value) |> Decimal.negative?(), do: true, else: false
  # end

  # defp is_saldo_suficiente?(saldo_inicial, valor),
  #   do: if(saldo_inicial - valor >= 0, do: true, else: false)

  # defp operacao(conta, valor, :subtrair) do
  #   novo = conta.saldo_conta - valor

  #   conta
  #   |> Conta.update_changeset(%{saldo_conta: novo})
  # end

  # defp operacao(conta, valor, :adicionar) do
  #   conta
  #   |> Conta.update_changeset(%{saldo_conta: conta.saldo_conta + valor})
  # end
end
