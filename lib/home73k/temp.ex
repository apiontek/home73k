defmodule Home73k.Temp do
  @moduledoc """
  Simple module to generate temporary files
  """
  def file do
    System.tmp_dir!()
    |> Path.join(random_filename())
    |> touch_file()
  end

  defp random_filename do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64 |> binary_part(0, 32)
  end

  defp touch_file(fdname) do
    File.touch!(fdname)
    fdname
  end
end
