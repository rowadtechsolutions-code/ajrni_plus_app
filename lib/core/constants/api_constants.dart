class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://slglklsyrbgcsdgruunk.supabase.co',
  );

  static const String apiKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsZ2xrbHN5cmJnY3NkZ3J1dW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzMzM2MjcsImV4cCI6MjA5NjkwOTYyN30.Q96l5nkezgZrrawdfU2QR_wQ3iKeRH-Ue6_ctYV9YwE',
  );
}
