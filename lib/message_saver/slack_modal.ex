defmodule MessageSaver.SlackModal do
  def body(message_id) do
    %{
      "type" => "modal",
      "callback_id" => Integer.to_string(message_id),
      "title" => %{
        "type" => "plain_text",
        "text" => "Save Message",
        "emoji" => true
      },
      "submit" => %{
        "type" => "plain_text",
        "text" => "Save",
        "emoji" => true
      },
      "close" => %{
        "type" => "plain_text",
        "text" => "Cancel",
        "emoji" => true
      },
      "blocks" => [
        %{
          "type" => "input",
          "block_id" => "notes",
          "optional" => true,
          "element" => %{
            "action_id" => "notes_input",
            "type" => "plain_text_input",
            "multiline" => true
          },
          "label" => %{
            "type" => "plain_text",
            "text" => "Add a note (optional)",
            "emoji" => true
          }
        },
        %{
          "type" => "input",
          "block_id" => "interval",
          "optional" => true,
          "label" => %{
            "type" => "plain_text",
            "text" => "Set a reminder (optional)",
            "emoji" => true
          },
          "element" => %{
            "action_id" => "reminder_input",
            "type" => "static_select",
            "placeholder" => %{
              "type" => "plain_text",
              "text" => "Remind me in...",
              "emoji" => true
            },
            "options" => [
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "15 minutes",
                  "emoji" => true
                },
                "value" => "15"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "30 minutes",
                  "emoji" => true
                },
                "value" => "30"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "1 hour",
                  "emoji" => true
                },
                "value" => "60"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "4 hours",
                  "emoji" => true
                },
                "value" => "240"
              },
              %{
                "text" => %{
                  "type" => "plain_text",
                  "text" => "Tomorrow",
                  "emoji" => true
                },
                "value" => "tomorrow"
              }
            ]
          }
        }
      ]
    }
  end
end
