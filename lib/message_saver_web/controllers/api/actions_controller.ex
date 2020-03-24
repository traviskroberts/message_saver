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

  def command(conn, params) do
    if params["command"] == "/saved_messages" && params["text"] == "list" do
      Task.async(MessageHandler, :retrieve_messages, [params])
    end

    if params["command"] == "/saved_messages" && params["text"] == "clear" do
      Task.async(MessageHandler, :clear_messages, [params])
    end

    send_resp(conn, 204, "")
  end
end
