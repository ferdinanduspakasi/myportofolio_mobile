import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _endDateController = TextEditingController();
  String _institutionName = '';
  String _degree = 'bachelor';
  String _fieldOfStudy = '';
  String _logoUrl = '';
  String _description = '';
  DateTime? _endedAt;

  final List<({String value, String label})> _degrees = [
    (value: 'junior-high-school', label: 'Middle School'),
    (value: 'high-school', label: 'High School'),
    (value: 'diploma', label: 'Diploma'),
    (value: 'bachelor', label: "Bachelor's"),
    (value: 'master', label: "Master's"),
    (value: 'doctorate', label: 'Doctorate'),
    (value: 'certification', label: 'Certification'),
  ];

  Future<void> _selectEndDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _endedAt = selectedDate;
        _endDateController.text = _formattedEndDate;
      });
    }
  }

  void _showSummary() {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Education successfully added!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institution: ${_institutionName.trim()}'),
                Text('Degree: ${_degreeLabel}'),
                Text('Field of Study: ${_fieldOfStudy.trim()}'),
                Text('Logo URL: ${_logoUrl.trim()}'),
                Text('Description: ${_description.trim()}'),
                Text('End Date: ${_formattedEndDate}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _formKey.currentState!.reset();
                setState(() {
                  _institutionName = '';
                  _degree = 'bachelor';
                  _fieldOfStudy = '';
                  _logoUrl = '';
                  _description = '';
                  _endedAt = null;
                  _endDateController.clear();
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String get _degreeLabel =>
      _degrees.firstWhere((degree) => degree.value == _degree).label;

  String get _formattedEndDate => _endedAt == null
      ? '-'
      : '${_endedAt!.year.toString().padLeft(4, '0')}-'
            '${_endedAt!.month.toString().padLeft(2, '0')}-'
            '${_endedAt!.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Education Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLength: 255,
                  decoration: InputDecoration(
                    hintText: 'Nama sekolah/universitas',
                    labelText: 'Nama Institusi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _institutionName = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama institusi tidak boleh kosong!';
                    }
                    if (value.trim().length > 255) {
                      return 'Nama institusi maksimal 255 karakter.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Jenjang Pendidikan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _degree,
                  items: _degrees
                      .map(
                        (degree) => DropdownMenuItem<String>(
                          value: degree.value,
                          child: Text(degree.label),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value == null) return;
                    setState(() {
                      _degree = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLength: 255,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Ilmu Komputer',
                    labelText: 'Bidang Studi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _fieldOfStudy = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bidang studi tidak boleh kosong!';
                    }
                    if (value.trim().length > 255) {
                      return 'Bidang studi maksimal 255 karakter.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Opsional, gunakan URL http atau https',
                    labelText: 'URL Logo Institusi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _logoUrl = value;
                    });
                  },
                  validator: (String? value) {
                    final String url = value?.trim() ?? '';
                    if (url.isNotEmpty &&
                        !url.toLowerCase().startsWith(RegExp('https?://'))) {
                      return 'URL logo harus menggunakan http atau https.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ceritakan pengalaman pendidikanmu',
                    labelText: 'Deskripsi (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  readOnly: true,
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Selesai (opsional)',
                    hintText: 'Pilih tanggal selesai',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: _selectEndDate,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _showSummary,
                    child: const Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
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
