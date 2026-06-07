//
//  OnboardingView.swift
//  CoinControl
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: Settings
    @State private var selectedCurrency = "৳"
    @State private var step = 1

    let currencies = ["৳", "$", "€", "£", "¥", "₹"]

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            if step == 1 {
                currencyStep
            } else {
                setupStep
            }

            Spacer()

            Button(action: {
                if step == 1 {
                    settings.currencySymbol = selectedCurrency
                    step = 2
                } else {
                    settings.hasCompletedOnboarding = true
                }
            }) {
                Text(step == 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }

    private var currencyStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "banknote.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Welcome to CoinControl")
                .font(.title)
                .fontWeight(.bold)

            Text("Choose your preferred currency symbol to get started.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Picker("Currency", selection: $selectedCurrency) {
                ForEach(currencies, id: \.self) { symbol in
                    Text(symbol).tag(symbol)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
        }
    }

    private var setupStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Ready to Go!")
                .font(.title)
                .fontWeight(.bold)

            Text("We've set up some default categories and accounts for you. You can customize them later in settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "list.bullet.indent")
                    Text("Standard Categories")
                }
                HStack {
                    Image(systemName: "creditcard.fill")
                    Text("Default Accounts (Cash, Bank, Card)")
                }
            }
            .font(.subheadline)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

#if DEBUG
    #Preview {
        OnboardingView()
            .environmentObject(Settings())
    }
#endif
