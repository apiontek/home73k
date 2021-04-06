defmodule Home73kWeb.LiveHelpers do
  @moduledoc """
  Functions to make working with Phoenix LiveView a little easier.
  """

  @doc """
  Performs the {:noreply, socket} for a given socket.
  This helps make the noreply pipeable
  """
  def live_noreply(socket), do: {:noreply, socket}

  @doc """
  Performs the {:ok, socket} for a given socket.
  This helps make the ok reply pipeable
  """
  def live_okreply(socket), do: {:ok, socket}
end
