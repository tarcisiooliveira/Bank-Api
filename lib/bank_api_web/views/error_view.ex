defmodule BankApiWeb.ErrorView do
  use BankApiWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  alias Ecto.Changeset

  def render("401.json", %{error: _error}) do
    %{error: "Admin not found."}
  end

  def render("400.json", %{error: error}) do
    %{error: error}
  end

  def render("500.json", %{error: error}) do
    %{error: error}
  end

  def render("error_message.json", %{message: message}) do
    %{error: [message]}
  end

  def render("error_changeset.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end
end
