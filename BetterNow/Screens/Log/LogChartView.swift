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
// - 欠け日は same(0) として補間
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
        Chart(last7ChartPoints) { p in
            // 累積スコアの折れ線（直線）
            LineMark(
                x: .value("Date", p.date),
                y: .value("Better", p.value)
            )
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .foregroundStyle(Color.accentColor)

            // 各日のポイント表示
            PointMark(
                x: .value("Date", p.date),
                y: .value("Better", p.value)
            )
            .symbolSize(64)
            .foregroundStyle(Color.accentColor)
        }
        // 両端の丸が切れないように、X軸の表示範囲に半日ぶんの余白を足す
        .chartXScale(domain: xDomain)

        // Y軸は直近1週間の最小/最大値 ±2 の可変レンジ
        .chartYScale(domain: yDomain)

        // 右側にY軸表示
        .chartYAxis {
            AxisMarks(position: .trailing, values: yAxisValues) { _ in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.20))
                AxisValueLabel()
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.gray)
            }
        }

        // X軸は曜日表示（直近7日ぶんを必ず出す）
        .chartXAxis {
            AxisMarks(values: last7ChartPoints.map(\.date)) { value in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.12))
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
                .foregroundStyle(Color.gray)
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

    // 直近7日間の累積データ（欠け日は same(0) として補間）
    private var last7ChartPoints: [ChartPoint] {

        let cal = Calendar.autoupdatingCurrent
        let today = anchorTodayNoon

        // 直近7日間の日付配列を生成
        let days: [Date] = (0...6).compactMap {
            cal.date(byAdding: .day, value: -$0, to: today)
        }.sorted()

        // 日付 -> choice の辞書を作る（保存キーは YYYY-MM-DD）
        let entryMap: [String: BetterChoice] = Dictionary(
            uniqueKeysWithValues: entries.map { ($0.id, $0.choice) }
        )

        var total: Double = 0
        var result: [ChartPoint] = []

        for day in days {
            // X軸のズレ防止のため、その日の開始（0:00）に揃える
            let startOfDay = cal.startOfDay(for: day)
            let key = DateFormatters.dayKey(startOfDay)

            // 欠け日は same(0) として扱う
            let choice = entryMap[key] ?? .same

            total += Double(choice.rawValue)

            result.append(
                ChartPoint(
                    id: key,
                    date: startOfDay,
                    value: total
                )
            )
        }

        return result
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

    private struct ChartPoint: Identifiable {
        let id: String
        let date: Date
        let value: Double
    }

    // 固定のマゼンタ色（ライト/ダーク共通）
    private static let healthMagenta = Color(red: 0.82, green: 0.18, blue: 0.86)
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
