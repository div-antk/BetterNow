//
//  LogChartView.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import SwiftUI
import Charts

// ログ画面の上部に表示する折れ線グラフ

// - 直近7日間を表示
// - 未記入日は skip として扱う
// - skip は値を進めず、ポイントだけを表示する
// - 値は up(+1) / same(0) / down(-1) の累積スコア
// - Y軸は直近7日間の最小/最大値を基準に ±2 の余白を取る
// - X軸は曜日を7日ぶん必ず表示
struct LogChartView: View {
    let entries: [BetterEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("trend_title")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.primary)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay {
                    if last7ChartPoints.isEmpty {
                        Text("chart_placeholder")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        chart
                            .padding(16)
                    }
                }
                .frame(height: 200)
        }
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            ForEach(last7LineSegments) { segment in
                ForEach(segment.lineRuns) { run in
                    LineMark(
                        x: .value("Date", run.start.date),
                        y: .value("Better", run.start.value),
                        series: .value("Segment", run.id)
                    )
                    .lineStyle(StrokeStyle(lineWidth: run.lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(run.color)

                    LineMark(
                        x: .value("Date", run.end.date),
                        y: .value("Better", run.end.value),
                        series: .value("Segment", run.id)
                    )
                    .lineStyle(StrokeStyle(lineWidth: run.lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(run.color)
                }
            }

            ForEach(last7ChartPoints) { point in
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Better", point.value)
                )
                .symbolSize(point.isSkipped ? 80 : 52)
                .foregroundStyle(pointColor(for: point))
            }
        }
        // 両端の丸が切れないように、X軸の表示範囲に半日ぶんの余白を足す
        .chartXScale(domain: xDomain)

        // Y軸は直近1週間の最小/最大値 ±2 の可変レンジ
        .chartYScale(domain: yDomain)

        // 右側にY軸表示
        .chartYAxis {
            AxisMarks(position: .trailing, values: yAxisValues) { _ in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.12))
                AxisValueLabel()
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.secondary.opacity(0.8))
            }
        }

        // X軸は曜日表示（直近7日ぶんを必ず出す）
        .chartXAxis {
            AxisMarks(values: last7Days) { value in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.08))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            // 英語（Sun/Mon...）だと右端が省略されやすいので、1文字表記にする
                            .frame(width: 16, alignment: .center)
                            .lineLimit(1)
                            .offset(x: -12) // 微調整（必要なら 0〜-6 で調整）
                    }
                }
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.secondary.opacity(0.8))
            }
        }
        // プロット領域（グラフ描画部分）を確実にクリップ
        // ただし両端が切れやすいので、横だけ少し内側に余白を足してからクリップする
        .chartPlotStyle { plotArea in
            plotArea
                .clipped()
        }
    }

    // MARK: - Derived data

    // 今日を正午基準で固定（DSTズレ防止）
    private var anchorTodayNoon: Date {
        let cal = Calendar.autoupdatingCurrent
        let comps = cal.dateComponents([.year, .month, .day], from: .now)
        return cal.date(from: DateComponents(
            year: comps.year,
            month: comps.month,
            day: comps.day,
            hour: 12
        )) ?? .now
    }

    // 直近7日間の累積データ
    // - 未記入日は skip として扱う
    // - skip は値を進めずポイントだけを表示する
    private var last7ChartPoints: [ChartPoint] {

        let cal = Calendar.autoupdatingCurrent
        let days = last7Days

        // 日付 -> choice の辞書を作る（保存キーは YYYY-MM-DD）
        let entryMap: [String: BetterEntry] = Dictionary(
            uniqueKeysWithValues: entries.map { ($0.id, $0) }
        )

        var total: Double = 0
        var result: [ChartPoint] = []

        for day in days {
            // X軸のズレ防止のため、その日の開始（0:00）に揃える
            let startOfDay = cal.startOfDay(for: day)
            let key = DateFormatters.dayKey(startOfDay)
            let entry = entryMap[key]
            let choice = entry?.choice ?? .skipped
            let isSkipped = choice == .skipped

            total += Double(choice.deltaValue)

            result.append(
                ChartPoint(
                    id: key,
                    date: startOfDay,
                    value: total,
                    isSkipped: isSkipped
                )
            )
        }

        return result
    }

    private var last7LineSegments: [ChartSegment] {
        zip(last7ChartPoints, last7ChartPoints.dropFirst()).enumerated().compactMap { index, pair in
            // skip に入る線は切るが、skip から再開する線はつなぐ
            guard !pair.1.isSkipped else { return nil }

            return ChartSegment(
                id: "segment-\(index)",
                lineRuns: [
                    ChartLineRun(
                        id: "segment-\(index)-run",
                        start: pair.0,
                        end: pair.1
                    )
                ]
            )
        }
    }

    private var last7Days: [Date] {
        let cal = Calendar.autoupdatingCurrent
        let today = anchorTodayNoon

        return (0...6).compactMap {
            cal.date(byAdding: .day, value: -$0, to: today)
        }
        .map { cal.startOfDay(for: $0) }
        .sorted()
    }

    // 両端のポイントが切れないように、X軸の表示範囲に余白を追加
    // - start: 最初の日の 0:00 - 12時間
    // - end:   最後の日の 0:00 + 12時間
    private var xDomain: ClosedRange<Date> {
        guard let first = last7ChartPoints.first?.date,
              let last = last7ChartPoints.last?.date else {
            let now = Date()
            return now...now
        }

        let cal = Calendar.autoupdatingCurrent
        let start = cal.date(byAdding: .hour, value: -12, to: first) ?? first
        let end = cal.date(byAdding: .hour, value: 12, to: last) ?? last
        return start...end
    }

    // 直近1週間の最小/最大値を基準にしたY軸レンジ
    // - 下限: 最小値 - 2
    // - 上限: 最大値 + 2
    private var yDomain: ClosedRange<Double> {
        guard !last7ChartPoints.isEmpty else { return -2...2 }

        let values = last7ChartPoints.map(\.value)
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 0

        return (minV - 2)...(maxV + 2)
    }

    // Y軸ラベル生成（整数刻み）
    // 直近1週間の最小/最大値 ±2 の範囲で整数値を表示する
    private var yAxisValues: [Int] {
        let lower = Int(floor(yDomain.lowerBound))
        let upper = Int(ceil(yDomain.upperBound))
        guard lower <= upper else { return [] }
        return Array(lower...upper)
    }

    private func pointColor(for point: ChartPoint) -> Color {
        if point.isSkipped {
            return Color.secondary.opacity(0.45)
        }

        return Color.accentColor.opacity(0.72)
    }

    private struct ChartPoint: Identifiable {
        let id: String
        let date: Date
        let value: Double
        let isSkipped: Bool
    }

    private struct ChartSegment: Identifiable {
        let id: String
        let lineRuns: [ChartLineRun]
    }

    private struct ChartLineRun: Identifiable {
        let id: String
        let start: ChartPoint
        let end: ChartPoint

        var delta: Double {
            end.value - start.value
        }

        var color: Color {
            switch delta {
            case let value where value > 0:
                return Color.accentColor.opacity(0.95)
            case let value where value < 0:
                return Color.accentColor.opacity(0.22)
            default:
                return Color.accentColor.opacity(0.38)
            }
        }

        var lineWidth: CGFloat {
            switch delta {
            case let value where value > 0:
                return 2.8
            case let value where value < 0:
                return 1.4
            default:
                return 1.8
            }
        }
    }
}

#Preview {
    let store = EntryStore()
    let cal = Calendar.autoupdatingCurrent

    for i in (0...6).reversed() {
        let d = cal.date(byAdding: .day, value: -i, to: .now) ?? .now
        store.save(choice: .up, caption: "up", date: d)
    }

    return LogChartView(entries: store.entries)
        .padding()
}
