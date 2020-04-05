defmodule MessageSaver.MessageTest do
  use MessageSaver.DataCase, async: true

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
end
