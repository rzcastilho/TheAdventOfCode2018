defmodule Day04 do

  defmodule Event do
    defstruct [date: nil, time: nil, event: nil, guard: nil]
  end

  defp input do
    File.read!("input/day04.txt")
    |> String.split("\n")
    |> Enum.sort
  end

  defp parse_record(record) do
    Regex.named_captures(~r/\[(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2}) (?<hour>[0-9]{2}):(?<minute>[0-9]{2})\] (?<event>(Guard #(?<guard_id>[0-9]+) begins shift|falls asleep|wakes up))/, record)
  end

  defp event(%{"year" => year, "month" => month, "day" => day, "hour" => hour, "minute" => minute, "event" => "wakes up"}) do
    {:ok, date} = Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))
    {:ok, time} = Time.new(String.to_integer(hour), String.to_integer(minute), 0)
    %Event{date: date, time: time, event: :wakeup}
  end

  defp event(%{"year" => year, "month" => month, "day" => day, "hour" => hour, "minute" => minute, "event" => "falls asleep"}) do
    {:ok, date} = Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))
    {:ok, time} = Time.new(String.to_integer(hour), String.to_integer(minute), 0)
    %Event{date: date, time: time, event: :sleep}
  end

  defp event(%{"year" => year, "month" => month, "day" => day, "hour" => "00", "guard_id" => id}) do
    {:ok, date} = Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))
    {:ok, time} = Time.new(0, 0, 0)
    %Event{date: date, time: time, event: :start, guard: String.to_integer(id)}
  end

  defp event(%{"year" => year, "month" => month, "day" => day, "guard_id" => id}) do
    {:ok, date} = Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))
    {:ok, time} = Time.new(0, 0, 0)
    %Event{date: Date.add(date, 1), time: time, event: :start, guard: String.to_integer(id)}
  end

  defp fill_guard_id(record, guard) do
    case record do
      %{guard: nil} ->
        {%{record|guard: guard}, guard}
      %{guard: guard} ->
        {record, guard}
    end
  end

  defp group_by_date_guard(%{date: date, guard: guard}) do
    %{date: date, guard: guard, timeline: 0..59 |> Enum.map(fn minute -> {minute, "."} end)}
  end

  defp group_by_guard(%{guard: guard}) do
    %{guard: guard}
  end

  defp fill_timeline({%{timeline: timeline} = guard, records}) do
    Map.merge(guard, fill_timeline(timeline, records))
  end

  defp fill_timeline(timeline, [%{event: :start}|records]) do
    fill_timeline(timeline, records, %{sleep: 0, wakeup: 0, last_minute: 0, last_flag: "."})
  end

  defp fill_timeline(timeline, [], %{sleep: sleep, wakeup: wakeup, last_minute: last_minute, last_flag: "."}) do
    timeline = last_minute..59
    |> Enum.reduce(timeline, fn minute, acc -> List.replace_at(acc, minute, {minute, "."}) end)
    %{timeline: timeline, sleep: sleep, wakeup: wakeup + (60 - last_minute)}
  end

  defp fill_timeline(timeline, [], %{sleep: sleep, wakeup: wakeup, last_minute: last_minute, last_flag: "#"}) do
    timeline = last_minute..59
    |> Enum.reduce(timeline, fn minute, acc -> List.replace_at(acc, minute, {minute, "#"}) end)
    %{timeline: timeline, sleep: sleep + (60 - last_minute), wakeup: wakeup}
  end

  defp fill_timeline(timeline, [record|records], %{sleep: sleep, wakeup: wakeup, last_minute: last_minute, last_flag: last_flag}) do
    case record do
      %{event: :sleep, time: time} ->
        timeline = last_minute..(time.minute - 1)
        |> Enum.reduce(timeline, fn minute, acc -> List.replace_at(acc, minute, {minute, last_flag}) end)
        fill_timeline(timeline, records, %{sleep: sleep, wakeup: wakeup + (time.minute - last_minute), last_minute: time.minute, last_flag: "#"})
      %{event: _, time: time} ->
        timeline = last_minute..(time.minute - 1)
                   |> Enum.reduce(timeline, fn minute, acc -> List.replace_at(acc, minute, {minute, last_flag}) end)
        fill_timeline(timeline, records, %{sleep: sleep + (time.minute - last_minute), wakeup: wakeup, last_minute: time.minute, last_flag: "."})
    end
  end

  #defp print_record(%{date: date, guard: guard, timeline: timeline}) do
  #  "#{String.pad_leading(Integer.to_string(date.month), 2, "0")}-#{String.pad_leading(Integer.to_string(date.day), 2, "0")}  ##{String.pad_leading(Integer.to_string(guard), 5, "0")}  #{print_timeline(timeline)}"
  #end

  #defp print_timeline(timeline) do
  #  timeline
  #  |> Enum.map(fn {_, flag} -> flag end)
  #  |> Enum.join
  #end

  defp summarize_guard({%{guard: guard}, records}) do
    records
    |> Enum.reduce(0..59 |> Enum.reduce(%{guard: guard, sleep: 0, wakeup: 0, timeline: %{}}, fn x, %{guard: guard, sleep: sleep, wakeup: sleep, timeline: acc} -> %{guard: guard, sleep: sleep, wakeup: sleep, timeline: Map.put(acc, String.pad_leading(Integer.to_string(x), 2, "0"), 0)} end),
        fn %{timeline: timeline, sleep: sleep, wakeup: wakeup}, %{timeline: acc_timeline} = acc_guard ->
          acc_guard = acc_guard
          |> Map.put(:sleep, Map.get(acc_guard, :sleep, 0) + sleep)
          |> Map.put(:wakeup, Map.get(acc_guard, :wakeup, 0) + wakeup)
          new_timeline = Enum.reduce(timeline, acc_timeline,
            fn {minute, flag}, sum ->
              minute_key = String.pad_leading(Integer.to_string(minute), 2, "0")
              case flag do
                "#" ->
                  Map.put(sum, minute_key, Map.get(acc_timeline, minute_key, 0) + 1)
                _ ->
                  Map.put(sum, minute_key, Map.get(acc_timeline, minute_key, 0))
              end
            end)
          %{acc_guard|timeline: new_timeline}
        end)
  end

  def part1 do
    %{guard: guard, timeline: timeline} = input()
    |> Enum.map(&parse_record/1)
    |> Enum.map(&event/1)
    |> Enum.map_reduce(nil, &fill_guard_id/2)
    |> elem(0)
    |> Enum.group_by(&group_by_date_guard/1)
    |> Enum.map(&fill_timeline/1)
    |> Enum.group_by(&group_by_guard/1)
    |> Enum.map(&summarize_guard/1)
    |> Enum.max_by(fn %{sleep: sleep} -> sleep end)
    {minute, _} = timeline
    |> Enum.max_by(fn {_, times} -> times end)
    guard * String.to_integer(minute)
  end

  def part2 do
    %{guard: guard, minute: minute} = input()
    |> Enum.map(&parse_record/1)
    |> Enum.map(&event/1)
    |> Enum.map_reduce(nil, &fill_guard_id/2)
    |> elem(0)
    |> Enum.group_by(&group_by_date_guard/1)
    |> Enum.map(&fill_timeline/1)
    |> Enum.group_by(&group_by_guard/1)
    |> Enum.map(&summarize_guard/1)
    |> Enum.reduce(%{guard: 0, minute: 0, total: 0},
      fn %{guard: guard, timeline: timeline}, %{total: last_total} = acc ->
        {minute, total} = Enum.max_by(timeline, fn {_, times} -> times end)
        case total > last_total do
          true ->
            %{guard: guard, minute: String.to_integer(minute), total: total, }
          _ ->
            acc
        end
      end)
    guard * minute
  end

end
