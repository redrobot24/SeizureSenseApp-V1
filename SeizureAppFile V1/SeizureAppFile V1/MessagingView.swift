//
//  MessagingView.swift
//  Maren-Content View
//
//  Created by Maren McCrossan on 11/12/25.
//

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
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 56))
                            .foregroundStyle(.secondary)
                        Text("No contacts yet")
                            .font(.title3)
                            .bold()
                        Text("Tap the button below to add your first contact.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add Contact", systemImage: "plus.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Contacts list
                    List {
                        ForEach(model.contacts) { contact in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(Text(initials(for: contact.firstName)).bold())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.firstName)
                                        .font(.headline)
                                    Text(formatPhone(contact.phoneNumber))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: model.delete)
                    }
                }
            }
            .navigationTitle("Messaging")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Messaging")
                        .font(.headline)
                        .bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Contact")
                }
            }
            // Add-contact sheet with a small form
            .sheet(isPresented: $showingAdd, onDismiss: resetForm) {
                NavigationStack {
                    Form {
                        Section("Contact Info") {
                            TextField("First Name", text: $firstName)
                                .textContentType(.givenName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(true)
                                
                            
                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                        }
                    }
                    .navigationTitle("New Contact")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // Centered, smaller title
                        ToolbarItem(placement: .principal) {
                            Text("New Contact")
                                .font(.subheadline)
                                .bold()
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAdd = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                addContactValidated()
                            }
                            .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                      phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .alert("Invalid Contact", isPresented: $showValidationAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(validationMessage)
                    }
                }
            }
        }
    }
    
    private func addContactValidated() {
        // Simple validation: allow digits and common phone punctuation
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
        // Lightweight formatting: collapse extra spaces
        phone.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

#Preview {
    MessagingView()
}
