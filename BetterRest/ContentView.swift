//
//  ContentView.swift
//  BetterRest
//
//  Created by Joao Leal on 2/13/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = Date.now
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("When do you want to wake up?")
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                
                Text("How many sleep hours would you like?")
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 0...20)
            }.navigationTitle("Better Rest")
                .toolbar{
                    Button("Action") {
                        calculateBedTime()
                    }
                
                    .alert(alertTitle, isPresented: $showingAlert)  {
                        Button("OK") {}
                            
                        } message: {
                            Text(alertMessage)
                        }
                    
                }
        }
    }
    
    
    func calculateBedTime() {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal betime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            
                alertMessage = "Sorry, there was a problem"
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
