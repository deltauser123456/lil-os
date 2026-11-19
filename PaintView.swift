import SwiftUI

private struct LilOSPaintPoint: Codable {
    let x: Double
    let y: Double
}

private struct LilOSPaintStroke: Codable, Identifiable {
    let id: UUID
    var points: [LilOSPaintPoint]
    var colorName: String
    var width: Double

    init(points: [LilOSPaintPoint], colorName: String, width: Double) {
        id = UUID()
        self.points = points
        self.colorName = colorName
        self.width = width
    }
}

private struct LilOSPaintColor: Identifiable {
    let name: String
    let color: Color
    var id: String { name }
}

struct PaintView: View {
    @State private var strokes: [LilOSPaintStroke] = []
    @State private var activeStroke: LilOSPaintStroke?
    @State private var selectedColor = "cyan"
    @State private var brushSize = 7.0
    @State private var saveStatus = "Draw something!"
    @State private var showClearConfirmation = false

    private let storageKey = "LilOS.Paint.Strokes"
    private let palette: [LilOSPaintColor] = [
        LilOSPaintColor(name: "cyan", color: .cyan),
        LilOSPaintColor(name: "pink", color: .pink),
        LilOSPaintColor(name: "yellow", color: .yellow),
        LilOSPaintColor(name: "white", color: .white),
        LilOSPaintColor(name: "mint", color: .mint),
        LilOSPaintColor(name: "orange", color: .orange),
        LilOSPaintColor(name: "purple", color: .purple)
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Paint Studio")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text(saveStatus)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 21))
                    .foregroundStyle(.pink)
            }

            HStack(spacing: 5) {
                ForEach(palette) { option in
                    Button {
                        selectedColor = option.name
                    } label: {
                        Circle()
                            .fill(option.color)
                            .frame(width: 23, height: 23)
                            .overlay {
                                Circle()
                                    .stroke(
                                        selectedColor == option.name ? Color.white : Color.white.opacity(0.22),
                                        lineWidth: selectedColor == option.name ? 3 : 1
                                    )
                                    .padding(selectedColor == option.name ? -3 : 0)
                            }
                            .frame(width: 31, height: 31)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(option.name) paint color")
                    .accessibilityAddTraits(selectedColor == option.name ? .isSelected : [])
                }
                Spacer(minLength: 0)
                Text(selectedColor.capitalized)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }

            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.96, green: 0.97, blue: 0.99))

                    Canvas { context, size in
                        let visibleStrokes = strokes + (activeStroke.map { [$0] } ?? [])
                        for stroke in visibleStrokes {
                            let points = stroke.points.map {
                                CGPoint(x: $0.x * size.width, y: $0.y * size.height)
                            }
                            guard let firstPoint = points.first else { continue }

                            let color = paintColor(named: stroke.colorName)
                            let lineWidth = CGFloat(stroke.width)

                            if points.count == 1 {
                                let dot = CGRect(
                                    x: firstPoint.x - lineWidth / 2,
                                    y: firstPoint.y - lineWidth / 2,
                                    width: lineWidth,
                                    height: lineWidth
                                )
                                context.fill(Path(ellipseIn: dot), with: .color(color))
                            } else {
                                var path = Path()
                                path.move(to: firstPoint)
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                                context.stroke(
                                    path,
                                    with: .color(color),
                                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                                )
                            }
                        }
                    }
                    .padding(1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let width = max(geometry.size.width, 1)
                            let height = max(geometry.size.height, 1)
                            let point = LilOSPaintPoint(
                                x: Double(min(max(value.location.x / width, 0), 1)),
                                y: Double(min(max(value.location.y / height, 0), 1))
                            )

                            if activeStroke == nil {
                                activeStroke = LilOSPaintStroke(
                                    points: [point],
                                    colorName: selectedColor,
                                    width: brushSize
                                )
                            } else {
                                activeStroke?.points.append(point)
                            }
                        }
                        .onEnded { _ in
                            finishStroke()
                        }
                )
                .accessibilityLabel("Drawing canvas")
            }
            .frame(minHeight: 150)

            HStack(spacing: 9) {
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.65))
                Slider(value: $brushSize, in: 2...22, step: 1)
                    .tint(.cyan)
                    .accessibilityLabel("Brush size")
                Text("\(Int(brushSize))")
                    .font(.system(size: 10, weight: .semibold).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.65))
                    .frame(width: 19)

                Button {
                    undoStroke()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .disabled(strokes.isEmpty)
                .opacity(strokes.isEmpty ? 0.35 : 1)
                .accessibilityLabel("Undo last stroke")

                Button {
                    showClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.red.opacity(0.25), in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .disabled(strokes.isEmpty)
                .opacity(strokes.isEmpty ? 0.35 : 1)
                .accessibilityLabel("Clear drawing")
            }
        }
        .padding(14)
        .onAppear(perform: loadDrawing)
        .alert("Clear drawing?", isPresented: $showClearConfirmation) {
            Button("Clear", role: .destructive) {
                strokes.removeAll()
                persistDrawing()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This removes all saved strokes from Paint Studio.")
        }
    }

    private func paintColor(named name: String) -> Color {
        switch name {
        case "pink": return .pink
        case "yellow": return .yellow
        case "white": return .white
        case "mint": return .mint
        case "orange": return .orange
        case "purple": return .purple
        default: return .cyan
        }
    }

    private func finishStroke() {
        guard let completedStroke = activeStroke else { return }
        strokes.append(completedStroke)
        activeStroke = nil
        persistDrawing()
    }

    private func undoStroke() {
        guard !strokes.isEmpty else { return }
        strokes.removeLast()
        persistDrawing()
    }

    private func loadDrawing() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            strokes = try JSONDecoder().decode([LilOSPaintStroke].self, from: data)
            saveStatus = strokes.isEmpty ? "Draw something!" : "Saved locally"
        } catch {
            saveStatus = "Couldn't load drawing"
        }
    }

    private func persistDrawing() {
        do {
            let data = try JSONEncoder().encode(strokes)
            UserDefaults.standard.set(data, forKey: storageKey)
            saveStatus = "Saved locally"
        } catch {
            saveStatus = "Save failed"
        }
    }
}
