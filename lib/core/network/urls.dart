
const BASE_URL = "https://www.shleeh.com";
const BASE_URL_STAGGING = "http://www.dohfar.com";
const IS_STATGING = false;

// AUTHENTICATION URLS
const RESET_PASSWORD_URL = "/api/Owners/RestPassword";
const LOGIN_URL = "/api/CustomerData/Login";
const PROFILE_URL = "/api/CustomerData/GetOwner";

const Register_URL = "/api/CustomerData/AddOwner";
const CHECK_USER_EXISTED = "/api/Owners/CheckUser";
const SEND_OTP_URL = "/api/Support/SendMessage";
const VERIFY_OTP_URL = "/api/CustomerData/Login";

//CHALETS URL
const  CHALETS_URL = "/api/CustomerData/BuildingListv2";
const  CHALETS_FILTER_URL = "/api/CustomerData/FilterBuildingListv2";
const  CHALETS_FILTER_DATE_URL = "/api/CustomerData/BuildingListWithDates";


const  CHALET_DETAILS_URL = "/api/CustomerData/GetBuildingData?BuldingId=";
const  CHALETS_MAP_URL = "/api/CustomerData/BuildingLatlog";

//BOOKING URL
const  CALCULATE_BOOKING_PRICE_URL = "/api/CustomerData/CalculateBuldingPrices";
const  CALCULATE_BOOKING_Building_PRICE_URL = "/api/FlatsCustomer/CalculateFlatPrices";


const  CHALET_BOOKING_URL = "/api/CustomerData/AddBooking";
const  PAYMENT_BOOKING_URL = "/api/CustomerData/BookingPayment";
const  PAYMENT_BOOKING_FLAT_URL = "/api/FlatsCustomer/HotelBookingPayment";

// QPay (installments) — mirrors the website's shleeh_com_customer/urls.js,
// CONFIRMED against a real backend response (23 Aug 2026):
// POST { bookingId, paymentType: 3, phoneNumber } ->
// { status, message: { plansList, principalId, paymentNumber } }
// Same BASE_URL (shleeh.com) as every other endpoint above — no separate
// host/env for QPay. Backend test deploy expected 24 Aug 2026.
const  PAYMENT_BOOKING_QPAY_URL = "/api/CustomerData/BookingPaymentQpay";
const  PAYMENT_BOOKING_FLAT_QPAY_URL = "/api/FlatsCustomer/HotelBookingPaymentQpay";
// QPay OTP send/resend. CONFIRMED: POST { PaymentNumber,
// phoneNumber } -> { status, message: 'Otp Sended' }.
// CORRECTED (10 Sep 2026, per the real Swagger list): NOT shared with
// buildings/flats like previously assumed — there is a separate
// /api/FlatsCustomer/HotelBookingQpayOTP for those, same split as
// PAYMENT_BOOKING_QPAY_URL/PAYMENT_BOOKING_FLAT_QPAY_URL above. See
// QPAY_SEND_OTP_FLAT_URL below.
const  QPAY_SEND_OTP_URL = "/api/CustomerData/BookingQpayOTP";
// QPay cards — verifies the OTP and returns the customer's saved QPay cards
// to charge. CONFIRMED (Ahmed Younes, 24 Aug 2026): POST { paymentNumber,
// phoneNumber, otp } -> card list.
// CORRECTED (10 Sep 2026): also split by booking type, see
// QPAY_CARDS_FLAT_URL below — was wrongly treated as shared.
const  QPAY_CARDS_URL = "/api/CustomerData/BookingQpayCards";
// QPay confirm — the final step that actually charges the selected card.
// CONFIRMED (Ahmed Younes, 24 Aug 2026): POST { paymentNumber, phoneNumber,
// otp, PrincipalId, PlanId, account } — note PrincipalId/PlanId are
// PascalCase while everything else stays lowercase (CONFIRMED 10 Sep 2026).
// "account" is the identifier of the card chosen on the previous
// (BookingQpayCards) step.
// CORRECTED (10 Sep 2026): also split by booking type, see
// QPAY_CONFIRM_FLAT_URL below — was wrongly treated as shared.
const  QPAY_CONFIRM_URL = "/api/CustomerData/BookingQpayConfirm";
// QPay OTP/cards/confirm for flats — CONFIRMED against the real Swagger
// listing (10 Sep 2026) as dedicated FlatsCustomer endpoints, mirroring
// PAYMENT_BOOKING_FLAT_QPAY_URL above. Same request/response shapes as
// their CustomerData counterparts (QPAY_SEND_OTP_URL/QPAY_CARDS_URL/
// QPAY_CONFIRM_URL) — only the host path differs.
const  QPAY_SEND_OTP_FLAT_URL = "/api/FlatsCustomer/HotelBookingQpayOTP";
const  QPAY_CARDS_FLAT_URL = "/api/FlatsCustomer/HotelBookingQpayCards";
const  QPAY_CONFIRM_FLAT_URL = "/api/FlatsCustomer/HotelBookingQpayConfirm";


const  CHAELTS_BOOKINGS_URL = "/api/CustomerData/GetBookingList";
const  FLAT_BOOKINGS_URL = "/api/FlatsCustomer/GetBookingList";

const  BOOKING_DETAILS_URL = "/api/CustomerData/GetBookingDetailes";
const  BOOKING_DETAILS_FLAT_URL = "/api/FlatsCustomer/GetBookingDetailes";

const  BOOKED_DAYS_CHALETS_URL = "/api/CustomerData/GetBookingDays";
const  BOOKED_DAYS_BUILDINGS_URL = "/api/FlatsCustomer/GetFlatBookingDays";

const  FLAT_BOOKING_URL = "/api/FlatsCustomer/AddBookingHotel";



//SETTING_URL
const  GET_USER_URL = "/api/CustomerData/GetOwner";
const  UPDATE_USER_URL = "/api/CustomerData/UpdateOwner";
const  DELETE_USER_URL = "/api/CustomerData/RemoveCustomer";



const  BUILDINGS_URL = "/api/FlatsCustomer/HotelBuildingList";
const  BUILDINGS_FILTER_URL = "/api/FlatsCustomer/FilterHotelBuildingList";
const  BUILDINGS_FILTER_DATE_URL = "/api/FlatsCustomer/CheckFlatBookingDaysList";


const  BUILDING_DETAILS_URL = "/api/FlatsCustomer/GetHotelBuildingData?BuldingId=";
const  BUILDINGS_MAP_URL = "/api/FlatsCustomer/HotelBuildingLatlog";


//flats
const  FLAT_URL = "/api/FlatsCustomer/HotelBuildingFlatsList";

// FAVORITES — new, backend-synced (previously local-only via
// shared_preferences — see FAVORITES-API-SPEC.md in the shleeh_com_customer
// repo for the full contract, shared with the website).
const  FAVORITES_URL = "/api/CustomerData/GetFavorite";
const  TOGGLE_FAVORITE_URL = "/api/CustomerData/ToggleFavorite";



