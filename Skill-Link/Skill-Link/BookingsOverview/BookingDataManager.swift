//
//  BookingDataManager.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 28/12/2025.
//

import Foundation

class BookingDataManager {
    static let shared = BookingDataManager()
    private init() {}
    
    private var allBookings: [Booking] = [
        // PENDING: Waiting for provider acceptance
        Booking(
            service: BookedService(
                state: .Pending,
                title: "Light Replacement",
                date: Date.now,
                time: "10:00 - 11:00 AM",
                location: "Manama, Bahrain",
                totalPrice: 13.0
            ),
            user: UserProfile(
                name: "Jaffar",
                skills: [],
                brief: "",
                contact: "+973 1234 5678"
            ),
            provider: UserProfile(
                name: "Modeer",
                skills: ["Electrician", "Stock Analyst"],
                brief: "Microsoft Certified Electrician with 5 years experience!",
                contact: "+973 3232 4545"
            )
        ),
        
        // UPCOMING: Accepted and scheduled for future
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "Home Cleaning Service",
                date: Date.now.addingTimeInterval(86400 * 2), // 2 days from now
                time: "2:00 - 4:00 PM",
                location: "Riffa, Bahrain",
                totalPrice: 28.5
            ),
            user: UserProfile(
                name: "Sarah Ahmed",
                skills: [],
                brief: "",
                contact: "+973 9876 5432"
            ),
            provider: UserProfile(
                name: "CleanPro Co.",
                skills: ["Deep Cleaning", "Carpet Cleaning", "Window Cleaning"],
                brief: "Professional cleaning team with eco-friendly products",
                contact: "+973 1717 0000"
            )
        ),
        
        // UPCOMING: Another upcoming booking
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "AC Repair & Maintenance",
                date: Date.now.addingTimeInterval(86400 * 1), // Tomorrow
                time: "9:00 - 11:00 AM",
                location: "Muharraq, Bahrain",
                totalPrice: 75.0
            ),
            user: UserProfile(
                name: "Ali Hassan",
                skills: [],
                brief: "",
                contact: "+973 3344 5566"
            ),
            provider: UserProfile(
                name: "CoolAir Solutions",
                skills: ["AC Repair", "Maintenance", "Installation"],
                brief: "Certified HVAC technicians with 10+ years experience",
                contact: "+973 1777 8888"
            )
        ),
        
        // COMPLETED: Past successful service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Plumbing Fix - Leaking Pipe",
                date: Date.now.addingTimeInterval(-86400 * 3), // 3 days ago
                time: "11:00 AM - 12:30 PM",
                location: "Seef, Bahrain",
                totalPrice: 42.0
            ),
            user: UserProfile(
                name: "Fatima Khalid",
                skills: [],
                brief: "",
                contact: "+973 9988 7766"
            ),
            provider: UserProfile(
                name: "QuickFix Plumbers",
                skills: ["Emergency Plumbing", "Pipe Repair", "Installation"],
                brief: "24/7 emergency plumbing services",
                contact: "+973 1600 1234"
            )
        ),
        
        // COMPLETED: Another completed service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Monthly Car Wash & Polish",
                date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
                time: "3:00 - 4:00 PM",
                location: "Budaiya, Bahrain",
                totalPrice: 15.0
            ),
            user: UserProfile(
                name: "Khalid Ali",
                skills: [],
                brief: "",
                contact: "+973 4455 6677"
            ),
            provider: UserProfile(
                name: "ShinyCars Detailing",
                skills: ["Car Wash", "Polishing", "Interior Cleaning"],
                brief: "Premium car care with ceramic coating options",
                contact: "+973 3666 9999"
            )
        ),
        
        // CANCELED: User canceled booking
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Furniture Assembly",
                date: Date.now.addingTimeInterval(86400 * 5), // Would have been 5 days from now
                time: "1:00 - 3:00 PM",
                location: "Isa Town, Bahrain",
                totalPrice: 35.0
            ),
            user: UserProfile(
                name: "Maryam Abdul",
                skills: [],
                brief: "",
                contact: "+973 2233 4455"
            ),
            provider: UserProfile(
                name: "Home Assembly Pro",
                skills: ["Furniture Assembly", "Mounting", "Installation"],
                brief: "Expert furniture assemblers for all brands",
                contact: "+973 1888 2222"
            )
        ),
        
        // CANCELED: Provider canceled
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Gardening & Landscaping",
                date: Date.now.addingTimeInterval(86400 * 4), // Would have been 4 days from now
                time: "8:00 AM - 12:00 PM",
                location: "Hamala, Bahrain",
                totalPrice: 120.0
            ),
            user: UserProfile(
                name: "Omar Farooq",
                skills: [],
                brief: "",
                contact: "+973 6677 8899"
            ),
            provider: UserProfile(
                name: "GreenThumb Gardens",
                skills: ["Landscaping", "Gardening", "Irrigation"],
                brief: "Complete garden design and maintenance",
                contact: "+973 1777 3333"
            )
        ),
        
        // PENDING: Another pending request
        Booking(
            service: BookedService(
                state: .Pending,
                title: "WiFi Network Setup",
                date: Date.now.addingTimeInterval(86400 * 3), // 3 days from now
                time: "4:00 - 5:30 PM",
                location: "Juffair, Bahrain",
                totalPrice: 25.0
            ),
            user: UserProfile(
                name: "Layla Mohammed",
                skills: [],
                brief: "",
                contact: "+973 5544 3322"
            ),
            provider: UserProfile(
                name: "TechConnect Solutions",
                skills: ["Network Setup", "WiFi Optimization", "IT Support"],
                brief: "Certified network engineers for home and business",
                contact: "+973 1700 5555"
            )
        ),
        Booking(
            service: BookedService(
                state: .Pending,
                title: "Light Replacement",
                date: Date.now,
                time: "10:00 - 11:00 AM",
                location: "Manama, Bahrain",
                totalPrice: 13.0
            ),
            user: UserProfile(
                name: "Jaffar",
                skills: [],
                brief: "",
                contact: "+973 1234 5678"
            ),
            provider: UserProfile(
                name: "Modeer",
                skills: ["Electrician", "Stock Analyst"],
                brief: "Microsoft Certified Electrician with 5 years experience!",
                contact: "+973 3232 4545"
            )
        ),
        
        // UPCOMING: Accepted and scheduled for future
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "Home Cleaning Service",
                date: Date.now.addingTimeInterval(86400 * 2), // 2 days from now
                time: "2:00 - 4:00 PM",
                location: "Riffa, Bahrain",
                totalPrice: 28.5
            ),
            user: UserProfile(
                name: "Sarah Ahmed",
                skills: [],
                brief: "",
                contact: "+973 9876 5432"
            ),
            provider: UserProfile(
                name: "CleanPro Co.",
                skills: ["Deep Cleaning", "Carpet Cleaning", "Window Cleaning"],
                brief: "Professional cleaning team with eco-friendly products",
                contact: "+973 1717 0000"
            )
        ),
        
        // UPCOMING: Another upcoming booking
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "AC Repair & Maintenance",
                date: Date.now.addingTimeInterval(86400 * 1), // Tomorrow
                time: "9:00 - 11:00 AM",
                location: "Muharraq, Bahrain",
                totalPrice: 75.0
            ),
            user: UserProfile(
                name: "Ali Hassan",
                skills: [],
                brief: "",
                contact: "+973 3344 5566"
            ),
            provider: UserProfile(
                name: "CoolAir Solutions",
                skills: ["AC Repair", "Maintenance", "Installation"],
                brief: "Certified HVAC technicians with 10+ years experience",
                contact: "+973 1777 8888"
            )
        ),
        
        // COMPLETED: Past successful service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Plumbing Fix - Leaking Pipe",
                date: Date.now.addingTimeInterval(-86400 * 3), // 3 days ago
                time: "11:00 AM - 12:30 PM",
                location: "Seef, Bahrain",
                totalPrice: 42.0
            ),
            user: UserProfile(
                name: "Fatima Khalid",
                skills: [],
                brief: "",
                contact: "+973 9988 7766"
            ),
            provider: UserProfile(
                name: "QuickFix Plumbers",
                skills: ["Emergency Plumbing", "Pipe Repair", "Installation"],
                brief: "24/7 emergency plumbing services",
                contact: "+973 1600 1234"
            )
        ),
        
        // COMPLETED: Another completed service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Monthly Car Wash & Polish",
                date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
                time: "3:00 - 4:00 PM",
                location: "Budaiya, Bahrain",
                totalPrice: 15.0
            ),
            user: UserProfile(
                name: "Khalid Ali",
                skills: [],
                brief: "",
                contact: "+973 4455 6677"
            ),
            provider: UserProfile(
                name: "ShinyCars Detailing",
                skills: ["Car Wash", "Polishing", "Interior Cleaning"],
                brief: "Premium car care with ceramic coating options",
                contact: "+973 3666 9999"
            )
        ),
        
        // CANCELED: User canceled booking
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Furniture Assembly",
                date: Date.now.addingTimeInterval(86400 * 5), // Would have been 5 days from now
                time: "1:00 - 3:00 PM",
                location: "Isa Town, Bahrain",
                totalPrice: 35.0
            ),
            user: UserProfile(
                name: "Maryam Abdul",
                skills: [],
                brief: "",
                contact: "+973 2233 4455"
            ),
            provider: UserProfile(
                name: "Home Assembly Pro",
                skills: ["Furniture Assembly", "Mounting", "Installation"],
                brief: "Expert furniture assemblers for all brands",
                contact: "+973 1888 2222"
            )
        ),
        
        // CANCELED: Provider canceled
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Gardening & Landscaping",
                date: Date.now.addingTimeInterval(86400 * 4), // Would have been 4 days from now
                time: "8:00 AM - 12:00 PM",
                location: "Hamala, Bahrain",
                totalPrice: 120.0
            ),
            user: UserProfile(
                name: "Omar Farooq",
                skills: [],
                brief: "",
                contact: "+973 6677 8899"
            ),
            provider: UserProfile(
                name: "GreenThumb Gardens",
                skills: ["Landscaping", "Gardening", "Irrigation"],
                brief: "Complete garden design and maintenance",
                contact: "+973 1777 3333"
            )
        ),
        
        // PENDING: Another pending request
        Booking(
            service: BookedService(
                state: .Pending,
                title: "WiFi Network Setup",
                date: Date.now.addingTimeInterval(86400 * 3), // 3 days from now
                time: "4:00 - 5:30 PM",
                location: "Juffair, Bahrain",
                totalPrice: 25.0
            ),
            user: UserProfile(
                name: "Layla Mohammed",
                skills: [],
                brief: "",
                contact: "+973 5544 3322"
            ),
            provider: UserProfile(
                name: "TechConnect Solutions",
                skills: ["Network Setup", "WiFi Optimization", "IT Support"],
                brief: "Certified network engineers for home and business",
                contact: "+973 1700 5555"
            )
        ),
        Booking(
            service: BookedService(
                state: .Pending,
                title: "Light Replacement",
                date: Date.now,
                time: "10:00 - 11:00 AM",
                location: "Manama, Bahrain",
                totalPrice: 13.0
            ),
            user: UserProfile(
                name: "Jaffar",
                skills: [],
                brief: "",
                contact: "+973 1234 5678"
            ),
            provider: UserProfile(
                name: "Modeer",
                skills: ["Electrician", "Stock Analyst"],
                brief: "Microsoft Certified Electrician with 5 years experience!",
                contact: "+973 3232 4545"
            )
        ),
        
        // UPCOMING: Accepted and scheduled for future
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "Home Cleaning Service",
                date: Date.now.addingTimeInterval(86400 * 2), // 2 days from now
                time: "2:00 - 4:00 PM",
                location: "Riffa, Bahrain",
                totalPrice: 28.5
            ),
            user: UserProfile(
                name: "Sarah Ahmed",
                skills: [],
                brief: "",
                contact: "+973 9876 5432"
            ),
            provider: UserProfile(
                name: "CleanPro Co.",
                skills: ["Deep Cleaning", "Carpet Cleaning", "Window Cleaning"],
                brief: "Professional cleaning team with eco-friendly products",
                contact: "+973 1717 0000"
            )
        ),
        
        // UPCOMING: Another upcoming booking
        Booking(
            service: BookedService(
                state: .Upcoming,
                title: "AC Repair & Maintenance",
                date: Date.now.addingTimeInterval(86400 * 1), // Tomorrow
                time: "9:00 - 11:00 AM",
                location: "Muharraq, Bahrain",
                totalPrice: 75.0
            ),
            user: UserProfile(
                name: "Ali Hassan",
                skills: [],
                brief: "",
                contact: "+973 3344 5566"
            ),
            provider: UserProfile(
                name: "CoolAir Solutions",
                skills: ["AC Repair", "Maintenance", "Installation"],
                brief: "Certified HVAC technicians with 10+ years experience",
                contact: "+973 1777 8888"
            )
        ),
        
        // COMPLETED: Past successful service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Plumbing Fix - Leaking Pipe",
                date: Date.now.addingTimeInterval(-86400 * 3), // 3 days ago
                time: "11:00 AM - 12:30 PM",
                location: "Seef, Bahrain",
                totalPrice: 42.0
            ),
            user: UserProfile(
                name: "Fatima Khalid",
                skills: [],
                brief: "",
                contact: "+973 9988 7766"
            ),
            provider: UserProfile(
                name: "QuickFix Plumbers",
                skills: ["Emergency Plumbing", "Pipe Repair", "Installation"],
                brief: "24/7 emergency plumbing services",
                contact: "+973 1600 1234"
            )
        ),
        
        // COMPLETED: Another completed service
        Booking(
            service: BookedService(
                state: .Completed,
                title: "Monthly Car Wash & Polish",
                date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
                time: "3:00 - 4:00 PM",
                location: "Budaiya, Bahrain",
                totalPrice: 15.0
            ),
            user: UserProfile(
                name: "Khalid Ali",
                skills: [],
                brief: "",
                contact: "+973 4455 6677"
            ),
            provider: UserProfile(
                name: "ShinyCars Detailing",
                skills: ["Car Wash", "Polishing", "Interior Cleaning"],
                brief: "Premium car care with ceramic coating options",
                contact: "+973 3666 9999"
            )
        ),
        
        // CANCELED: User canceled booking
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Furniture Assembly",
                date: Date.now.addingTimeInterval(86400 * 5), // Would have been 5 days from now
                time: "1:00 - 3:00 PM",
                location: "Isa Town, Bahrain",
                totalPrice: 35.0
            ),
            user: UserProfile(
                name: "Maryam Abdul",
                skills: [],
                brief: "",
                contact: "+973 2233 4455"
            ),
            provider: UserProfile(
                name: "Home Assembly Pro",
                skills: ["Furniture Assembly", "Mounting", "Installation"],
                brief: "Expert furniture assemblers for all brands",
                contact: "+973 1888 2222"
            )
        ),
        
        // CANCELED: Provider canceled
        Booking(
            service: BookedService(
                state: .Canceled,
                title: "Gardening & Landscaping",
                date: Date.now.addingTimeInterval(86400 * 4), // Would have been 4 days from now
                time: "8:00 AM - 12:00 PM",
                location: "Hamala, Bahrain",
                totalPrice: 120.0
            ),
            user: UserProfile(
                name: "Omar Farooq",
                skills: [],
                brief: "",
                contact: "+973 6677 8899"
            ),
            provider: UserProfile(
                name: "GreenThumb Gardens",
                skills: ["Landscaping", "Gardening", "Irrigation"],
                brief: "Complete garden design and maintenance",
                contact: "+973 1777 3333"
            )
        ),
        
        // PENDING: Another pending request
        Booking(
            service: BookedService(
                state: .Pending,
                title: "WiFi Network Setup",
                date: Date.now.addingTimeInterval(86400 * 3), // 3 days from now
                time: "4:00 - 5:30 PM",
                location: "Juffair, Bahrain",
                totalPrice: 25.0
            ),
            user: UserProfile(
                name: "Layla Mohammed",
                skills: [],
                brief: "",
                contact: "+973 5544 3322"
            ),
            provider: UserProfile(
                name: "TechConnect Solutions",
                skills: ["Network Setup", "WiFi Optimization", "IT Support"],
                brief: "Certified network engineers for home and business",
                contact: "+973 1700 5555"
            )
        )
    ] // Your initial data here
    
    // CRUD Operations
    func getAllBookings() -> [Booking] {
        return allBookings
    }
    
    func getBookings(for state: BookedServiceStatus) -> [Booking] {
        return allBookings.filter { $0.service.state == state }
    }
    
    func updateBookingState(serviceId: UUID, newState: BookedServiceStatus) {
        if let index = allBookings.firstIndex(where: { $0.service.id == serviceId }) {
            // Create a mutable copy
            var booking = allBookings[index]
            booking.service.state = newState
            allBookings[index] = booking
            
            // Notify observers (tabs) of the change
            NotificationCenter.default.post(
                name: .bookingDataDidChange,
                object: nil
            )
        }
    }
    
    // Add initial data
    func setInitialData(_ bookings: [Booking]) {
        self.allBookings = bookings
    }
}

// Notification name
extension Notification.Name {
    static let bookingDataDidChange = Notification.Name("bookingDataDidChange")
}
