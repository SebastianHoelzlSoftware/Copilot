defmodule CopilotApiWeb.Plugs.EnsureParams do
  @moduledoc """
  A plug to ensure that a required parameter key exists in the connection parameters.
  It halts the connection with a 400 Bad Request if the key is missing.

  ## Example Usage

  In your controller:

      plug CopilotApiWeb.Plugs.EnsureParams, "customer" when action in [:create, :update]

  This will ensure that the `customer` key is present in the params for the
  `create` and `update` actions.
  """
  import Plug.Conn

  # We can reuse the FallbackController to render our standard error response.
  alias CopilotApiWeb.FallbackController

  def init(required_key) when is_binary(required_key) do
    required_key
  end

  def call(conn, required_key) do
    if Map.has_key?(conn.params, required_key) do
      conn
    else
      conn |> FallbackController.call({:error, :bad_request}) |> halt()
    end
  end
end
