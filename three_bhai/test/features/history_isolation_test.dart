import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_bhai/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:three_bhai/features/recipe/data/repositories/local_history_repository.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each user only sees their own history', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = MockAuthRepository();
    final history = LocalHistoryRepository(auth);

    await auth.signIn(email: 'asha@3bhai.app', password: 'x');
    await history.save(
      ingredients: const ['Chicken'],
      sourceName: 'TheMealDB',
      recipes: const [Recipe(id: '1', title: 'Curry')],
    );
    expect((await history.getHistory()).length, 1);

    await auth.signOut();
    await auth.signIn(email: 'bilal@3bhai.app', password: 'x');
    expect(await history.getHistory(), isEmpty);

    await auth.signOut();
    await auth.signIn(email: 'asha@3bhai.app', password: 'x');
    final mine = await history.getHistory();
    expect(mine.length, 1);
    expect(mine.first.recipes.first.title, 'Curry');
  });
}
