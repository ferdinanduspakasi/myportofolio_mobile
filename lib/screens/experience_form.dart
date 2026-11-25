import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _startDateKey = GlobalKey<FormFieldState<DateTime>>();
  String _title = '';
  String _description = '';
  ExperienceCategory _category = ExperienceCategory.fullTime;
  DateTime? _startedAt;
  DateTime? _endedAt;
  String? _thumbnail;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final authState = context.read<AuthState>();
      final token = authState.token;
      if (token == null) return;

      final newExperience = Experience(
        title: _title,
        description: _description,
        category: _category,
        startedAt: _startedAt!,
        endedAt: _endedAt,
        thumbnail: _thumbnail,
      );
      final experience = await context.read<ApiClient>().createExperience(
        newExperience,
        token: token,
      );
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pengalaman berhasil ditambahkan!'),
          content: Text(experience.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      form.reset();
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        await context.read<AuthState>().logout();
        if (!mounted) return;
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add experience: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    return null;
  }

  String? _validateUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final url = Uri.tryParse(text);
    if (url == null ||
        (url.scheme != 'http' && url.scheme != 'https') ||
        url.host.isEmpty) {
      return 'Enter a valid URL.';
    }
    return null;
  }

  Widget _field(
    String label,
    void Function(String) onSaved, {
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        onSaved: (value) => onSaved(value!.trim()),
      ),
    );
  }

  Widget _dateField({
    Key? key,
    required String label,
    required void Function(DateTime?) onSaved,
    required String? Function(DateTime?) validator,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FormField<DateTime>(
        key: key,
        onSaved: onSaved,
        validator: validator,
        builder: (field) {
          final date = field.value;
          return InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
              border: const OutlineInputBorder(),
              suffixIcon: optional && date != null
                  ? IconButton(
                      tooltip: 'Clear end date',
                      onPressed: _isSubmitting
                          ? null
                          : () => field.didChange(null),
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            child: TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                date == null
                    ? 'Select date'
                    : MaterialLocalizations.of(context).formatMediumDate(date),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100, 12, 31),
                      );
                      if (selected != null && field.mounted) {
                        field.didChange(selected);
                      }
                    },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                'Title',
                (value) => _title = value,
                validator: _requiredField,
                maxLength: 255,
              ),
              _field(
                'Description',
                (value) => _description = value,
                validator: _requiredField,
                maxLines: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButtonFormField<ExperienceCategory>(
                  initialValue: ExperienceCategory.fullTime,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final category in ExperienceCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: _isSubmitting ? null : (_) {},
                  onSaved: (value) => _category = value!,
                ),
              ),
              _dateField(
                key: _startDateKey,
                label: 'Start Date',
                onSaved: (date) => _startedAt = date,
                validator: (date) =>
                    date == null ? 'Start date is required.' : null,
              ),
              _dateField(
                label: 'End Date (Optional)',
                onSaved: (date) => _endedAt = date,
                optional: true,
                validator: (date) {
                  final start = _startDateKey.currentState?.value;
                  if (date != null && start != null && date.isBefore(start)) {
                    return 'End date cannot be before start date.';
                  }
                  return null;
                },
              ),
              _field(
                'Thumbnail URL (Optional)',
                (value) => _thumbnail = value.isEmpty ? null : value,
                validator: _validateUrl,
                keyboardType: TextInputType.url,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
