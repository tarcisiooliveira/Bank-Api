defmodule BankApiWeb.OperationView do
  use BankApiWeb, :view
  alias BankApi.Schemas.Operation
  alias Ecto.Changeset

  def render("show.json", %{operation:  %Operation{operation_name: operation_name}}) do
    %{
      mensagem: "Operation Type found.",
      operation:  operation_name
    }
  end

  def render("create.json", %{operation:  %{create_transaction: %Operation{operation_name: operation_name}}}) do
    %{
      mensagem: "Operation Recorded",
      Operação: %{operation_name: operation_name}
    }
  end
  def render("create.json", %{operation:  %Operation{operation_name: operation_name}}) do
    %{
      mensagem: "Operation Recorded",
      Operação: %{operation_name: operation_name}
    }
  end

  def render("update.json", %{operation:  %{update_operation: %Operation{operation_name: operation_name}}}) do
    %{
      mensagem: "Operation Updated",
      Operação: %{operation_name: operation_name}
    }
  end

  def render("delete.json", %{
        operation:  %{fetch_operation: %Operation{operation_name: operation_name}}
      }) do
    %{
      mensagem: "Operation #{operation_name} deleted successfully."
    }
  end

  def render("delete.json", %{error: :operation_not_exists}) do
    %{
      Result: "Non-existent operation.",
      Mensagem: "Invalid ID or inexistent."
    }
  end

  def render("delete.json", %{error: error}) do
    %{
      Result: "Non-existent operation.",
      Mensagem: error
    }
  end

  def render("error.json", %{error: :operation_already_exists}) do
    %{
      error: "Previously registered operation."
    }
  end

  def render(
        "error.json",
        %{error: %Changeset{errors: [operation_name: {"has already been taken", _error}]}} =
          _params
      ) do
    %{error: "Previously registered operation."}
  end

  def render("error.json", %{error: error} = _params) do
    %{error: error}
  end
end
