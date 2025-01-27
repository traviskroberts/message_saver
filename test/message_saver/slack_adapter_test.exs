defmodule MessageSaver.SlackAdapterTest do
  use MessageSaver.DataCase, async: true

  alias MessageSaver.SlackAdapter
  alias MessageSaver.SlackModal

  describe "get_permalink/1" do
    test "it returns the permalink when one is found" do
      payload = %{
        "channel" => %{
          "id" => 10
        },
        "message" => %{
          "ts" => "273948729384"
        }
      }

      assert SlackAdapter.get_permalink(payload) == "http://www.permalink.com"
    end
  end

  describe "present_modal/2" do
    test "it sends a modal to the user" do
      expected = %{
        url: "https://slack.com/api/views.open",
        body:
          URI.encode_query(%{
            token: System.get_env("SLACK_TOKEN"),
            trigger_id: 2,
            view: Poison.encode!(SlackModal.body(1))
          }),
        headers: [{"Content-Type", "application/x-www-form-urlencoded"}]
      }

      assert SlackAdapter.present_modal(1, 2) == expected
    end
  end

  describe "send_confirmation/2" do
    test "it sends the correct message when action is 'clear'" do
      expected = %{
        url: "foo",
        body:
          Poison.encode!(%{
            "text" => "All saved messages have been deleted.",
            "response_type" => "ephemeral"
          }),
        headers: [{"Content-Type", "application/json"}]
      }

      assert SlackAdapter.send_confirmation("clear", "foo") == expected
    end

    test "it sends the correct message when action is 'deleted'" do
      expected = %{
        url: "foo",
        body:
          Poison.encode!(%{
            "text" => "Message deleted!",
            "response_type" => "ephemeral"
          }),
        headers: [{"Content-Type", "application/json"}]
      }

      assert SlackAdapter.send_confirmation("deleted", "foo") == expected
    end

    test "it sends the correct message when action is 'list_empty'" do
      expected = %{
        url: "foo",
        body:
          Poison.encode!(%{
            "text" => "You don’t have any saved messages.",
            "response_type" => "ephemeral"
          }),
        headers: [{"Content-Type", "application/json"}]
      }

      assert SlackAdapter.send_confirmation("list_empty", "foo") == expected
    end

    test "it sends the correct message when action is 'save'" do
      expected = %{
        url: "foo",
        body:
          Poison.encode!(%{
            "text" => "Message saved!",
            "response_type" => "ephemeral"
          }),
        headers: [{"Content-Type", "application/json"}]
      }

      assert SlackAdapter.send_confirmation("save", "foo") == expected
    end

    test "it sends the correct message when action is 'unknown'" do
      expected = %{
        url: "foo",
        body:
          Poison.encode!(%{
            "text" => "Unknown command. Use `/saved_messages help` to see available commands.",
            "response_type" => "ephemeral"
          }),
        headers: [{"Content-Type", "application/json"}]
      }

      assert SlackAdapter.send_confirmation("unknown", "foo") == expected
    end
  end

  describe "send_messages_list/2" do
    test "it sends the messages to the user" do
      expected = %{
        url: "https://slack.com/api/chat.postMessage",
        body:
          URI.encode_query(%{
            token: System.get_env("SLACK_TOKEN"),
            channel: 3,
            blocks: Poison.encode!(%{"foo" => "bar"})
          }),
        headers: [{"Content-Type", "application/x-www-form-urlencoded"}]
      }

      assert SlackAdapter.send_messages_list(%{"foo" => "bar"}, 3) == expected
    end
  end
end
