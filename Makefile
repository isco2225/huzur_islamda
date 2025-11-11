# Flutter App
fr:
	cd qr_menu_system_flutter && flutter run --flavor development -t lib/main_development.dart --enable-impeller 
frp:
	cd qr_menu_system_flutter && flutter run --profile --enable-impeller
fg:
	cd qr_menu_system_flutter && dart run build_runner build --delete-conflicting-outputs
fpg:
	cd qr_menu_system_flutter && flutter pub get
fbid:
	cd qr_menu_system_flutter && flutter build ios -t lib/main_development.dart --flavor development
fbad:
	cd qr_menu_system_flutter && flutter build appbundle -t lib/main_development.dart --flavor development --release --no-shrink
fbis:
	cd qr_menu_system_flutter && flutter build ios -t lib/main_staging.dart --flavor staging
fbas:
	cd qr_menu_system_flutter && flutter build appbundle -t lib/main_staging.dart --flavor staging --release --no-shrink
ft: 
	cd qr_menu_system_flutter && flutter test
ftc: 
	cd qr_menu_system_flutter && flutter test --coverage && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
fcl:
	cd qr_menu_system_flutter && find . -name '.dart_tool' -prune -o -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.gr.dart' ! -name '*.gen.dart' ! -name 'l10n.dart' !  -name 'messages_tr.dart' ! -name 'messages_en.dart' -print | xargs wc -l | sort -n
# Flutter Web
fwr:
	cd qr_menu_system_flutter && flutter run -d chrome
