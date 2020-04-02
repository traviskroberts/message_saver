defmodule MessageSaver.MessageHandlerTest do
  use MessageSaver.DataCase
  import MessageSaver.Factory

  alias MessageSaver.MessageHandler
  alias MessageSaver.Message

  describe "clear_messages/1" do
    test "it deletes all of the messages for the user" do
      insert(:message, user_id: "U284981")

      MessageHandler.clear_messages(%{"user_id" => "U284981", "response_url" => "http://localhost"})

      assert Repo.aggregate(Message, :count) == 0
    end
  end

  describe "handle_action/1" do
    test "it deletes the specified message when action is 'Delete Message'" do
      message = insert(:message, user_id: "U284981")
      args = %{
        "actions" => [
          %{
            "value" => message.id,
            "text" => %{
              "text" => "Delete Message"
            }
          }
        ],
        "response_url" => "http://localhost",
        "user" => %{
          "id" => "U284981"
        }
      }
      MessageHandler.handle_action(args)

      assert Repo.aggregate(Message, :count) == 0
    end
  end

  describe "save_message/1" do
    test "it saves the message to the database" do
      args = %{
        "channel" => %{
          "id" => "channel_id"
        },
        "message" => %{
          "ts" => "118232987.3806",
          "text" => "This is the message.",
          "user" => "username"
        },
        "user" => %{
          "id" => "user_id"
        },
        "response_url" => "http://localhost"
      }
      MessageHandler.save_message(args)

      assert Repo.aggregate(Message, :count) == 1
    end
  end
end
