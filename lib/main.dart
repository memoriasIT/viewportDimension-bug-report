import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Demo Sections
final List<TabSection> _sections = [
  TabSection(
    title: 'Hello',
    id: 'hello',
    color: Colors.blue,
  ),
  TabSection(
    title: 'Flutter',
    id: 'flutter',
    color: Colors.red,
  ),
  TabSection(
    title: 'Hello',
    id: 'a',
    color: Colors.blue,
  ),
  TabSection(
    title: 'Flutter',
    id: 'b',
    color: Colors.red,
  ),
  TabSection(
    title: 'Hello',
    id: 'c',
    color: Colors.blue,
  ),
  TabSection(
    title: 'Flutter',
    id: 'd',
    color: Colors.red,
  ),
  TabSection(
    title: 'Hello',
    id: 'e',
    color: Colors.blue,
  ),
  TabSection(
    title: 'Flutter',
    id: 'f',
    color: Colors.red,
  ),
];

final GoRouter _router = GoRouter(
  initialLocation: '/tab/hello',
  routes: <RouteBase>[
    GoRoute(
      path: '/tab/:tabId',
      builder: (BuildContext context, GoRouterState state) {
        // Extract the tabId from the route parameters.
        final String tabId = state.pathParameters['tabId']!;
        return NewsContentLoaded(
          // Use a key to ensure the widget rebuilds correctly on route changes.
          key: state.pageKey,
          sections: _sections,
          tabSection: tabId,
          // Update the route when the tab changes.
          onTabChanged: (String tabSection) => context.go('/tab/$tabSection'),
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'detail/:detailId',
          builder: (BuildContext context, GoRouterState state) {
            final String tabId = state.pathParameters['tabId']!;
            final String detailId = state.pathParameters['detailId']!;
            return DetailPage(tabId: tabId, detailId: detailId);
          },
        ),
      ],
    ),
  ],
);

// --- Main Application ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MaterialApp.router to enable go_router.
    return MaterialApp.router(
      routerConfig: _router,
      title: 'viewportDimension null',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}

// --- Detail Page Widget ---

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.tabId,
    required this.detailId,
  });

  final String tabId;
  final String detailId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail View for Tab: $tabId'),
        // Use go_router's pop method for navigation.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tab/$tabId'),
        ),
      ),
      body: Center(
        child: Text(
          'Showing details for ID: $detailId',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

// --- Tab View ---

class NewsContentLoaded extends StatefulWidget {
  const NewsContentLoaded({
    super.key,
    required this.sections,
    required this.onTabChanged,
    this.tabSection,
  });

  final List<TabSection> sections;
  final void Function(String tabSection) onTabChanged;
  final String? tabSection;

  @override
  State<NewsContentLoaded> createState() => NewsContentLoadedState();
}

class NewsContentLoadedState extends State<NewsContentLoaded> with TickerProviderStateMixin {
  CustomTabController? _tabController;
  late final PageStorageBucket bucket;

  @override
  void initState() {
    super.initState();
    bucket = PageStorageBucket();
    _initTabController();
  }

  void _initTabController() {
    _tabController = CustomTabController(
      initialIndex: 5,
      length: widget.sections.length,
      vsync: this,
      onTabChangeCallback: (index) async {
        final tab = widget.sections[index];
        widget.onTabChanged(tab.id);
      },
    );
  }

  @override
  void didUpdateWidget(covariant NewsContentLoaded oldWidget) {
    super.didUpdateWidget(oldWidget);

    final controller = _tabController;
    if (controller == null) return;

    controller.animateTo(0);
    controller.animateTo(widget.sections.length - 3);
    controller.animateTo(0);
    controller.animateTo(widget.sections.length - 3);
    controller.animateTo(0);
    controller.animateTo(widget.sections.length - 3);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty || _tabController == null) {
      return const Scaffold(body: Center(child: LinearProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ColoredBox(
              color: Colors.white,
              child: CustomTabBar(
                controller: _tabController!,
                sections: widget.sections,
                onTabChange: (index) {},
              ),
            ),
            Expanded(
              child: PageStorage(
                bucket: bucket,
                child: TabBarView(
                  controller: _tabController,
                  children: widget.sections.map((tab) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Demo content ${tab.title}'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.go('/tab/${tab.id}/detail/1');
                            },
                            child: const Text('Open Detail'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTabController extends TabController {
  CustomTabController({
    required super.length,
    required super.vsync,
    super.initialIndex = defaultIndex,
    this.onTabChangeCallback,
  }) {
    _init();
  }

  final Future<void> Function(int index)? onTabChangeCallback;

  static const int defaultIndex = 0;
  int oldIndex = defaultIndex;

  void _init() {
    addListener(onTabChange);
  }

  Future<void> onTabChange() async {
    if (!indexIsChanging && index != oldIndex) {
      await onTabChangeCallback?.call(index);
      oldIndex = index;
    }
  }

  @override
  void dispose() {
    removeListener(onTabChange);
    super.dispose();
  }
}

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    required this.sections,
    required this.controller,
    required this.onTabChange,
    this.tabAlignment = TabAlignment.start,
    this.isScrollable = true,
    super.key,
  });

  final List<TabSection> sections;
  final TabController controller;
  final TabAlignment tabAlignment;
  final bool isScrollable;
  final void Function(int index) onTabChange;

  static const double borderSize = 3;

  static double getTabBarHeight(BuildContext context) {
    if (!context.mounted) return 0;
    final textScaleFactor = MediaQuery.textScalerOf(context);
    return textScaleFactor.clamp(minScaleFactor: 1, maxScaleFactor: 1.36).scale(44) + borderSize;
  }

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  List<Tab> tabs = [];
  Color tabColor = Colors.transparent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabsAndColor();
  }

  @override
  void didUpdateWidget(covariant CustomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sections != oldWidget.sections) {
      _updateTabsAndColor();
    }
  }

  void _updateTabsAndColor() {
    tabs = widget.sections
        .map(
          (section) => Tab(
            text: section.title,
            height: CustomTabBar.getTabBarHeight(context) - CustomTabBar.borderSize,
          ),
        )
        .toList();
    if (widget.sections.isNotEmpty) {
      tabColor = widget.sections[widget.controller.index].color;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.animation?.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!mounted) return;

    final controller = widget.controller;
    final animation = controller.animation;

    if (animation == null) return;

    final currentIndex = controller.index;
    final targetIndex = controller.offset.round() + currentIndex;

    // Ensure targetIndex is within bounds
    if (targetIndex < 0 || targetIndex >= widget.sections.length) return;

    final currentColor = widget.sections[currentIndex].color;
    final targetColor = widget.sections[targetIndex].color;

    final lerpedColor = Color.lerp(currentColor, targetColor, controller.offset.abs());

    if (lerpedColor != null) {
      setState(() {
        tabColor = lerpedColor;
      });
    }

    widget.onTabChange(currentIndex);
  }

  @override
  void dispose() {
    widget.controller.animation?.removeListener(_handleTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      controller: widget.controller,
      dividerColor: Colors.transparent,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: tabColor, width: 3),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      isScrollable: widget.isScrollable,
      tabAlignment: widget.tabAlignment,
      tabs: tabs,
    );
  }
}

class TabSection {
  TabSection({
    required this.title,
    required this.id,
    required this.color,
  });

  final String title;
  final String id;
  final Color color;
}
