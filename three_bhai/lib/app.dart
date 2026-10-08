import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:three_bhai/core/config/app_config.dart';
import 'package:three_bhai/core/theme/app_theme.dart';
import 'package:three_bhai/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:three_bhai/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_in.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_out.dart';
import 'package:three_bhai/features/auth/domain/usecases/sign_up.dart';
import 'package:three_bhai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:three_bhai/features/auth/presentation/pages/auth_page.dart';
import 'package:three_bhai/features/chat/data/repositories/local_chat_repository.dart';
import 'package:three_bhai/features/chat/data/repositories/supabase_chat_repository.dart';
import 'package:three_bhai/features/chat/domain/repositories/chat_repository.dart';
import 'package:three_bhai/features/chat/domain/usecases/chat_usecases.dart';
import 'package:three_bhai/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:three_bhai/features/chat/presentation/pages/chat_page.dart';
import 'package:three_bhai/features/recipe/data/datasources/edge_function_recipe_data_source.dart';
import 'package:three_bhai/features/recipe/data/datasources/meal_db_recipe_data_source.dart';
import 'package:three_bhai/features/recipe/data/datasources/recipe_remote_data_source.dart';
import 'package:three_bhai/features/recipe/data/repositories/local_history_repository.dart';
import 'package:three_bhai/features/recipe/data/repositories/mock_ingredient_repository.dart';
import 'package:three_bhai/features/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:three_bhai/features/recipe/data/repositories/supabase_history_repository.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/domain/repositories/history_repository.dart';
import 'package:three_bhai/features/recipe/domain/repositories/ingredient_repository.dart';
import 'package:three_bhai/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:three_bhai/features/recipe/domain/usecases/find_recipes.dart';
import 'package:three_bhai/features/recipe/domain/usecases/get_ingredients.dart';
import 'package:three_bhai/features/recipe/domain/usecases/history_usecases.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/history_cubit.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/ingredient_selection_cubit.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/recipe_results_cubit.dart';
import 'package:three_bhai/features/recipe/presentation/pages/history_page.dart';
import 'package:three_bhai/features/recipe/presentation/pages/ingredient_selection_page.dart';
import 'package:three_bhai/features/recipe/presentation/pages/recipe_results_page.dart';

abstract final class AppRoutes {
  static const auth = '/';
  static const ingredients = '/ingredients';
}

class ThreeBhaiApp extends StatelessWidget {
  const ThreeBhaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final useSupabase = AppConfig.hasSupabase;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<http.Client>(
          create: (_) => http.Client(),
          dispose: (client) => client.close(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (_) {
            if (useSupabase) {
              return SupabaseAuthRepository(Supabase.instance.client);
            }
            return MockAuthRepository();
          },
        ),
        RepositoryProvider<IngredientRepository>(
          create: (_) => MockIngredientRepository(),
        ),
        RepositoryProvider<HistoryRepository>(
          create: (context) {
            if (useSupabase) {
              return SupabaseHistoryRepository(Supabase.instance.client);
            }
            return LocalHistoryRepository(context.read<AuthRepository>());
          },
        ),
        RepositoryProvider<ChatRepository>(
          create: (context) {
            if (useSupabase) {
              return SupabaseChatRepository(Supabase.instance.client);
            }
            return LocalChatRepository(context.read<AuthRepository>());
          },
        ),
        RepositoryProvider<RecipeRemoteDataSource>(
          create: (context) {
            if (useSupabase) {
              return EdgeFunctionRecipeDataSource(Supabase.instance.client);
            }
            return MealDbRecipeDataSource(context.read<http.Client>());
          },
        ),
        RepositoryProvider<RecipeRepository>(
          create: (context) =>
              RecipeRepositoryImpl(context.read<RecipeRemoteDataSource>()),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) {
          final repo = context.read<AuthRepository>();
          return AuthCubit(
            signIn: SignIn(repo),
            signUp: SignUp(repo),
            signOut: SignOut(repo),
          );
        },
        child: Builder(
          builder: (context) {
            // A restored Supabase session skips the login screen.
            final signedIn =
                context.read<AuthRepository>().currentUser != null;

            return MaterialApp(
              title: '3Bhai',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              initialRoute: signedIn ? AppRoutes.ingredients : AppRoutes.auth,
              routes: {
                AppRoutes.auth: (context) => AuthPage(
                      onAuthenticated: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.ingredients),
                    ),
                AppRoutes.ingredients: (context) =>
                    BlocProvider<IngredientSelectionCubit>(
                      create: (context) => IngredientSelectionCubit(
                        GetIngredients(context.read<IngredientRepository>()),
                      )..load(),
                      child: IngredientSelectionPage(
                        onGenerate: (ingredients) =>
                            _openLiveResults(context, ingredients),
                        onOpenHistory: () => _openHistory(context),
                        onOpenChat: () => _openChat(context),
                        onLogout: () async {
                          await context.read<AuthCubit>().signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.auth,
                            (route) => false,
                          );
                        },
                      ),
                    ),
              },
            );
          },
        ),
      ),
    );
  }
}

void _openLiveResults(BuildContext context, List<Ingredient> ingredients) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<RecipeResultsCubit>(
        create: (ctx) => RecipeResultsCubit(FindRecipes(
          ctx.read<RecipeRepository>(),
          ctx.read<HistoryRepository>(),
        ))
          ..search(ingredients),
        child: RecipeResultsPage(
          labels: [for (final i in ingredients) '${i.emoji} ${i.name}'],
        ),
      ),
    ),
  );
}

void _openSaved(BuildContext context, SearchRecord record) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<RecipeResultsCubit>(
        create: (ctx) => RecipeResultsCubit(FindRecipes(
          ctx.read<RecipeRepository>(),
          ctx.read<HistoryRepository>(),
        ))
          ..showSaved(record),
        child: RecipeResultsPage(
          labels: record.ingredients,
          canSearchAgain: false,
        ),
      ),
    ),
  );
}

void _openHistory(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (pageContext) => BlocProvider<HistoryCubit>(
        create: (ctx) {
          final repo = ctx.read<HistoryRepository>();
          return HistoryCubit(
            getHistory: GetHistory(repo),
            deleteItem: DeleteHistoryItem(repo),
            clearAll: ClearHistory(repo),
          )..load();
        },
        child: HistoryPage(onOpen: (record) => _openSaved(pageContext, record)),
      ),
    ),
  );
}

void _openChat(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<ChatCubit>(
        create: (ctx) {
          final repo = ctx.read<ChatRepository>();
          return ChatCubit(
            load: LoadChat(repo),
            send: SendChatMessage(repo),
            clear: ClearChat(repo),
          )..load();
        },
        child: const ChatPage(),
      ),
    ),
  );
}
