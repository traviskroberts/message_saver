defmodule MessageSaverWeb.Api.ActionsController do
  use MessageSaverWeb, :controller

  alias MessageSaver.MessageHandler

  def create(conn, %{"payload" => json_payload}) do
    payload = Poison.decode!(json_payload)

    if payload["callback_id"] == "save_message" do
      Task.async(MessageHandler, :save_message, [payload])
    end

    if payload["actions"] do
      Task.async(MessageHandler, :handle_action, [payload])
    end

    send_resp(conn, 204, "")
  end

  def command(conn, %{"command" => command, "text" => text} = params) do
    cond do
      command in ["/saved", "/saved_messages"] && text in ["list", ""] ->
        Task.async(MessageHandler, :retrieve_messages, [params])

      command in ["/saved", "/saved_messages"] && text == "clear" ->
        Task.async(MessageHandler, :clear_messages, [params])

      command in ["/saved", "/saved_messages"] && text == "help" ->
        Task.async(MessageHandler, :help_text, [params])

      true ->
        Task.async(MessageHandler, :unknown_command, [params])
    end

    send_resp(conn, 204, "")
  end
end
