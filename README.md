# Nivi - AI Travel Planner ✈️

Nivi is a modern, AI-powered travel planning application built with Flutter. It allows users to discover new destinations, get personalized travel itineraries from a generative AI, save their trips, and even preview locations in a 360° view.

## 🚀 Key Features

Secure Authentication: Full user signup and login flow powered by Supabase Auth.

AI Itinerary Planner: A built-in chat assistant ("Nivi") that connects to the Google Gemini API to generate custom travel plans on demand.

Destination Discovery: Fetches a rich list of travel destinations from a Supabase database.

Search & Filter: Easily find destinations by name, location, or category (Beach, Mountain, City, etc.).

Location-Aware: Greets users with their current city and country using the geolocator package.

Trip Booking:

Book AI-generated itineraries directly from the chat.

Manually book a "mock ticket" for any destination.

All bookings are saved to the user's "My Trips" page.

My Trips: A dedicated screen to view all saved and booked trips, fetched from the user's Supabase profile.

360° Preview: Uses the panorama_viewer package to provide an immersive 360° view of select destinations.

Profile Management: A clean profile page with user details and a secure logout function.

## 🛠️ Tech Stack

Frontend: Flutter

Backend-as-a-Service (BaaS): Supabase

Database: Supabase Postgres for storing destinations and user trips.

Auth: Supabase Authentication for user management.

APIs & Services:

Google Generative AI (Gemini): For the AI chat planner.

Geolocator & Geocoding: To fetch the user's current location.

Key Packages:

supabase_flutter

geolocator

geocoding

http

panorama_viewer
