defmodule YamlEncoder do
  def encode value do
    encode 0, value
  end

  def encode(indent, data) when is_number(data) do
    "#{data}\n"
  end

  def encode(indent, data) when is_boolean(data) do
    value = case data do
      true -> "true"
      _ -> "false"
    end
    ~s(#{value}\n)
  end

  def encode(indent, data) when is_binary(data) do
    value = encode_string indent, data
    ~s(#{value}\n)
  end

  def encode(indent, data) when is_list(data) do
    encode_list indent, "", data
  end

  def encode(indent, data) when is_map(data) do
    encode_map indent, "", data
  end

  defp encode_list indent, s, [head|tail] do
    value = encode_list_item indent, head
    encode_list indent, "#{s}#{value}", tail
  end

  defp encode_list indent, s, [] do
    s
  end

  defp encode_list_item indent, data do
    value = encode data
    prefix = indent_spaces(indent)
    "#{prefix}- #{value}"
  end

  defp encode_map indent, s, data do
    for {k, v} <- data,
      do: encode_key_value(indent, {k, v}),
      into: s
  end

  defp encode_key_value indent, {k, v} do
    prefix = indent_spaces indent

    if is_map(v) || is_list(v) do
      value = encode indent + 1, v
      "#{k}:\n#{value}"
    else
      value = encode indent, v
      "#{k}: #{value}"
    end
  end

  defp encode_string indent, data do
    single_quotes = data =~ ~r/'/
    double_quotes = data =~ ~r/"/
    encode_string indent, data, single_quotes, double_quotes
  end

  def encode_string(indent, data, true, true) do
    ~s('''#{data}''')
  end

  def encode_string(indent, data, false, true) do
    ~s('#{data}')
  end

  def encode_string(indent, data, _single_quotes, _double_quotes) do
    ~s("#{data}")
  end

  defp indent_spaces 0 do
    ""
  end

  defp indent_spaces n do
    for _ <- (0..0-1), do: "  ", into: ""
  end
end