defmodule MessageSaverTest do
  use MessageSaver.DataCase, async: true
  import MessageSaver.Factory

  alias MessageSaver.Message

  describe "delete_all_messages_for_user/1" do
    test "it deletes all the messages for the given user" do
      user_message_1 = insert(:message, user_id: "U123456")
      message_1 = insert(:message)
      user_message_2 = insert(:message, user_id: "U123456")

      MessageSaver.delete_all_messages_for_user("U123456")

      refute Repo.get(Message, user_message_1.id)
      assert Repo.get(Message, message_1.id)
      refute Repo.get(Message, user_message_2.id)
    end
  end

  describe "delete_message_for_user/2" do
    test "it delete_message_for_users the specified message" do
      message = insert(:message)

      MessageSaver.delete_message_for_user(message.user_id, message.id)

      refute Repo.get(Message, message.id)
    end
  end

  describe "messages_for_user/1" do
    test "it returns all messages for the specified user_id" do
      user_id = "U92857"
      message_1 = insert(:message, user_id: user_id)
      message_2 = insert(:message)
      message_3 = insert(:message, user_id: user_id)

      user_messages = MessageSaver.messages_for_user(user_id)
      assert Enum.member?(user_messages, message_1)
      refute Enum.member?(user_messages, message_2)
      assert Enum.member?(user_messages, message_3)
    end
  end

  describe "save_new_message/1" do
    test "it saves the message to the db" do
      valid_attrs = params_for(:message)
      MessageSaver.save_new_message(valid_attrs)

      assert Repo.aggregate(Message, :count) == 1
    end
  end
end
