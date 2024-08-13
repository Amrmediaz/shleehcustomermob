
const BASE_URL = "http://www.shleeh.com";
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
const  CHALET_BOOKING_URL = "/api/CustomerData/AddBooking";
const  PAYMENT_BOOKING_URL = "/api/CustomerData/BookingPayment";
const  BOOKINGS_URL = "/api/CustomerData/GetBookingList";
const  BOOKING_DETAILS_URL = "/api/CustomerData/GetBookingDetailes";
const  BOOKED_DAYS_CHALETS_URL = "/api/CustomerData/GetBookingDays";


//SETTING_URL
const  GET_USER_URL = "/api/CustomerData/GetOwner";
const  UPDATE_USER_URL = "/api/CustomerData/UpdateOwner";
const  DELETE_USER_URL = "/api/CustomerData/RemoveCustomer";



