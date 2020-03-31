defmodule MessageSaver.Factory do
  use ExMachina.Ecto, repo: MessageSaver.Repo

  alias MessageSaver.Message

  def message_factory do
    %Message{
      author: "Author Name",
      channel: "channel-name",
      permalink: "http://permalink.url",
      text: "Message text.",
      user_id: "U208392"
    }
  end
end
