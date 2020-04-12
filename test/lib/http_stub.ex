defmodule MessageSaver.Test.HttpStub do
  def get("https://slack.com/api/chat.getPermalink", _headers, _options) do
    resp = Poison.encode!(%{"permalink" => "http://www.permalink.com"})

    {:ok, %HTTPoison.Response{status_code: 200, body: resp}}
  end

  def get(url, headers, options) do
    %{url: url, headers: headers, options: options}
  end

  def post(url, body, headers) do
    %{url: url, body: body, headers: headers}
  end
end
