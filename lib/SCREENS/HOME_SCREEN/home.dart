import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─── Sample Data Models (reuse your AppTransaction / AppTransactionType) ──────

enum AppTransactionType { income, expense }

class AppTransaction {
  final String title;
  final double amount;
  final AppTransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  AppTransaction({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });
}

// ─── Sample dummy data ────────────────────────────────────────────────────────

final List<AppTransaction> _dummyTransactions = [
  AppTransaction(title: 'Freelance Payment', amount: 1200, type: AppTransactionType.income, category: 'Freelance', date: DateTime.now().subtract(const Duration(hours: 2))),
  AppTransaction(title: 'Grocery Shopping', amount: 85.5, type: AppTransactionType.expense, category: 'Food', date: DateTime.now().subtract(const Duration(hours: 5))),
  AppTransaction(title: 'Netflix', amount: 15.99, type: AppTransactionType.expense, category: 'Entertainment', date: DateTime.now().subtract(const Duration(days: 1))),
  AppTransaction(title: 'Salary', amount: 3500, type: AppTransactionType.income, category: 'Salary', date: DateTime.now().subtract(const Duration(days: 2))),
  AppTransaction(title: 'Electricity Bill', amount: 120, type: AppTransactionType.expense, category: 'Bills', date: DateTime.now().subtract(const Duration(days: 3))),
  AppTransaction(title: 'Transport', amount: 45, type: AppTransactionType.expense, category: 'Transport', date: DateTime.now().subtract(const Duration(days: 3))),
];

// ─── Category Icons ───────────────────────────────────────────────────────────

IconData _categoryIcon(String cat) {
  switch (cat) {
    case 'Food': return Icons.fastfood_rounded;
    case 'Transport': return Icons.directions_bus_rounded;
    case 'Shopping': return Icons.shopping_bag_rounded;
    case 'Health': return Icons.favorite_rounded;
    case 'Bills': return Icons.receipt_long_rounded;
    case 'Entertainment': return Icons.movie_rounded;
    case 'Salary': return Icons.work_rounded;
    case 'Freelance': return Icons.laptop_rounded;
    case 'Investment': return Icons.trending_up_rounded;
    default: return Icons.category_rounded;
  }
}

// ─── Home ─────────────────────────────────────────────────────────────────

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late AnimationController _cardsAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  List<AppTransaction> _transactions = List.from(_dummyTransactions);

  // Budget limit (monthly)
  final double _monthlyBudget = 1500;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardsAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      _headerAnim.forward();
      _cardsAnim.forward();
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _cardsAnim.dispose();
    super.dispose();
  }

  // ── Computed values ──────────────────────────────────────────────────────

  double get _totalIncome => _transactions
      .where((t) => t.type == AppTransactionType.income)
      .fold(0, (s, t) => s + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == AppTransactionType.expense)
      .fold(0, (s, t) => s + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  double get _budgetUsed => _totalExpense.clamp(0, _monthlyBudget);
  double get _budgetProgress => (_budgetUsed / _monthlyBudget).clamp(0, 1);

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _cardsAnim,
              builder: (context, child) => Opacity(
                opacity: _cardsAnim.value,
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildIncomeExpenseRow(),
                    const SizedBox(height: 20),
                    _buildChartCard(),
                    const SizedBox(height: 20),
                    _buildBudgetCard(),
                    const SizedBox(height: 20),
                    _buildRecentHeader(),
                    const SizedBox(height: 12),
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver Header (Balance Card) ─────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _headerSlide,
        child: FadeTransition(
          opacity: _headerFade,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A1A2E).withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'My Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${_balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _balance >= 0 ? Colors.white : const Color(0xFFEF5350),
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                // Mini sparkline dots decoration
                Row(
                  children: List.generate(
                    8,
                        (i) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 6,
                      height: 6 + (i % 3 * 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15 + i * 0.05),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Income / Expense Summary Row ─────────────────────────────────────────

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            label: 'Income',
            amount: _totalIncome,
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFF26C485),
            bg: const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            label: 'Expenses',
            amount: _totalExpense,
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFFEF5350),
            bg: const Color(0xFFFFEBEE),
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9EA7), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '\$${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chart Card (Income vs Expense Donut) ─────────────────────────────────

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OVERVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E9EA7),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    income: _totalIncome,
                    expense: _totalExpense,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_totalExpense / (_totalIncome == 0 ? 1 : _totalIncome) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const Text(
                          'spent',
                          style: TextStyle(fontSize: 10, color: Color(0xFF9E9EA7)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem('Income', const Color(0xFF26C485), _totalIncome),
                    const SizedBox(height: 12),
                    _legendItem('Expenses', const Color(0xFFEF5350), _totalExpense),
                    const SizedBox(height: 12),
                    _legendItem('Savings', const Color(0xFF5B8DEF), _balance > 0 ? _balance : 0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, double amount) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B6B80), fontWeight: FontWeight.w500)),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  // ── Budget Progress Card ──────────────────────────────────────────────────

  Widget _buildBudgetCard() {
    final pct = (_budgetProgress * 100).toStringAsFixed(0);
    final isOver = _totalExpense > _monthlyBudget;
    final progressColor = isOver
        ? const Color(0xFFEF5350)
        : _budgetProgress > 0.75
        ? const Color(0xFFFF9800)
        : const Color(0xFF26C485);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MONTHLY BUDGET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9E9EA7),
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOver ? 'Over Budget!' : '$pct% used',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _budgetProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F1F6),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${_totalExpense.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B80), fontWeight: FontWeight.w600),
              ),
              Text(
                'Limit: \$${_monthlyBudget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B80), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Transactions ───────────────────────────────────────────────────

  Widget _buildRecentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.2,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B8DEF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final recent = _transactions.take(5).toList();

    return Column(
      children: List.generate(recent.length, (i) {
        final tx = recent[i];
        final isIncome = tx.type == AppTransactionType.income;
        final color = isIncome ? const Color(0xFF26C485) : const Color(0xFFEF5350);
        final bg = isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

        return AnimatedBuilder(
          animation: _cardsAnim,
          builder: (ctx, child) {
            final delay = (i * 0.1).clamp(0.0, 1.0);
            final progress = (((_cardsAnim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
            return Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - progress)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A1A2E).withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
                  child: Icon(_categoryIcon(tx.category), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.category} • ${_timeAgo(tx.date)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9EA7)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Donut Chart Painter ──────────────────────────────────────────────────────

class _DonutChartPainter extends CustomPainter {
  final double income;
  final double expense;

  _DonutChartPainter({required this.income, required this.expense});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;

    final total = income + expense;
    if (total == 0) return;

    final bgPaint = Paint()
      ..color = const Color(0xFFF0F1F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Income arc
    final incomePaint = Paint()
      ..color = const Color(0xFF26C485)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final expensePaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final savingsPaint = Paint()
      ..color = const Color(0xFF5B8DEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final savings = (income - expense).clamp(0, double.infinity);
    final grandTotal = expense + savings + (income - expense - savings).clamp(0, double.infinity);
    final chartTotal = expense + income;

    final expenseAngle = 2 * math.pi * (expense / chartTotal);
    final incomeAngle = 2 * math.pi * (income / chartTotal);

    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      expenseAngle - 0.1,
      false,
      expensePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + expenseAngle,
      incomeAngle - 0.1,
      false,
      incomePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}