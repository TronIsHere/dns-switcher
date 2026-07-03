import SwiftUI

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var dns = DNSController.shared

    @State private var showingProfileEditor = false
    @State private var editingProfile: DNSProfile?

    private var l10n: L10n { settings.l10n }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    networkCard
                    currentDNSCard
                    presetSection
                    savedProfilesSection

                    if settings.selectedPreset == .custom, settings.selectedProfile == nil {
                        customDNSCard
                    }

                    actionButtons

                    if let statusMessage = dns.statusMessage {
                        statusBanner(statusMessage)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 22)
            }
        }
        .frame(width: 440)
        .background(
            LinearGradient(
                colors: [AppTheme.canvas, AppTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .environment(\.layoutDirection, settings.language.layoutDirection)
        .onAppear { dns.loadServices() }
        .sheet(isPresented: $showingProfileEditor) {
            ProfileEditorSheet(
                profile: editingProfile,
                l10n: l10n,
                onSave: { profile in
                    if settings.savedProfiles.contains(where: { $0.id == profile.id }) {
                        settings.updateProfile(profile)
                    } else {
                        settings.addProfile(profile)
                        settings.selection = .profile(profile.id)
                    }
                    showingProfileEditor = false
                    editingProfile = nil
                },
                onDelete: { id in
                    settings.deleteProfile(id: id)
                    showingProfileEditor = false
                    editingProfile = nil
                },
                onCancel: {
                    showingProfileEditor = false
                    editingProfile = nil
                }
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.softAccent.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: "network")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.softAccent)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(l10n.appTitle)
                    .font(.system(.title3, design: .rounded).weight(.semibold))

                Text(l10n.appSubtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            languageMenu
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
    }

    private var languageMenu: some View {
        Menu {
            ForEach(AppLanguage.allCases) { lang in
                Button {
                    settings.language = lang
                } label: {
                    if settings.language == lang {
                        Label(lang.displayName, systemImage: "checkmark")
                    } else {
                        Text(lang.displayName)
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "globe")
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(AppTheme.muted)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(AppTheme.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(AppTheme.hairline, lineWidth: 1))
        }
        .menuStyle(.button)
        .fixedSize()
        .help(l10n.languageLabel)
    }

    // MARK: - Cards

    private var networkCard: some View {
        LightCard {
            CardHeader(title: l10n.network, icon: "wifi")

            Picker(l10n.networkPicker, selection: $dns.selectedService) {
                ForEach(dns.services, id: \.self) { service in
                    Text(service).tag(service)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var currentDNSCard: some View {
        LightCard {
            HStack {
                CardHeader(title: l10n.currentDNS, icon: "server.rack")
                Spacer()
                StatusPill(status: dns.dnsStatus, l10n: l10n)
            }

            if dns.currentDNS.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                    Text(l10n.automaticDHCP)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(dns.currentDNS, id: \.self) { server in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppTheme.softAccent)
                                .frame(width: 5, height: 5)
                            Text(server)
                                .font(.system(.subheadline, design: .monospaced))
                        }
                    }
                }
            }
        }
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardHeader(title: l10n.dnsPreset, icon: "square.grid.2x2")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(DNSPreset.allCases) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: settings.selection == .preset(preset),
                        isMatched: dns.matchedPreset == preset,
                        language: settings.language,
                        l10n: l10n
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            settings.selection = .preset(preset)
                        }
                    }
                }
            }
        }
    }

    private var savedProfilesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                CardHeader(title: l10n.savedProfiles, icon: "bookmark.fill")
                Spacer()
                Button {
                    editingProfile = nil
                    showingProfileEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.body.weight(.medium))
                        .foregroundStyle(AppTheme.softAccent)
                }
                .buttonStyle(.plain)
                .help(l10n.addProfile)
            }

            if settings.savedProfiles.isEmpty {
                Text(l10n.noSavedProfiles)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
                    .padding(.horizontal, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(settings.savedProfiles) { profile in
                        ProfileCard(
                            profile: profile,
                            isSelected: settings.selection == .profile(profile.id),
                            isMatched: dns.matchedProfile?.id == profile.id,
                            l10n: l10n,
                            onSelect: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    settings.selection = .profile(profile.id)
                                }
                            },
                            onEdit: {
                                editingProfile = profile
                                showingProfileEditor = true
                            },
                            onDelete: {
                                settings.deleteProfile(id: profile.id)
                            }
                        )
                    }
                }
            }
        }
    }

    private var customDNSCard: some View {
        LightCard {
            CardHeader(title: l10n.customDNS, icon: "pencil.and.list.clipboard")

            VStack(spacing: 12) {
                DNSField(
                    label: l10n.primaryServer,
                    placeholder: "1.1.1.1",
                    text: $settings.customPrimaryDNS
                )

                DNSField(
                    label: "\(l10n.secondaryServer) (\(l10n.optional))",
                    placeholder: "1.0.0.1",
                    text: $settings.customSecondaryDNS
                )

                if dns.canApply {
                    Button {
                        editingProfile = DNSProfile(
                            name: "",
                            primaryDNS: settings.customPrimaryDNS,
                            secondaryDNS: settings.customSecondaryDNS
                        )
                        showingProfileEditor = true
                    } label: {
                        Label(l10n.saveAsProfile, systemImage: "bookmark.badge.plus")
                            .font(.caption.weight(.medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button {
                Task { await dns.applyCurrentSelection() }
            } label: {
                HStack(spacing: 8) {
                    if dns.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                    }
                    Text(l10n.applyDNS)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.softAccent)
            .controlSize(.large)
            .disabled(dns.isLoading || dns.selectedService.isEmpty || !dns.canApply)

            Button {
                Task { await dns.resetDNS() }
            } label: {
                Text(l10n.resetAutomatic)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppTheme.muted)
            .controlSize(.large)
            .disabled(dns.isLoading || dns.selectedService.isEmpty)
        }
    }

    private func statusBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: dns.isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundStyle(dns.isError ? .red.opacity(0.8) : .green.opacity(0.8))
            Text(message)
                .font(.footnote)
                .foregroundStyle(dns.isError ? .red.opacity(0.9) : .primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(dns.isError ? Color.red.opacity(0.06) : Color.green.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(dns.isError ? Color.red.opacity(0.12) : Color.green.opacity(0.12), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - Components

private struct LightCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(AppTheme.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

private struct CardHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.softAccent)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
                .textCase(.uppercase)
                .tracking(0.4)
        }
    }
}

private struct StatusPill: View {
    let status: DNSStatus
    let l10n: L10n

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2.weight(.medium))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(color.opacity(0.1), in: Capsule())
        .foregroundStyle(color)
    }

    private var label: String {
        switch status {
        case .automatic: return l10n.statusAutomatic
        case .matched(let preset): return l10n.statusMatched(preset)
        case .matchedProfile(let profile): return l10n.statusMatchedProfile(profile)
        case .other: return l10n.statusOther
        }
    }

    private var color: Color {
        switch status {
        case .automatic: return AppTheme.muted
        case .matched, .matchedProfile: return .green
        case .other: return .orange
        }
    }
}

private struct PresetCard: View {
    let preset: DNSPreset
    let isSelected: Bool
    let isMatched: Bool
    let language: AppLanguage
    let l10n: L10n
    let action: () -> Void

    private var isHighlighted: Bool { isSelected || isMatched }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: preset.icon)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(iconColor)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.softAccent)
                            .padding(4)
                            .background(AppTheme.softAccent.opacity(0.12), in: Circle())
                    } else if isMatched {
                        Text(l10n.statusActive)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1), in: Capsule())
                    }
                }

                Text(preset.name(for: language))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(l10n.presetDescription(preset))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.muted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if preset != .custom {
                    Text(preset.servers.joined(separator: " · "))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isHighlighted ? 1.5 : 1)
            )
            .shadow(color: .black.opacity(isHighlighted ? 0.05 : 0.02), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        if isSelected { return AppTheme.softAccent }
        if isMatched { return .green }
        return AppTheme.muted
    }

    private var backgroundFill: Color {
        if isSelected { return AppTheme.softAccent.opacity(0.06) }
        if isMatched { return Color.green.opacity(0.06) }
        return AppTheme.surface
    }

    private var borderColor: Color {
        if isSelected { return AppTheme.softAccent.opacity(0.35) }
        if isMatched { return Color.green.opacity(0.35) }
        return AppTheme.hairline
    }
}

private struct DNSField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.muted)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(AppTheme.canvas, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(AppTheme.hairline, lineWidth: 1)
                )
        }
    }
}

private struct ProfileCard: View {
    let profile: DNSProfile
    let isSelected: Bool
    let isMatched: Bool
    let l10n: L10n
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var isHighlighted: Bool { isSelected || isMatched }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(profile.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppTheme.softAccent)
                        } else if isMatched {
                            Text(l10n.statusActive)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1), in: Capsule())
                        }
                    }

                    Text(profile.servers.joined(separator: " · "))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label(l10n.editProfile, systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label(l10n.deleteProfile, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundStyle(AppTheme.muted)
                }
                .menuStyle(.button)
                .fixedSize()
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isHighlighted ? 1.5 : 1)
            )
            .shadow(color: .black.opacity(isHighlighted ? 0.05 : 0.02), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var backgroundFill: Color {
        if isSelected { return AppTheme.softAccent.opacity(0.06) }
        if isMatched { return Color.green.opacity(0.06) }
        return AppTheme.surface
    }

    private var borderColor: Color {
        if isSelected { return AppTheme.softAccent.opacity(0.35) }
        if isMatched { return Color.green.opacity(0.35) }
        return AppTheme.hairline
    }
}

private struct ProfileEditorSheet: View {
    let profile: DNSProfile?
    let l10n: L10n
    let onSave: (DNSProfile) -> Void
    let onDelete: (UUID) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var primaryDNS: String = ""
    @State private var secondaryDNS: String = ""
    @State private var errorMessage: String?

    private var isEditing: Bool { profile != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && DNSValidator.isValid(primaryDNS)
            && (secondaryDNS.trimmingCharacters(in: .whitespaces).isEmpty || DNSValidator.isValid(secondaryDNS))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(isEditing ? l10n.editProfile : l10n.addProfile)
                    .font(.headline)
                Spacer()
                Button(l10n.cancel) { onCancel() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(l10n.profileName)
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                    TextField(l10n.profileNamePlaceholder, text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                DNSField(label: l10n.primaryServer, placeholder: "1.1.1.1", text: $primaryDNS)
                DNSField(
                    label: "\(l10n.secondaryServer) (\(l10n.optional))",
                    placeholder: "1.0.0.1",
                    text: $secondaryDNS
                )

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()

            Divider()

            HStack {
                if let profile {
                    Button(l10n.deleteProfile, role: .destructive) {
                        onDelete(profile.id)
                    }
                }

                Spacer()

                Button(l10n.save) {
                    save()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.softAccent)
                .disabled(!canSave)
            }
            .padding()
        }
        .frame(width: 360)
        .onAppear {
            name = profile?.name ?? ""
            primaryDNS = profile?.primaryDNS ?? ""
            secondaryDNS = profile?.secondaryDNS ?? ""
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = l10n.invalidProfileName
            return
        }
        guard DNSValidator.isValid(primaryDNS) else {
            errorMessage = l10n.invalidPrimary
            return
        }
        let secondary = secondaryDNS.trimmingCharacters(in: .whitespaces)
        if !secondary.isEmpty, !DNSValidator.isValid(secondary) {
            errorMessage = l10n.invalidSecondary
            return
        }

        let saved = DNSProfile(
            id: profile?.id ?? UUID(),
            name: trimmedName,
            primaryDNS: primaryDNS.trimmingCharacters(in: .whitespaces),
            secondaryDNS: secondary
        )
        onSave(saved)
    }
}
