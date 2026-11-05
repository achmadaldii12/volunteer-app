import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/seed_data.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  final Color color;
  const ArticleScreen({super.key, required this.article, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 190,
          foregroundColor: Colors.white,
          backgroundColor: color,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color, Color.lerp(color, Colors.black, 0.45)!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: PageWrap(
                  maxWidth: 760,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Pill(article.category, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PageWrap(
            maxWidth: 760,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 10),
              Text('${article.author} • ${article.minutes} menit baca', style: TextStyle(color: context.muted)),
              const Divider(height: 36),
              for (final p in article.paragraphs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(p, style: const TextStyle(fontSize: 16.5, height: 1.65)),
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: context.softTeal, borderRadius: BorderRadius.circular(16)),
                child: Row(children: const [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(child: Text('Siap mencoba? Buka tab Cari dan temukan aktivitas pertamamu.')),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class ArticleListScreen extends StatelessWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Volunteer')),
      body: SingleChildScrollView(
        child: PageWrap(
          maxWidth: 1000,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          child: Column(children: [
            for (var i = 0; i < SeedData.articles.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Builder(builder: (ctx) {
                  final a = SeedData.articles[i];
                  final c = kCategories[(i * 3 + 1) % kCategories.length].color;
                  return AppCard(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ArticleScreen(article: a, color: c))),
                    child: Row(children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: [c, Color.lerp(c, Colors.black, 0.4)!])),
                        child: Icon(kCategories[(i * 3 + 1) % kCategories.length].icon, color: Colors.white, size: 38),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.category, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5)),
                          const SizedBox(height: 4),
                          Text(a.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(a.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: ctx.muted)),
                        ]),
                      ),
                    ]),
                  );
                }),
              ),
          ]),
        ),
      ),
    );
  }
}
