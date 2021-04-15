//
//  ContentView.swift
//  ClockWheel
//
//  Created by Vlad Iacob on 4/9/21.
//

import SwiftUI

struct LineCap: View {
    let image: String
    let imageColor: Color
    @Binding var correctionAngle: Double
    
    var body: some View {
        Image(systemName: image)
            .foregroundColor(imageColor)
            .opacity(0.6)
            .rotationEffect(.degrees(90 - correctionAngle))
    }
}

extension Color {
    static let systemGray = Color(.sRGB, red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 1)
    static let systemGray3 = Color(.sRGB, red: 72 / 255, green: 72 / 255, blue: 73 / 255, opacity: 1)
    static let systemGray5 = Color(.sRGB, red: 44 / 255, green: 44 / 255, blue: 46 / 255, opacity: 1)
    static let systemGray6 = Color(.sRGB, red: 28 / 255, green: 28 / 255, blue: 30 / 255, opacity: 1)
}

struct PaymentRing: View {
    @State var frameSize = UIScreen.main.bounds.width - 100
    @State var currentStart: CGFloat = 0 {
        didSet {
            checkForIntervalRequirements()
        }
    }
    @State var currentEnd: CGFloat = 0.25 {
        didSet {
            checkForIntervalRequirements()
        }
    }
    @State var endValue: Double = 90
    @State var startValue: Double = 0
    @State var isIntervalSatisfied = false
    var progressCircleColor: Color {
        isIntervalSatisfied ? .systemGray5 : .orange
    }
    var iconColor: Color {
        isIntervalSatisfied ? .systemGray : .black
    }
    var progressDashColor: Color {
        isIntervalSatisfied ? .systemGray6 : .systemGray3
    }
    var timeInterval: String {
        computeTimeInterval(for: currentEnd - currentStart)
    }
    var caption: String {
        isIntervalSatisfied ? "This interval meets your sleeping schedule" : "This interval does not meet your goal schedule"
    }
    
    @State var isStartInFront: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Color.systemGray5
                    .frame(width: UIScreen.main.bounds.width - 30, height: 550, alignment: .center)
                    .cornerRadius(20)
                Circle()
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 50, lineCap: .butt, lineJoin: .round))
                    .frame(width: frameSize, height: frameSize)
                Circle()
                    .trim(from: currentStart, to: currentEnd)
                    .stroke(progressCircleColor, style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                    .frame(width: frameSize, height: frameSize)
                    .rotationEffect(.init(degrees: -90))
                Circle()
                    .trim(from: currentStart, to: currentEnd)
                    .stroke(progressDashColor.opacity(0.5), style: StrokeStyle(lineWidth: 13, lineJoin: .round, dash: [2, 3]))
                    .frame(width: frameSize, height: frameSize)
                    .rotationEffect(.init(degrees: -90))
                Circle()
                    .trim(from: currentStart, to: currentEnd)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 50, lineCap: .round))
                    .opacity(0.01)
                    .frame(width: frameSize, height: frameSize)
                    .gesture(DragGesture().onChanged(onDragArc(value:)))
                    .rotationEffect(.init(degrees: -90))
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(progressCircleColor)
                    .overlay(LineCap(image: "bed.double.fill", imageColor: iconColor, correctionAngle: $startValue))
                    .offset(x: frameSize/2)
                    .rotationEffect(.init(degrees: startValue))
                    .gesture(DragGesture().onChanged(onDragStart(value:)))
                    .rotationEffect(.init(degrees: -90))
                    .zIndex(isStartInFront ? 1 : 0)
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(progressCircleColor)
                    .overlay(LineCap(image: "bell.fill", imageColor: iconColor, correctionAngle: $endValue))
                    .offset(x: frameSize/2)
                    .rotationEffect(.init(degrees: endValue))
                    .gesture(DragGesture().onChanged(onDragEnd(value:)))
                    .rotationEffect(.init(degrees: -90))
            }
            
            VStack {
                Text(timeInterval)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                HStack {
                    if !isIntervalSatisfied {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 13))
                    }
                    Text(caption)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .padding(.top, 3)
                        .lineLimit(2)
                }.padding(.horizontal, 20)
            }.offset(y: -90)
        }
    }
        
    func checkForIntervalRequirements() {
        let interval = currentEnd - currentStart
        withAnimation {
            isIntervalSatisfied = interval > 0.3
        }
    }
    
    func computeTimeInterval(for interval: CGFloat) -> String {
        let minutesInterval = Int((currentEnd - currentStart) * 1440) * 60
        
        let dateComponents = DateComponentsFormatter()
        dateComponents.unitsStyle = .short
        dateComponents.allowedUnits = [.hour, .minute]

        return dateComponents.string(from: TimeInterval(minutesInterval)) ?? ""
    }
    
    func onDragArc(value: DragGesture.Value) {
        let radianVector = CGVector(dx: value.location.x, dy: value.location.y)
        let radian = atan2(radianVector.dy - frameSize / 2, radianVector.dx - frameSize / 2)
        var angleValue = radian * 180 / .pi

        if angleValue < 0 {
            angleValue = 360 + angleValue
        }

        generateSelectionFeedback()
        
        let current = angleValue / 360
        
        let arcLength = (currentEnd - currentStart) / 2
        
        self.currentStart = current - arcLength
        self.currentEnd = current + arcLength
        
        self.startValue = Double(self.currentStart * 360)
        self.endValue = Double(self.currentEnd * 360)
    }
    
    func onDragStart(value: DragGesture.Value) {
        let radianVector = CGVector(dx: value.location.x, dy: value.location.y)
        let radian = atan2(radianVector.dy - 20, radianVector.dx - 20)
        var angleValue = radian * 180 / .pi
        
        if angleValue < 0 {
            angleValue = 360 + angleValue
        }
        
        generateSelectionFeedback()
    
        withAnimation(Animation.linear(duration: .leastNonzeroMagnitude)) {
            let current = angleValue / 360
            
            guard current < currentEnd else {
                isStartInFront = true
                self.currentStart = current
                self.startValue = Double(self.currentStart * 360)

                self.currentEnd = self.currentStart
                self.endValue = Double((self.currentStart) * 360)
                return
            }

            isStartInFront = false
            self.currentStart = current
            self.startValue = Double(angleValue)
        }
    }
    
    func onDragEnd(value: DragGesture.Value) {
        let radianVector = CGVector(dx: value.location.x, dy: value.location.y)
        let radian = atan2(radianVector.dy - 20, radianVector.dx - 20)
        var angleValue = radian * 180 / .pi
        
        if angleValue < 0 {
            angleValue = 360 + angleValue
        }
        
        generateSelectionFeedback()
        
        withAnimation(Animation.linear(duration: .leastNonzeroMagnitude)) {
            let current = angleValue / 360
            
            guard current < 1 else { return }
            
            self.currentEnd = current
            isStartInFront = false
            
            guard Double(angleValue) > startValue else {
                self.endValue = Double(angleValue)
                self.currentStart = current
                self.startValue = Double(angleValue)
                return
            }
            
            self.endValue = Double(angleValue)
        }
    }
    
    func generateSelectionFeedback() {
        let feedBackGenerator = UISelectionFeedbackGenerator()
        feedBackGenerator.selectionChanged()
    }
}

struct PaymentRing_Previews: PreviewProvider {
    static var previews: some View {
        PaymentRing().preferredColorScheme(.dark)
    }
}
