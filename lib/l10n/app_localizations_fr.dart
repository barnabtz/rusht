// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Russhit';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get ownerMode => 'Mode propriétaire';

  @override
  String get ownerModeDescription =>
      'Activer pour mettre en location des articles';

  @override
  String get uploadImage => 'Télécharger une image';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get profilePictureUpdated => 'Photo de profil mise à jour avec succès';

  @override
  String get failedToUpload => 'Échec du téléchargement de l\'image';

  @override
  String get fullNameRequired => 'Veuillez entrer votre nom complet';

  @override
  String get pleaseEnterPhoneNumber =>
      'Veuillez entrer votre numéro de téléphone';

  @override
  String get pleaseEnterAddress => 'Veuillez entrer votre adresse';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get pleaseEnterYourName => 'Veuillez entrer votre nom';

  @override
  String get pleaseEnterYourPhone =>
      'Veuillez entrer votre numéro de téléphone';

  @override
  String get pleaseEnterYourAddress => 'Veuillez entrer votre adresse';

  @override
  String get locationUpdated => 'Localisation mise à jour avec succès';

  @override
  String get iAmOwner => 'Je veux louer des articles';

  @override
  String get ownerDescription =>
      'Activez cette option pour mettre vos articles en location et gagner de l\'argent';

  @override
  String get ownerModeEnabled =>
      'Mode propriétaire activé - vous pouvez maintenant mettre des articles en location';

  @override
  String get ownerModeDisabled => 'Mode propriétaire désactivé';

  @override
  String get bookings => 'Mes réservations';

  @override
  String get noBookings => 'Aucune réservation pour le moment';

  @override
  String get noBookingsDescription => 'Vos réservations apparaîtront ici';

  @override
  String get errorLoadingBookings =>
      'Erreur lors du chargement des réservations';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get refresh => 'Actualiser';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get totalPrice => 'Prix total';

  @override
  String get cancellationReason => 'Motif d\'annulation';

  @override
  String get review => 'Avis';

  @override
  String get rating => 'Note';

  @override
  String bookingNumber(Object number) {
    return 'Réservation #$number';
  }

  @override
  String get status => 'Statut';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusConfirmed => 'Confirmée';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get statusDeclined => 'Refusée';

  @override
  String get chat => 'Discussion';

  @override
  String get typeAMessage => 'Tapez un message...';

  @override
  String get errorLoadingMessages => 'Erreur lors du chargement des messages';

  @override
  String get tryAgainButton => 'Réessayer';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get createRequest => 'Créer une demande';

  @override
  String get requestTitle => 'Titre de la demande';

  @override
  String get requestTitleHint => 'Entrez le titre de votre demande';

  @override
  String get requestTitleRequired => 'Le titre est requis';

  @override
  String get requestDescription => 'Description';

  @override
  String get requestDescriptionHint => 'Entrez une description';

  @override
  String get requestDescriptionRequired => 'La description est requise';

  @override
  String get requestCategory => 'Catégorie';

  @override
  String get requestBudgetMin => 'Budget minimum';

  @override
  String get requestBudgetMax => 'Budget maximum';

  @override
  String get requestBudgetRequired => 'Le budget est requis';

  @override
  String get requestBudgetInvalid => 'Budget invalide';

  @override
  String get requestBudgetMaxTooLow =>
      'Le budget maximum doit être supérieur au minimum';

  @override
  String get requestNeededBy => 'Nécessaire par';

  @override
  String requestNeededByDate(String date) {
    return 'Date requise';
  }

  @override
  String get requestSelectDate => 'Veuillez sélectionner une date limite';

  @override
  String get selectNeededByDate => 'Veuillez sélectionner une date requise';

  @override
  String get requestImages => 'Images';

  @override
  String get requestAddImage => 'Ajouter une image';

  @override
  String requestImageUploadError(String error) {
    return 'Échec du téléchargement de l\'image : $error';
  }

  @override
  String get requestImageUploadFailed =>
      'Échec du téléchargement de l\'image. Veuillez réessayer.';

  @override
  String requestImageUploadErrorDetail(Object error) {
    return 'Erreur lors du téléchargement de l\'image : $error. Veuillez réessayer plus tard.';
  }

  @override
  String requestImageUploadErrorNew(String error) {
    return 'Échec du téléchargement de l\'image : $error';
  }

  @override
  String get submitRequest => 'Soumettre la demande';

  @override
  String get cannotBookOwnProduct =>
      'Vous ne pouvez pas réserver votre propre produit';

  @override
  String get bookingCreatedSuccess => 'Réservation créée avec succès !';

  @override
  String get description => 'Description';

  @override
  String get pricePerDay => 'Prix par jour';

  @override
  String get searchItems => 'Rechercher des articles...';

  @override
  String get noItemsFound => 'Aucun article trouvé';

  @override
  String get tryAdjustingSearch =>
      'Essayez d\'ajuster votre recherche ou vos filtres';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get confirmBooking => 'Confirmer la réservation';

  @override
  String get item => 'Article';

  @override
  String get duration => 'Durée';

  @override
  String daysCount(int count) {
    return '$count jours';
  }

  @override
  String get categoryElectronics => 'Électronique';

  @override
  String get categoryFurniture => 'Mobilier';

  @override
  String get categoryTools => 'Outils';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryFashion => 'Mode';

  @override
  String get categoryHome => 'Maison';

  @override
  String get categoryToys => 'Jouets';

  @override
  String get categoryBaby => 'Bébé';

  @override
  String get categoryGaming => 'Jeux vidéo';

  @override
  String get categoryMusical => 'Musique';

  @override
  String get categoryArt => 'Art';
}
