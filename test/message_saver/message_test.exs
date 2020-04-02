defmodule MessageSaver.MessageTest do
  use MessageSaver.DataCase, async: true
  import MessageSaver.Factory

  alias MessageSaver.Message

  describe "changeset/2" do
    test "it is valid when all attributes are present" do
      changeset =
        Message.changeset(%Message{}, %{
          author: "Author Name",
          channel: "channel-name",
          permalink: "http://permalink.url",
          text: "Message text.",
          user_id: "U02830"
        })

      assert changeset.valid?
    end

    test "it is invalid when there is no author" do
      changeset =
        Message.changeset(%Message{}, %{
          author: "",
          channel: "channel-name",
          text: "Message text.",
          user_id: "U02830"
        })

      refute changeset.valid?
    end

    test "it is invalid when there is no channel" do
      changeset =
        Message.changeset(%Message{}, %{
          author: "Author Name",
          channel: "",
          text: "Message text.",
          user_id: "U02830"
        })

      refute changeset.valid?
    end

    test "it is invalid when there is no text" do
      changeset =
        Message.changeset(%Message{}, %{
          author: "Author Name",
          channel: "channel-name",
          text: "",
          user_id: "U02830"
        })

      refute changeset.valid?
    end

    test "it is invalid when there is no user_id" do
      changeset =
        Message.changeset(%Message{}, %{
          author: "Author Name",
          channel: "channel-name",
          text: "Message text.",
          user_id: ""
        })

      refute changeset.valid?
    end
  end

  describe "delete_all_for_user/1" do
    test "it deletes all the messages for the given user" do
      user_message_1 = insert(:message, user_id: "U123456")
      message_1 = insert(:message)
      user_message_2 = insert(:message, user_id: "U123456")

      Message.delete_all_for_user("U123456")

      refute Repo.get(Message, user_message_1.id)
      assert Repo.get(Message, message_1.id)
      refute Repo.get(Message, user_message_2.id)
    end
  end

  describe "delete/1" do
    test "it deletes the specified message" do
      message = insert(:message)

      Message.delete(message.id)

      refute Repo.get(Message, message.id)
    end
  end

  describe "for_user/1" do
    test "it returns all messages for the specified user_id" do
      user_id = "U92857"
      message_1 = insert(:message, user_id: user_id)
      message_2 = insert(:message)
      message_3 = insert(:message, user_id: user_id)

      user_messages = Message.for_user(user_id)
      assert Enum.member?(user_messages, message_1)
      refute Enum.member?(user_messages, message_2)
      assert Enum.member?(user_messages, message_3)
    end
  end
end
