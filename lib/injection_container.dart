import 'package:shleehcustomer/features/buildings/domain/repositories/buildings_repository.dart';
import 'package:shleehcustomer/features/authentication/login/data/datasources/login_data_source.dart';
import 'package:shleehcustomer/features/authentication/login/domain/repositories/login_repository.dart';
import 'package:shleehcustomer/features/authentication/login/domain/usecases/login_usecase.dart';
import 'package:shleehcustomer/features/authentication/register/data/datasources/register_data_source.dart';
import 'package:shleehcustomer/features/authentication/register/data/repositories/register_repository_implementation.dart';
import 'package:shleehcustomer/features/authentication/register/domain/repositories/register_repositories.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/check_user_exist.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/register_user.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/send_otp.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/verify_otp.dart';
import 'package:shleehcustomer/features/authentication/register/presentaion/bloc/register/register_user_bloc.dart';
import 'package:shleehcustomer/features/authentication/reset_password/data/datasources/reset_password_data_source.dart';
import 'package:shleehcustomer/features/authentication/reset_password/data/repositories/reset_password_repository_impl.dart';
import 'package:shleehcustomer/features/authentication/reset_password/domain/repositories/reset_password_repository.dart';
import 'package:shleehcustomer/features/authentication/reset_password/domain/usecases/reset_password_usecase.dart';
import 'package:shleehcustomer/features/booking/data/datasources/chalet_remote_data_source.dart';
import 'package:shleehcustomer/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:shleehcustomer/features/booking/domain/repositories/booking_repository.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/book_chalet.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/get_booking_by_id.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/get_bookings.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/payment_book.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/payment_book_qpay.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/send_qpay_otp.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/get_qpay_cards.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/confirm_qpay.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/buildings/data/datasources/building_local_data_source.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_building_by_id.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_buildings.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_buildings_map.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_flats_by_building_id.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/buildings/buildings_bloc.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/flat/flats_bloc.dart';
import 'package:shleehcustomer/features/chalets/data/datasources/chalet_local_data_source.dart';
import 'package:shleehcustomer/features/chalets/data/datasources/chalet_remote_data_source.dart';
import 'package:shleehcustomer/features/chalets/data/repositories/chalet_repository_impl.dart';
import 'package:shleehcustomer/features/chalets/domain/repositories/chalets_repository.dart';
import 'package:shleehcustomer/features/chalets/domain/usecases/get_chalet_by_id.dart';
import 'package:shleehcustomer/features/chalets/domain/usecases/get_chalets.dart';
import 'package:shleehcustomer/features/chalets/domain/usecases/get_chalets_map.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/landing/data/datasource/local_data_source.dart';
import 'package:shleehcustomer/features/landing/data/repositories/on_board_repositories_implementation.dart';
import 'package:shleehcustomer/features/landing/domain/reposiitories/onboard_repositories.dart';
import 'package:shleehcustomer/features/landing/domain/usescases/get_onboard_items.dart';
import 'package:shleehcustomer/features/landing/presentation/bloc/landing/landing_bloc.dart';
import 'package:shleehcustomer/features/settings/data/datasources/setting_remote_data_source.dart';
import 'package:shleehcustomer/features/settings/data/repositories/setting_repository_impl.dart';
import 'package:shleehcustomer/features/settings/domain/repositories/setting_repository.dart';
import 'package:shleehcustomer/features/settings/domain/usecases/delete_user.dart';
import 'package:shleehcustomer/features/settings/domain/usecases/get_user_data.dart';
import 'package:shleehcustomer/features/settings/domain/usecases/update_user.dart';

import 'package:get_it/get_it.dart';

import 'core/favorites/favorites_cubit.dart';
import 'core/favorites/favorites_service.dart';
import 'core/network/network_info.dart';
import 'features/authentication/login/data/repositories/login_repository_impl.dart';
import 'features/authentication/login/presentation/bloc/login/login_bloc.dart';
import 'features/authentication/reset_password/presentation/bloc/reset/reset_password_bloc.dart';
import 'features/booking/domain/usecases/get_dates_cost.dart';
import 'features/buildings/data/datasources/building_remote_data_source.dart';
import 'package:shleehcustomer/features/buildings/domain/repositories/buildings_repository.dart';
import 'package:shleehcustomer/features/buildings/data/repositories/building_repository_impl.dart';
import 'features/home_page/presentation/bloc/home/home_bloc.dart';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/settings/presentation/bloc/setting/setting_bloc.dart';


final sl = GetIt.instance;

Future<void> init() async {
//! Features - posts

// Bloc

  sl.registerFactory(() => HomeBloc());
  sl.registerFactory(() => SettingBloc(getUserSettingsUsecase: sl(), updateUserSettingsUsecase: sl(), deleteUserSettingsUsecase: sl()));

  sl.registerFactory(() => ChaletsBloc(getChaletsUsecase:sl(), getChaletIdUsecase: sl(), getChaletsMapUsecase: sl()));
  sl.registerFactory(() => BookingsBloc(getBookingsUsecase: sl(), getBookingIdUsecase: sl(), getBookingDatesCostUsecase: sl(), bookingPaymentUsecase: sl(), bookChaletUsecase: sl()));
  sl.registerFactory(() => BuildingsBloc(getBuildingsUsecase: sl(), getBuildingIdUsecase: sl(), getBuildingsMapUsecase: sl()));
  sl.registerFactory(() => FlatsBloc(getFlatByBuildingIdUsecase: sl()));


  sl.registerFactory(() => LoginBloc(loginUsecase: sl()));
  sl.registerFactory(() => ResetBloc(resetPasswordUsecase: sl()));
  sl.registerFactory(() => LandingBloc(getOnBoardsUsecase: sl()));
  sl.registerFactory(() => RegisterBloc(registerUserUserCase: sl(),sendOtpUserCase: sl(),verifyOtpUserCase: sl(), checkUserExistedUserCase: sl()));

  // Favorites — backend-synced (see FavoritesService). Registered as a
  // factory to match this app's existing convention for every other
  // Bloc/Cubit, but (also like every other Bloc here) it's only ever
  // instantiated once, in the root MultiBlocProvider, so it behaves as a
  // single shared instance.
  sl.registerFactory(() => FavoritesCubit(sl()));



// Usecases

  sl.registerLazySingleton(() => GetBookingsUsecase(sl()));
  sl.registerLazySingleton(() => GetUserSettingsUsecase(sl()));
  sl.registerLazySingleton(() => UpdateUserSettingsUsecase(sl()));
  sl.registerLazySingleton(() => DeleteUserSettingsUsecase(sl()));

  sl.registerLazySingleton(() => GetBookingIdUsecase(sl()));
  sl.registerLazySingleton(() => GetBookingDatesCostUsecase(sl()));
  sl.registerLazySingleton(() => BookingPaymentUsecase(sl()));
  sl.registerLazySingleton(() => BookingPaymentQpayUsecase(sl()));
  sl.registerLazySingleton(() => SendQpayOtpUsecase(sl()));
  sl.registerLazySingleton(() => GetQpayCardsUsecase(sl()));
  sl.registerLazySingleton(() => ConfirmQpayUsecase(sl()));
  sl.registerLazySingleton(() => BookChaletUsecase(sl()));


  sl.registerLazySingleton(() => LoginUsecase(sl()));

  sl.registerLazySingleton(() => ResetPasswordUsecase(sl()));
  sl.registerLazySingleton(() => GetOnBoardsUsecase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUserCase(registerRepositories: sl()));
  sl.registerLazySingleton(() => SendOtpUserCase(registerRepositories: sl()));
  sl.registerLazySingleton(() => CheckUserExistUserCase(registerRepositories: sl()));
  sl.registerLazySingleton(() => RegisterUserUserCase(registerRepositories: sl()));
  sl.registerLazySingleton(() => GetChaletsUsecase(sl()));
  sl.registerLazySingleton(() => GetChaletIdUsecase(sl()));
  sl.registerLazySingleton(() => GetChaletsMapUsecase(sl()));

  sl.registerLazySingleton(() => GetBuildingIdUsecase(sl()));
  sl.registerLazySingleton(() => GetBuildingsUsecase(sl()));
  sl.registerLazySingleton(() => GetBuildingsMapUsecase(sl()));

  sl.registerLazySingleton(() => GetFlatByBuildingIdUsecase(sl()));

// Repository


  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
      remoteDataSource: sl(),  networkInfo: sl()));

  sl.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(loginDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<ResetPasswordRepositories>(() => ResetPasswordRepositoryImpl(resetPasswordDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<OnboardRepositories>(() => OnBoardRepositoriesImplementation(onboardLocalDataSource: sl()));
  sl.registerLazySingleton<RegisterRepositories>(() => RegisterRepositoryImplementation(registerDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<ChaletsRepository>(() => ChaletsRepositoryImpl(remoteDataSource: sl(),localDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<BookingRepository>(() => BookingssRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));

  sl.registerLazySingleton<BuildingsRepository>(() => BuildingsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()));

// Datasources
  sl.registerLazySingleton<ResetPasswordDataSource>(
          () => ResetPasswordDataSourceImpl(client: sl()));
  sl.registerLazySingleton<SettingRemoteDataSource>(
          () => SettingRemoteDataSourceImpl(client: sl()));
  sl.registerLazySingleton<LoginDataSource>(
          () => LoginDataSourceImpl(client: sl()));

  sl.registerLazySingleton<OnboardLocalDataSource>(
          () => OnboardLocalDataSourceImp());
  sl.registerLazySingleton<RegisterDataSource>(
          () => RegisterDataSourceImp(client: sl()));
  sl.registerLazySingleton<ChaletRemoteDataSource>(
          () => ChaletsRemoteDataSourceImpl(client: sl()));

  sl.registerLazySingleton<BuildingRemoteDataSource>(
          () => BuildingsRemoteDataSourceImpl(client: sl()));
  sl.registerLazySingleton<ChaletLocalDataSource>(
          () => ChaletLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<BookingRemoteDataSource>(
          () => BookingRemoteDataSourceImpl(client: sl()));

  sl.registerLazySingleton<BuildingLocalDataSource>(
          () => BuildingLocalDataSourceImpl(sharedPreferences: sl()));
//! Core

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => FavoritesService(sl()));

//! External


  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.instance);
}
