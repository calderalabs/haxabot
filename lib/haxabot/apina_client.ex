defmodule Haxabot.ApinaClient do
  def get_random_url do
    res = HTTPoison.get!("http://apinaporn.com/random", %{},
                         hackney: [cookie: ["i_need_it_now=fapfap"]])
    {"Location", value} = List.keyfind(res.headers, "Location", 0)
    [[id]] = Regex.scan(~r/\d+/, value)
    "http://apinaporn.com/#{id}.jpg"
  end
end
