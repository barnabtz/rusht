// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Russhit';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign Out';

  @override
  String get ownerMode => 'Owner Mode';

  @override
  String get ownerModeDescription => 'Enable to list items for rent';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profilePictureUpdated => 'Profile picture updated successfully';

  @override
  String get failedToUpload => 'Failed to upload image';

  @override
  String get fullNameRequired => 'Please enter your full name';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterAddress => 'Please enter your address';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get pleaseEnterYourPhone => 'Please enter your phone number';

  @override
  String get pleaseEnterYourAddress => 'Please enter your address';

  @override
  String get locationUpdated => 'Location updated successfully';

  @override
  String get iAmOwner => 'I want to rent out items';

  @override
  String get ownerDescription =>
      'Enable this to list your items for rent and earn money';

  @override
  String get ownerModeEnabled =>
      'Owner mode enabled - you can now list items for rent';

  @override
  String get ownerModeDisabled => 'Owner mode disabled';

  @override
  String get bookings => 'My Bookings';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String get noBookingsDescription => 'Your bookings will appear here';

  @override
  String get errorLoadingBookings => 'Error loading bookings';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get refresh => 'Refresh';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get cancellationReason => 'Cancellation Reason';

  @override
  String get review => 'Review';

  @override
  String get rating => 'Rating';

  @override
  String bookingNumber(Object number) {
    return 'Booking #$number';
  }

  @override
  String get status => 'Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get chat => 'Chat';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get errorLoadingMessages => 'Error loading messages';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get sendMessage => 'Send message';

  @override
  String get createRequest => 'Create Request';

  @override
  String get requestTitle => 'Request Title';

  @override
  String get requestTitleHint => 'Enter the title of your request';

  @override
  String get requestTitleRequired => 'Title is required';

  @override
  String get requestDescription => 'Description';

  @override
  String get requestDescriptionHint => 'Enter a description';

  @override
  String get requestDescriptionRequired => 'Description is required';

  @override
  String get requestCategory => 'Category';

  @override
  String get requestBudgetMin => 'Minimum Budget';

  @override
  String get requestBudgetMax => 'Maximum Budget';

  @override
  String get requestBudgetRequired => 'Budget is required';

  @override
  String get requestBudgetInvalid => 'Invalid budget';

  @override
  String get requestBudgetMaxTooLow => 'Must be > min';

  @override
  String get requestNeededBy => 'Needed By';

  @override
  String requestNeededByDate(String date) {
    return 'Needed By Date';
  }

  @override
  String get requestSelectDate => 'Please select a needed by date';

  @override
  String get selectNeededByDate => 'Please select a needed by date';

  @override
  String get requestImages => 'Images';

  @override
  String get requestAddImage => 'Add Image';

  @override
  String requestImageUploadError(String error) {
    return 'Failed to upload image: $error';
  }

  @override
  String get requestImageUploadFailed =>
      'Image upload failed. Please try again.';

  @override
  String requestImageUploadErrorDetail(Object error) {
    return 'Error uploading image: $error. Please try again later.';
  }

  @override
  String requestImageUploadErrorNew(String error) {
    return 'Failed to upload image: $error';
  }

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get cannotBookOwnProduct => 'You cannot book your own product';

  @override
  String get bookingCreatedSuccess => 'Booking created successfully!';

  @override
  String get description => 'Description';

  @override
  String get pricePerDay => 'Price per day';

  @override
  String get searchItems => 'Search for items...';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get tryAdjustingSearch => 'Try adjusting your search or filters';

  @override
  String get allCategories => 'All Categories';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get item => 'Item';

  @override
  String get duration => 'Duration';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryFurniture => 'Furniture';

  @override
  String get categoryTools => 'Tools';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryFashion => 'Fashion';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryToys => 'Toys';

  @override
  String get categoryBaby => 'Baby';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryMusical => 'Musical';

  @override
  String get categoryArt => 'Art';
}
