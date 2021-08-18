import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/auth/form_submission_status.dart';
import 'package:social_media/data_repository.dart';
import 'package:social_media/models/User.dart';
import 'package:social_media/storage_repository.dart';
import '../image_url_cache.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final StorageRepository storageRepo;
  final DataRepository dataRepo;
  final _picker = ImagePicker();

  ProfileBloc(
      {required this.storageRepo,
      required this.dataRepo,
      required User user,
      required bool isCurrentUser})
      : super(ProfileState(user: user, isCurrentUser: isCurrentUser)) {
    if (user.avatarKey != null)
      ImageUrlCache.instance
          .getUrl(user.avatarKey!)
          .then((url) => add(ProvideImagePath(avatarPath: url)));
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ChangeAvatarRequest) {
      yield state.copyWith(imageSourceActionSheetIsVisible: true);
    } else if (event is OpenImagePicker) {
      yield state.copyWith(imageSourceActionSheetIsVisible: false);
      final pickedImage = await _picker.getImage(source: event.imageSource!);
      if (pickedImage == null) return;

      final imageKey = await storageRepo.uploadFile(File(pickedImage.path));
      final updatedUser = state.user.copyWith(avatarKey: imageKey);
      final results = await Future.wait([
        dataRepo.updateUser(updatedUser),
        storageRepo.getUrlForFile(imageKey)
      ]);

      yield state.copyWith(avatarPath: results.last as String?);
    } else if (event is ProvideImagePath) {
      yield state.copyWith(avatarPath: event.avatarPath);
    } else if (event is ProfileDescriptionChanged) {
      yield state.copyWith(userDescription: event.description);
    } else if (event is SaveProfileChanges) {
      yield state.copyWith(formStatus: FormSubmitting());
      final updatedUser = state.user.copyWith(description: state.userDescription);
      try{
        await dataRepo.updateUser(updatedUser);
        yield state.copyWith(formStatus: SubmissionSuccess());
      } catch(e){
        yield state.copyWith(formStatus: SubmissionFailed(e as Exception));
      }
    }
  }
}
