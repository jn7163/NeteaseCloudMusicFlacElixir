defmodule SongDownloader do
  @min_size 10

  def download_songs([]) do [] end

  def download_songs([song_name | song_list]) do
    IO.puts "song_name: #{song_name}"
    Song_info.get_song_info(song_name)
    |> Song_info.get_song_id
    |> Song_info.get_download_url_info
    |> Song_info.get_song_detail
    |> startDownload
    download_songs(song_list)
  end

  def startDownload(%{"song_link"=> ""}) do IO.puts "can not find song link\n" end
  def startDownload(%{"song_link"=> song_link, "song_name"=> song_name, "artist_name"=> artist_name})
  do
    IO.puts "\nsong_link is #{song_link}, song_name: #{song_name}, artist_name: #{artist_name}\n" 
    song_dir = "song_dir"
    File.mkdir(song_dir)
    filename = 
      Path.join([System.cwd(), song_dir, "#{song_name}-#{artist_name}.flac"]) 
      |> String.replace(" ", "")
      |> String.replace(",", "-")

    if File.exists?(filename) do 
      IO.puts "#{song_name} is already downloaded. Finding next song...\n\n"
    else
      IO.puts "#{song_name}  is downloading now ......\n\n"
      %{body: body, headers: headers} = 
        song_link
        |> HTTPotion.get([timeout: 1_000_000])

        content_size = 
          headers["content-length"] 
          |> Integer.parse() |> elem(0) 
          |> div(1024 * 1024) 

          cond do
            (content_size < @min_size) ->
              IO.puts "the size of #{filename} (#{content_size} Mb) is less than 10 Mb, skipping"
            true ->
              {:ok, file} = File.open filename, [:write]
              IO.binwrite file, body
          end
    end
  end

end
