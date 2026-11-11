import SwiftUI

struct LockScreenView: View {
    let date: Date
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.025, green: 0.055, blue: 0.16),
                    Color(red: 0.075, green: 0.17, blue: 0.34),
                    Color(red: 0.19, green: 0.09, blue: 0.31)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.cyan.opacity(0.22))
                .frame(width: 300, height: 300)
                .blur(radius: 75)
                .offset(x: 150, y: -210)

            Circle()
                .fill(Color.purple.opacity(0.24))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: -150, y: 240)

            Rectangle()
                .fill(.black.opacity(0.12))

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("LIL-OS")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .tracking(2.2)
                        Text("PERSONAL DESKTOP")
                            .font(.system(size: 8, weight: .semibold))
                            .tracking(1.8)
                            .foregroundStyle(.white.opacity(0.58))
                    }

                    Spacer()

                    HStack(spacing: 9) {
                        Image(systemName: "wifi")
                        Image(systemName: "battery.100percent")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                }
                .foregroundStyle(.white)
                .padding(.top, 62)

                Spacer(minLength: 26)

                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.78))
                    .padding(.bottom, 14)

                Text(date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 76, weight: .light, design: .rounded))
                    .tracking(-4)
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.top, 3)

                Spacer(minLength: 32)

                HStack(spacing: 13) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.cyan)
                        .frame(width: 42, height: 42)
                        .background(.white.opacity(0.11), in: RoundedRectangle(cornerRadius: 13))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Your Lil-OS desktop is ready.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.68))
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }

                Spacer(minLength: 34)

                VStack(spacing: 13) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.75))

                    Button(action: onUnlock) {
                        HStack(spacing: 9) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Unlock Lil-OS")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(Color(red: 0.07, green: 0.10, blue: 0.18))
                        .frame(maxWidth: .infinity)
                        .frame(height: 51)
                        .background(.white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the Lil-OS desktop")

                    Text("Swipe up to enter your desktop")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.62))
                }
                .padding(.bottom, 34)
            }
            .padding(.horizontal, 25)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    if value.translation.height < -45 {
                        onUnlock()
                    }
                }
        )
    }
}
