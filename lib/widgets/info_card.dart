import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          if (item.name == 'Lihat Pengalaman') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExperienceListScreen(),
              ),
            );
            return;
          }
          if (item.name == 'Tambah Pengalaman') {
            if (!await ensureLoggedIn(context) || !context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExperienceFormPage(),
              ),
            );
            return;
          }
          if (item.name == 'Logout') {
            final authState = context.read<AuthState>();
            if (!authState.isLoggedIn) return;
            await authState.logout();
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logout berhasil.')));
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Kamu telah menekan tombol ${item.name}!'),
              ),
            );
          if (item.name == "Tambah Pendidikan") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EducationFormPage(),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
