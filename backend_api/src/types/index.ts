// User types
export enum UserRole {
  USER = 'user',
  DRIVER = 'driver',
  ADMIN = 'admin',
}

export interface User {
  id: string;
  email?: string;
  phone?: string;
  displayName: string;
  photoURL?: string;
  role: UserRole;
  kycStatus: 'pending' | 'approved' | 'rejected';
  kycDocuments?: KycDocument[];
  rating?: number;
  totalReviews?: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface KycDocument {
  type: 'id_card' | 'drivers_license' | 'vehicle_registration';
  url: string;
  verified: boolean;
  submittedAt: Date;
}

// Trip types
export interface Trip {
  id: string;
  driverId: string;
  driverName: string;
  origin: Location;
  destination: Location;
  departureTime: Date;
  arrivalTime: Date;
  availableSeats: number;
  totalSeats: number;
  pricePerSeat: number;
  vehicleInfo: VehicleInfo;
  status: 'scheduled' | 'active' | 'in_progress' | 'completed' | 'cancelled';
  bookingIds: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Location {
  address: string;
  city: string;
  country: string;
  latitude?: number;
  longitude?: number;
}

export interface VehicleInfo {
  make: string;
  model: string;
  year: number;
  color: string;
  licensePlate: string;
  imageUrl?: string;
}

// Booking types
export enum BookingStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed',
}

export enum PaymentStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

export enum PaymentMethod {
  ORANGE_MONEY = 'orange_money',
  STRIPE = 'stripe',
  WAVE = 'wave',
  CASH = 'cash',
}

export interface Booking {
  id: string;
  tripId: string;
  passengerId: string;
  passengerName?: string;
  seats: number;
  totalAmount: number;
  totalPrice?: number;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  paymentMethod: PaymentMethod;
  paymentId?: string;
  pickupLocation?: Location;
  dropoffLocation?: Location;
  createdAt: Date;
  updatedAt: Date;
}

// Payment types
export interface Payment {
  id: string;
  bookingId: string;
  amount: number;
  method: PaymentMethod;
  status: PaymentStatus;
  providerRef?: string;
  transactionId?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Review types
export interface Review {
  id: string;
  bookingId: string;
  reviewerId: string;
  reviewerName: string;
  revieweeId: string;
  revieweeName: string;
  rating: number; // 1-5
  comment?: string;
  type: 'passenger_to_driver' | 'driver_to_passenger';
  createdAt: Date;
}

// API Response types
export interface ApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
  pagination?: PaginationInfo;
}

export interface PaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

// Auth types
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface PhoneAuthRequest {
  phone: string;
}

export interface PhoneVerifyRequest {
  phone: string;
  code: string;
}

export interface EmailRegisterRequest {
  email: string;
  password: string;
  displayName: string;
}

export interface EmailLoginRequest {
  email: string;
  password: string;
}

// Error types
export interface FieldError {
  field: string;
  message: string;
}
