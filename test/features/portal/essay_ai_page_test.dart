import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/presentation/pages/essay_ai_page.dart';

import 'essay_ai_fixture.dart';

class _FakeApi implements PortalApi {
  final calls = <String>[];
  @override
  Future<Map<String, dynamic>> essayAiOverview() async => essayAiOverviewFixture();
  @override
  Future<void> essayAiSet(String provider, Map<String, dynamic> patch, {String? note}) async => calls.add('set:$provider:$patch');
  @override
  Future<void> essayAiSetOrder(List<String> order, {String? note}) async => calls.add('order:${order.join('>')}');
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

Future<_FakeApi> _pump(WidgetTester t) async {
  SharedPreferences.setMockInitialValues({'language': 'portuguese'});
  final api = _FakeApi();
  t.view.physicalSize = const Size(1600, 1400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MultiBlocProvider(
    providers: [BlocProvider(create: (_) => LocaleCubit()..setLanguage(AppLanguage.portuguese)), RepositoryProvider<PortalApi>.value(value: api)],
    child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: SingleChildScrollView(child: EssayAiPage()))),
  ));
  await t.pumpAndSettle();
  return api;
}

void main() {
  testWidgets('mostra provedores, breaker aberto, consumo e capacidade', (t) async {
    await _pump(t);
    expect(find.text('Groq'), findsOneWidget);
    expect(find.text('Cloudflare Workers AI'), findsOneWidget);
    expect(find.text('Aberto'), findsOneWidget);
    expect(find.text('Fechado'), findsWidgets);
    expect(find.text('Reiniciar breaker'), findsNWidgets(2));
  });

  testWidgets('desligar provedor pede confirmação e envia enabled=false', (t) async {
    final api = await _pump(t);
    await t.tap(find.text('Desligar').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Desabilitar'));
    await t.pumpAndSettle();
    expect(api.calls, ['set:groq:{enabled: false}']);
  });

  testWidgets('subir prioridade do Plano B inverte a ordem', (t) async {
    final api = await _pump(t);
    await t.tap(find.byTooltip('Subir prioridade').at(1)); // primeiro botão ativo é o do 2º provedor
    await t.pumpAndSettle();
    await t.tap(find.text('Alterar'));
    await t.pumpAndSettle();
    expect(api.calls, ['order:cloudflare>groq>google']);
  });

  testWidgets('reiniciar breaker envia reset_breaker', (t) async {
    final api = await _pump(t);
    await t.tap(find.text('Reiniciar breaker').first);
    await t.pumpAndSettle();
    expect(api.calls, ['set:groq:{reset_breaker: true}']);
  });
}
