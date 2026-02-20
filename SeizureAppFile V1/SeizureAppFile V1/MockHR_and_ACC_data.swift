import SwiftUI

struct Contact: Identifiable, Equatable, Hashable {
    let id = UUID()
    var firstName: String
    var phoneNumber: String
    var lastMessage: String?
}

@Observable
final class MessagingViewModel {
    var contacts: [Contact] = [] // Start empty
    
    func addContact(firstName: String, phone: String) {
        let name = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneTrimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !phoneTrimmed.isEmpty else { return }
        contacts.append(Contact(firstName: name, phoneNumber: phoneTrimmed, lastMessage: nil))
    }
    
    func delete(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
}

struct MessagingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: AppSettings
    
    @State private var model = MessagingViewModel()
    @State private var showingAdd = false
    
    // Fields for the add-contact form
    @State private var firstName = ""
    @State private var phoneNumber = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if model.contacts.isEmpty {
                    // Empty state
                    VStack(spacing: 16 * settings.textScale) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 56 * settings.textScale))
                            .foregroundStyle(.secondary)
                        Text("No contacts yet")
                            .font(.system(size: 18 * settings.textScale, weight: .bold))
                        Text("Tap the button below to add your first contact.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14 * settings.textScale))
                        
                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add Contact", systemImage: "plus.circle.fill")
                                .font(.system(size: 16 * settings.textScale, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4 * settings.textScale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Contacts list
                    List {
                        ForEach(model.contacts) { contact in
                            HStack(spacing: 12 * settings.textScale) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 40 * settings.textScale, height: 40 * settings.textScale)
                                    .overlay(Text(initials(for: contact.firstName))
                                                .font(.system(size: 16 * settings.textScale, weight: .bold)))
                                
                                VStack(alignment: .leading, spacing: 2 * settings.textScale) {
                                    Text(contact.firstName)
                                        .font(.system(size: 16 * settings.textScale, weight: .semibold))
                                    Text(formatPhone(contact.phoneNumber))
                                        .font(.system(size: 14 * settings.textScale))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4 * settings.textScale)
                        }
                        .onDelete(perform: model.delete)
                    }
                }
            }
            .navigationTitle("Messaging")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(preferredScheme(for: settings.theme))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Messaging")
                        .font(.system(size: 18 * settings.textScale, weight: .bold))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18 * settings.textScale))
                    }
                    .accessibilityLabel("Add Contact")
                }
            }
            // Add-contact sheet
            .sheet(isPresented: $showingAdd, onDismiss: resetForm) {
                NavigationStack {
                    Form {
                        Section("Contact Info") {
                            TextField("First Name", text: $firstName)
                                .textContentType(.givenName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(true)
                                .font(.system(size: 16 * settings.textScale))
                            
                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                                .font(.system(size: 16 * settings.textScale))
                        }
                    }
                    .navigationTitle("New Contact")
                    .navigationBarTitleDisplayMode(.inline)
                    .preferredColorScheme(preferredScheme(for: settings.theme))
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("New Contact")
                                .font(.system(size: 16 * settings.textScale, weight: .bold))
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAdd = false }
                                .font(.system(size: 16 * settings.textScale))
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") { addContactValidated() }
                                .font(.system(size: 16 * settings.textScale))
                                .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                          phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .alert("Invalid Contact", isPresented: $showValidationAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(validationMessage)
                            .font(.system(size: 14 * settings.textScale))
                    }
                }
            }
        }
    }
    
    private func addContactValidated() {
        let allowed = CharacterSet(charactersIn: "+- ()0123456789")
        let isValidPhone = phoneNumber.unicodeScalars.allSatisfy { allowed.contains($0) }
        
        guard isValidPhone else {
            validationMessage = "Please enter a valid phone number (digits and +, -, spaces, or parentheses)."
            showValidationAlert = true
            return
        }
        
        model.addContact(firstName: firstName, phone: phoneNumber)
        showingAdd = false
        resetForm()
    }
    
    private func resetForm() {
        firstName = ""
        phoneNumber = ""
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first?.uppercased() }
        return letters.joined()
    }
    
    private func formatPhone(_ phone: String) -> String {
        phone.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    private func preferredScheme(for theme: Theme) -> ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        default: return nil
        }
    }
}

#Preview {
    MessagingView()
        .environmentObject(AppSettings())
}
